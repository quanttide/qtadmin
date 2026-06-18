package connect

import (
	"fmt"
	"log/slog"
	"os"
)

type SMTPConfig struct {
	Host string
	Port string
	User string
	Pass string
}

func LoadSMTPConfig() *SMTPConfig {
	return &SMTPConfig{
		Host: os.Getenv("SMTP_HOST"),
		Port: os.Getenv("SMTP_PORT"),
		User: os.Getenv("SMTP_USER"),
		Pass: os.Getenv("SMTP_PASS"),
	}
}

type EmailClient struct {
	config *SMTPConfig
}

func NewEmailClient(cfg *SMTPConfig) *EmailClient {
	return &EmailClient{config: cfg}
}

func (c *EmailClient) Send(to, subject, body string) error {
	slog.Info("email: send (mock)",
		"to", to, "subject", subject, "body", body)
	if c.config.Host == "" || c.config.Port == "" {
		return fmt.Errorf("email: smtp not configured")
	}
	return nil
}

func (c *EmailClient) HandleIncomingWebhook(body []byte) error {
	slog.Info("email: incoming webhook received (mock)", "body", string(body))
	return nil
}
