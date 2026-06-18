package connect

import (
	"testing"
)

func TestLarkClient_GetTenantAccessToken(t *testing.T) {
	cfg := &LarkConfig{AppID: "test-id", AppSecret: "test-secret"}
	c := NewLarkClient(cfg)
	token, err := c.GetTenantAccessToken()
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if token != "mock_tenant_token" {
		t.Errorf("got %q, want %q", token, "mock_tenant_token")
	}
}

func TestLarkClient_SendTextMessage_EmptyConfig(t *testing.T) {
	cfg := &LarkConfig{}
	c := NewLarkClient(cfg)
	err := c.SendTextMessage("u1", "hello")
	if err == nil {
		t.Fatal("expected error for empty config, got nil")
	}
}

func TestLarkClient_SendTextMessage_ValidConfig(t *testing.T) {
	cfg := &LarkConfig{AppID: "test-id", AppSecret: "test-secret"}
	c := NewLarkClient(cfg)
	err := c.SendTextMessage("u1", "hello")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestLarkClient_HandleApprovalWebhook(t *testing.T) {
	cfg := &LarkConfig{AppID: "test-id", AppSecret: "test-secret"}
	c := NewLarkClient(cfg)
	err := c.HandleApprovalWebhook([]byte(`{"event":"test"}`))
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
}
