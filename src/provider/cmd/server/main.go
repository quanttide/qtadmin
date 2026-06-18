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
	"github.com/quanttide/qtadmin-provider/internal/db"
)

func main() {
	cfgPath := os.Getenv("CONFIG_PATH")
	cfg, err := config.Load(cfgPath)
	if err != nil {
		slog.Error("failed to load config", "error", err)
		os.Exit(1)
	}

	setupLogger(cfg.Log)
	slog.Info("config loaded", "addr", cfg.Server.Addr, "database", cfg.Database.URL)

	database, err := db.Open(cfg.Database.URL)
	if err != nil {
		slog.Warn("database unavailable, running without persistence", "error", err)
	} else {
		slog.Info("database connected", "dsn", database.DSN())
	}
	_ = database

	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", api.Health)

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
