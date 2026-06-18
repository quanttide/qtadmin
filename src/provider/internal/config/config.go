package config

import (
	"encoding/json"
	"fmt"
	"os"
)

type Config struct {
	Server   ServerConfig   `json:"server"`
	Database DatabaseConfig `json:"database"`
	Log      LogConfig      `json:"log"`
}

type ServerConfig struct {
	Addr string `json:"addr"`
}

type DatabaseConfig struct {
	URL string `json:"url"`
}

type LogConfig struct {
	Level  string `json:"level"`
	Format string `json:"format"`
}

func Load(path string) (*Config, error) {
	cfg := &Config{
		Server:   ServerConfig{Addr: ":8000"},
		Database: DatabaseConfig{URL: "qtadmin.db"},
		Log:      LogConfig{Level: "info", Format: "text"},
	}

	if path != "" {
		data, err := os.ReadFile(path)
		if err != nil {
			return nil, fmt.Errorf("read config: %w", err)
		}
		if err := json.Unmarshal(data, cfg); err != nil {
			return nil, fmt.Errorf("parse config: %w", err)
		}
	}

	if v := os.Getenv("ADDR"); v != "" {
		cfg.Server.Addr = v
	}
	if v := os.Getenv("DATABASE_URL"); v != "" {
		cfg.Database.URL = v
	}
	if v := os.Getenv("LOG_LEVEL"); v != "" {
		cfg.Log.Level = v
	}
	if v := os.Getenv("LOG_FORMAT"); v != "" {
		cfg.Log.Format = v
	}

	return cfg, nil
}
