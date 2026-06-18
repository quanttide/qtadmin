package connect

import (
	"fmt"
	"log/slog"
	"os"
)

type LarkConfig struct {
	AppID     string
	AppSecret string
}

func LoadLarkConfig() *LarkConfig {
	return &LarkConfig{
		AppID:     os.Getenv("LARK_APP_ID"),
		AppSecret: os.Getenv("LARK_APP_SECRET"),
	}
}

type LarkClient struct {
	config *LarkConfig
}

func NewLarkClient(cfg *LarkConfig) *LarkClient {
	return &LarkClient{config: cfg}
}

func (c *LarkClient) GetTenantAccessToken() (string, error) {
	slog.Info("lark: get tenant_access_token (mock)")
	return "mock_tenant_token", nil
}

func (c *LarkClient) SendTextMessage(openID, text string) error {
	slog.Info("lark: send text message (mock)",
		"open_id", openID, "text", text)
	if c.config.AppID == "" || c.config.AppSecret == "" {
		return fmt.Errorf("lark: app id or secret not configured")
	}
	return nil
}

func (c *LarkClient) HandleApprovalWebhook(body []byte) error {
	slog.Info("lark: approval webhook received (mock)", "body", string(body))
	return nil
}
