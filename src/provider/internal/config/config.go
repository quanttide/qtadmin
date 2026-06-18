package config

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/quanttide/qtadmin-provider/internal/store"
)

type Config struct {
	Server  ServerConfig  `json:"server"`
	Store   store.Config  `json:"store"`
	Log     LogConfig     `json:"log"`
	Connect ConnectConfig `json:"connect"`
}

type ConnectConfig struct {
	LarkAppID     string `json:"lark_app_id"`
	LarkAppSecret string `json:"lark_app_secret"`
	SMTPHost      string `json:"smtp_host"`
	SMTPPort      string `json:"smtp_port"`
	SMTPUser      string `json:"smtp_user"`
	SMTPPass      string `json:"smtp_pass"`
}

type ServerConfig struct {
	Addr string `json:"addr"`
}

type LogConfig struct {
	Level  string `json:"level"`
	Format string `json:"format"`
}

func Load(path string) (*Config, error) {
	cfg := &Config{
		Server: ServerConfig{Addr: ":8000"},
		Store: store.Config{
			Driver: "file",
			Path:   "data",
		},
		Log: LogConfig{Level: "info", Format: "text"},
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

	if v := os.Getenv("QTADMIN_ADDR"); v != "" {
		cfg.Server.Addr = v
	} else if v := os.Getenv("ADDR"); v != "" {
		cfg.Server.Addr = v
	}
	if v := os.Getenv("QTADMIN_STORE_DRIVER"); v != "" {
		cfg.Store.Driver = v
	} else if v := os.Getenv("STORE_DRIVER"); v != "" {
		cfg.Store.Driver = v
	}
	if v := os.Getenv("QTADMIN_STORE_PATH"); v != "" {
		cfg.Store.Path = v
	} else if v := os.Getenv("STORE_PATH"); v != "" {
		cfg.Store.Path = v
	}
	if v := os.Getenv("QTADMIN_LOG_LEVEL"); v != "" {
		cfg.Log.Level = v
	} else if v := os.Getenv("LOG_LEVEL"); v != "" {
		cfg.Log.Level = v
	}
	if v := os.Getenv("QTADMIN_LOG_FORMAT"); v != "" {
		cfg.Log.Format = v
	} else if v := os.Getenv("LOG_FORMAT"); v != "" {
		cfg.Log.Format = v
	}

	return cfg, nil
}
