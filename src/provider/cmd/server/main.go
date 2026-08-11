package main

import (
	"context"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/quanttide/qtadmin-provider/internal/api"
	"github.com/quanttide/qtadmin-provider/internal/config"
	"github.com/quanttide/qtadmin-provider/internal/store"
)

// qtadmin provider 壳：服务骨架（config/store/health/日志/优雅关闭）。
//
// 领域 handler 已拆分迁移至各产品线仓库 examples/：
//   - human（employees/departments/positions/qtrecurit）→ qtcloud-human/examples/human-api/
//   - connect（rules/notifications）→ qtcloud-connect/examples/connect-api/
//   - course（qtclass courses/schedules/enrollments）→ qtcloud-course/examples/course-api/
//   - asset（qtcloud resources）→ qtcloud-asset/examples/asset-api/
//   - data（qtdata datasets）→ qtdata/examples/dataset-api/
//   - consult（qtconsult projects）→ qtconsult/examples/consult-api/
//
// 恢复领域服务时：从对应 examples/ 引入 handler 与 model，在下方注册路由。
func main() {
	cfgPath := os.Getenv("CONFIG_PATH")
	cfg, err := config.Load(cfgPath)
	if err != nil {
		slog.Error("failed to load config", "error", err)
		os.Exit(1)
	}

	setupLogger(cfg.Log)
	slog.Info("config loaded", "addr", cfg.Server.Addr, "store", cfg.Store)

	st, err := store.New(cfg.Store)
	if err != nil {
		slog.Error("failed to initialize store", "error", err)
		os.Exit(1)
	}
	defer st.Close()
	slog.Info("store initialized", "driver", cfg.Store.Driver, "path", cfg.Store.Path)

	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", api.Health)

	// 领域路由注册点（恢复时从 examples/ 引入 handler）

	handler := loggingMiddleware(mux)

	srv := &http.Server{Addr: cfg.Server.Addr, Handler: handler}

	go func() {
		slog.Info("listening", "addr", cfg.Server.Addr)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			slog.Error("server error", "error", err)
			os.Exit(1)
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	slog.Info("shutting down")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	srv.Shutdown(ctx)
}

func setupLogger(lc config.LogConfig) {
	var level slog.Level
	switch lc.Level {
	case "debug":
		level = slog.LevelDebug
	case "info":
		level = slog.LevelInfo
	case "warn":
		level = slog.LevelWarn
	case "error":
		level = slog.LevelError
	default:
		level = slog.LevelInfo
	}

	opts := &slog.HandlerOptions{Level: level}

	var h slog.Handler
	if lc.Format == "json" {
		h = slog.NewJSONHandler(os.Stdout, opts)
	} else {
		h = slog.NewTextHandler(os.Stdout, opts)
	}
	slog.SetDefault(slog.New(h))
}

func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		slog.Info("request", "method", r.Method, "path", r.URL.Path)
		next.ServeHTTP(w, r)
		slog.Info("response", "method", r.Method, "path", r.URL.Path, "duration", time.Since(start))
	})
}
