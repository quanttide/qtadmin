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

	humanHandler := api.NewHumanHandler(st)
	businessHandler := api.NewBusinessHandler(st)
	connectHandler := api.NewConnectHandler(st)
	authHandler := api.NewAuthHandler(st, cfg.Auth.JWTSecret)

	if cfg.Auth.AdminPassword != "" {
		if err := authHandler.EnsureAdmin(cfg.Auth.AdminPassword); err != nil {
			slog.Error("failed to seed admin user", "error", err)
			os.Exit(1)
		}
	}

	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", api.Health)

	mux.HandleFunc("GET /api/v1/employees", humanHandler.ListEmployees)
	mux.HandleFunc("POST /api/v1/employees", humanHandler.CreateEmployee)
	mux.HandleFunc("GET /api/v1/employees/{id}", humanHandler.GetEmployee)
	mux.HandleFunc("PUT /api/v1/employees/{id}", humanHandler.UpdateEmployee)
	mux.HandleFunc("DELETE /api/v1/employees/{id}", humanHandler.DeleteEmployee)

	mux.HandleFunc("GET /api/v1/departments", humanHandler.ListDepartments)
	mux.HandleFunc("POST /api/v1/departments", humanHandler.CreateDepartment)
	mux.HandleFunc("GET /api/v1/departments/{id}", humanHandler.GetDepartment)
	mux.HandleFunc("PUT /api/v1/departments/{id}", humanHandler.UpdateDepartment)
	mux.HandleFunc("DELETE /api/v1/departments/{id}", humanHandler.DeleteDepartment)

	mux.HandleFunc("GET /api/v1/positions", humanHandler.ListPositions)
	mux.HandleFunc("POST /api/v1/positions", humanHandler.CreatePosition)
	mux.HandleFunc("GET /api/v1/positions/{id}", humanHandler.GetPosition)
	mux.HandleFunc("PUT /api/v1/positions/{id}", humanHandler.UpdatePosition)
	mux.HandleFunc("DELETE /api/v1/positions/{id}", humanHandler.DeletePosition)

	mux.HandleFunc("GET /api/v1/connect/notifications", connectHandler.ListNotifications)
	mux.HandleFunc("GET /api/v1/connect/notifications/{id}", connectHandler.GetNotification)

	mux.HandleFunc("POST /api/v1/auth/login", authHandler.Login)

	authMW := api.AuthMiddleware(cfg.Auth.JWTSecret)
	mux.Handle("POST /api/v1/auth/refresh", authMW(http.HandlerFunc(authHandler.Refresh)))
	mux.Handle("GET /api/v1/auth/me", authMW(http.HandlerFunc(authHandler.Me)))

	mux.HandleFunc("GET /api/v1/qtconsult/projects", businessHandler.ListProjects)
	mux.HandleFunc("POST /api/v1/qtconsult/projects", businessHandler.CreateProject)
	mux.HandleFunc("GET /api/v1/qtconsult/projects/{id}", businessHandler.GetProject)
	mux.HandleFunc("PUT /api/v1/qtconsult/projects/{id}", businessHandler.UpdateProject)
	mux.HandleFunc("DELETE /api/v1/qtconsult/projects/{id}", businessHandler.DeleteProject)

	mux.HandleFunc("GET /api/v1/qtclass/courses", businessHandler.ListCourses)
	mux.HandleFunc("POST /api/v1/qtclass/courses", businessHandler.CreateCourse)
	mux.HandleFunc("GET /api/v1/qtclass/courses/{id}", businessHandler.GetCourse)
	mux.HandleFunc("PUT /api/v1/qtclass/courses/{id}", businessHandler.UpdateCourse)
	mux.HandleFunc("DELETE /api/v1/qtclass/courses/{id}", businessHandler.DeleteCourse)
	mux.HandleFunc("GET /api/v1/qtclass/schedules", businessHandler.ListSchedules)
	mux.HandleFunc("POST /api/v1/qtclass/enrollments", businessHandler.CreateEnrollment)

	mux.HandleFunc("GET /api/v1/qtcloud/resources", businessHandler.ListResources)
	mux.HandleFunc("POST /api/v1/qtcloud/resources", businessHandler.CreateResource)
	mux.HandleFunc("GET /api/v1/qtcloud/resources/{id}", businessHandler.GetResource)
	mux.HandleFunc("PUT /api/v1/qtcloud/resources/{id}", businessHandler.UpdateResource)
	mux.HandleFunc("DELETE /api/v1/qtcloud/resources/{id}", businessHandler.DeleteResource)

	mux.HandleFunc("GET /api/v1/qtdata/datasets", businessHandler.ListDatasets)
	mux.HandleFunc("POST /api/v1/qtdata/datasets", businessHandler.CreateDataset)
	mux.HandleFunc("GET /api/v1/qtdata/datasets/{id}", businessHandler.GetDataset)
	mux.HandleFunc("PUT /api/v1/qtdata/datasets/{id}", businessHandler.UpdateDataset)
	mux.HandleFunc("DELETE /api/v1/qtdata/datasets/{id}", businessHandler.DeleteDataset)

	mux.HandleFunc("POST /api/v1/qtrecurit/resumes", businessHandler.ImportResume)
	mux.HandleFunc("POST /api/v1/qtrecurit/interviews", businessHandler.CreateInterview)

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
