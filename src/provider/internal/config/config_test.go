package config

import (
	"os"
	"path/filepath"
	"testing"
)

func TestMain(m *testing.M) {
	os.Unsetenv("QTADMIN_STORE_PATH")
	os.Unsetenv("QTADMIN_ADDR")
	os.Unsetenv("QTADMIN_LOG_LEVEL")
	os.Unsetenv("QTADMIN_LOG_FORMAT")
	os.Unsetenv("ADDR")
	os.Unsetenv("STORE_PATH")
	os.Unsetenv("LOG_LEVEL")
	os.Unsetenv("LOG_FORMAT")
	os.Exit(m.Run())
}

func TestLoad_EmptyPath(t *testing.T) {
	cfg, err := Load("")
	if err != nil {
		t.Fatalf("Load empty path: %v", err)
	}
	if cfg.Server.Addr != ":8000" {
		t.Errorf("addr: got %q, want %q", cfg.Server.Addr, ":8000")
	}
	if cfg.Store.Driver != "file" {
		t.Errorf("store driver: got %q, want %q", cfg.Store.Driver, "file")
	}
	if cfg.Store.Path != "data" {
		t.Errorf("store path: got %q, want %q", cfg.Store.Path, "data")
	}
	if cfg.Log.Level != "info" {
		t.Errorf("log level: got %q, want %q", cfg.Log.Level, "info")
	}
	if cfg.Log.Format != "text" {
		t.Errorf("log format: got %q, want %q", cfg.Log.Format, "text")
	}
}

func TestLoad_CustomPath(t *testing.T) {
	dir := t.TempDir()
	configContent := `{"server":{"addr":":9000"},"store":{"driver":"memory","path":""},"log":{"level":"debug","format":"json"}}`
	configPath := filepath.Join(dir, "config.json")
	if err := os.WriteFile(configPath, []byte(configContent), 0644); err != nil {
		t.Fatalf("write config: %v", err)
	}

	cfg, err := Load(configPath)
	if err != nil {
		t.Fatalf("Load custom path: %v", err)
	}
	if cfg.Server.Addr != ":9000" {
		t.Errorf("addr: got %q, want %q", cfg.Server.Addr, ":9000")
	}
	if cfg.Store.Driver != "memory" {
		t.Errorf("store driver: got %q, want %q", cfg.Store.Driver, "memory")
	}
	if cfg.Log.Level != "debug" {
		t.Errorf("log level: got %q, want %q", cfg.Log.Level, "debug")
	}
	if cfg.Log.Format != "json" {
		t.Errorf("log format: got %q, want %q", cfg.Log.Format, "json")
	}
}

func TestLoad_InvalidPath(t *testing.T) {
	_, err := Load("/nonexistent/config.json")
	if err == nil {
		t.Fatal("expected error for nonexistent path, got nil")
	}
}

func TestLoad_InvalidJSON(t *testing.T) {
	dir := t.TempDir()
	configPath := filepath.Join(dir, "bad.json")
	if err := os.WriteFile(configPath, []byte("{invalid"), 0644); err != nil {
		t.Fatalf("write config: %v", err)
	}
	_, err := Load(configPath)
	if err == nil {
		t.Fatal("expected error for invalid JSON, got nil")
	}
}

func TestLoad_EnvOverrides(t *testing.T) {
	os.Setenv("QTADMIN_ADDR", ":7000")
	os.Setenv("QTADMIN_STORE_DRIVER", "postgres")
	os.Setenv("QTADMIN_STORE_PATH", "/data/db")
	os.Setenv("QTADMIN_LOG_LEVEL", "warn")
	os.Setenv("QTADMIN_LOG_FORMAT", "json")
	defer func() {
		os.Unsetenv("QTADMIN_ADDR")
		os.Unsetenv("QTADMIN_STORE_DRIVER")
		os.Unsetenv("QTADMIN_STORE_PATH")
		os.Unsetenv("QTADMIN_LOG_LEVEL")
		os.Unsetenv("QTADMIN_LOG_FORMAT")
	}()

	cfg, err := Load("")
	if err != nil {
		t.Fatalf("Load with env overrides: %v", err)
	}
	if cfg.Server.Addr != ":7000" {
		t.Errorf("addr: got %q, want %q", cfg.Server.Addr, ":7000")
	}
	if cfg.Store.Driver != "postgres" {
		t.Errorf("store driver: got %q, want %q", cfg.Store.Driver, "postgres")
	}
	if cfg.Store.Path != "/data/db" {
		t.Errorf("store path: got %q, want %q", cfg.Store.Path, "/data/db")
	}
	if cfg.Log.Level != "warn" {
		t.Errorf("log level: got %q, want %q", cfg.Log.Level, "warn")
	}
	if cfg.Log.Format != "json" {
		t.Errorf("log format: got %q, want %q", cfg.Log.Format, "json")
	}
}

func TestLoad_LegacyEnvOverrides(t *testing.T) {
	os.Setenv("ADDR", ":6000")
	os.Setenv("STORE_PATH", "/legacy/data")
	defer func() {
		os.Unsetenv("ADDR")
		os.Unsetenv("STORE_PATH")
	}()

	cfg, err := Load("")
	if err != nil {
		t.Fatalf("Load with legacy env: %v", err)
	}
	if cfg.Server.Addr != ":6000" {
		t.Errorf("addr: got %q, want %q", cfg.Server.Addr, ":6000")
	}
	if cfg.Store.Path != "/legacy/data" {
		t.Errorf("store path: got %q, want %q", cfg.Store.Path, "/legacy/data")
	}
}
