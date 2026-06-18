package api

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func registerConnectRoutes(h *ConnectHandler) *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("POST /api/v1/connect/notify", h.Notify)
	mux.HandleFunc("GET /api/v1/connect/notifications", h.ListNotifications)
	mux.HandleFunc("GET /api/v1/connect/notifications/{id}", h.GetNotification)
	mux.HandleFunc("POST /api/v1/connect/webhook/lark", h.LarkWebhook)
	return mux
}

func TestNotifyAndList(t *testing.T) {
	s, cleanup := testSetup(t)
	defer cleanup()

	h := NewConnectHandler(s)
	mux := registerConnectRoutes(h)

	var notifID string

	t.Run("Notify lark (mock)", func(t *testing.T) {
		body := `{"channel":"lark","title":"Test","content":"Hello","target":"user_123"}`
		req := httptest.NewRequest("POST", "/api/v1/connect/notify", strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusCreated {
			t.Fatalf("expected 201, got %d: %s", rec.Code, rec.Body.String())
		}

		var result map[string]any
		if err := json.Unmarshal(rec.Body.Bytes(), &result); err != nil {
			t.Fatalf("unmarshal failed: %v", err)
		}
		if result["id"] == "" {
			t.Error("expected non-empty id")
		}
		// lark mock returns 'failed' when env vars are not set, but record is still created
		if result["status"] == "" {
			t.Error("expected non-empty status")
		}
		notifID = result["id"].(string)
	})

	t.Run("Notify email", func(t *testing.T) {
		body := `{"channel":"email","title":"Email Test","content":"Email body","target":"test@test.com"}`
		req := httptest.NewRequest("POST", "/api/v1/connect/notify", strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusCreated {
			t.Fatalf("expected 201, got %d: %s", rec.Code, rec.Body.String())
		}
	})

	t.Run("List notifications", func(t *testing.T) {
		req := httptest.NewRequest("GET", "/api/v1/connect/notifications", nil)
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusOK {
			t.Fatalf("expected 200, got %d", rec.Code)
		}

		var items []any
		if err := json.Unmarshal(rec.Body.Bytes(), &items); err != nil {
			t.Fatalf("unmarshal failed: %v", err)
		}
		if len(items) < 2 {
			t.Errorf("expected at least 2 notifications, got %d", len(items))
		}
	})

	t.Run("Get notification by id", func(t *testing.T) {
		req := httptest.NewRequest("GET", "/api/v1/connect/notifications/"+notifID, nil)
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusOK {
			t.Fatalf("expected 200, got %d: %s", rec.Code, rec.Body.String())
		}

		var result map[string]any
		json.Unmarshal(rec.Body.Bytes(), &result)
		if result["title"] != "Test" {
			t.Errorf("expected title=Test, got %v", result["title"])
		}
	})

	t.Run("Get non-existent notification returns 404", func(t *testing.T) {
		req := httptest.NewRequest("GET", "/api/v1/connect/notifications/nonexistent", nil)
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusNotFound {
			t.Errorf("expected 404, got %d", rec.Code)
		}
	})

	t.Run("Notify validation", func(t *testing.T) {
		body := `{"channel":"lark"}`
		req := httptest.NewRequest("POST", "/api/v1/connect/notify", strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusBadRequest {
			t.Errorf("expected 400, got %d", rec.Code)
		}
	})

	t.Run("Webhook lark", func(t *testing.T) {
		req := httptest.NewRequest("POST", "/api/v1/connect/webhook/lark", strings.NewReader(`{"event":"approval"}`))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusOK {
			t.Errorf("expected 200, got %d", rec.Code)
		}
	})
}
