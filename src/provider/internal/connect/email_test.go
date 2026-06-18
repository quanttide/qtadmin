package connect

import (
	"testing"
)

func TestEmailClient_HandleIncomingWebhook(t *testing.T) {
	cfg := &SMTPConfig{Host: "smtp.example.com", Port: "587"}
	c := NewEmailClient(cfg)
	err := c.HandleIncomingWebhook([]byte(`{"event":"test"}`))
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestEmailClient_Send_EmptyConfig(t *testing.T) {
	cfg := &SMTPConfig{}
	c := NewEmailClient(cfg)
	err := c.Send("to@test.com", "Subject", "Body")
	if err == nil {
		t.Fatal("expected error for empty config, got nil")
	}
}

func TestEmailClient_Send_ValidConfig(t *testing.T) {
	cfg := &SMTPConfig{Host: "smtp.example.com", Port: "587", User: "user", Pass: "pass"}
	c := NewEmailClient(cfg)
	err := c.Send("to@test.com", "Subject", "Body")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
}
