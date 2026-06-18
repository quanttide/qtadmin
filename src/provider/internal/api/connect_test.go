package api

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/quanttide/qtadmin-provider/internal/model"
)

func registerConnectRoutes(h *ConnectHandler) *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /api/v1/connect/notifications", h.ListNotifications)
	mux.HandleFunc("GET /api/v1/connect/notifications/{id}", h.GetNotification)
	return mux
}

func TestListNotifications(t *testing.T) {
	s, cleanup := testSetup(t)
	defer cleanup()

	h := NewConnectHandler(s)
	mux := registerConnectRoutes(h)

	t.Run("List returns empty list", func(t *testing.T) {
		req := httptest.NewRequest("GET", "/api/v1/connect/notifications", nil)
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusOK {
			t.Fatalf("expected 200, got %d", rec.Code)
		}
	})

	t.Run("Get non-existent returns 404", func(t *testing.T) {
		req := httptest.NewRequest("GET", "/api/v1/connect/notifications/nonexistent", nil)
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusNotFound {
			t.Errorf("expected 404, got %d", rec.Code)
		}
	})
}

func TestNotificationCRUD(t *testing.T) {
	s, cleanup := testSetup(t)
	defer cleanup()

	data, _ := json.Marshal(model.Notification{Title: "Test", Content: "Hello", Channel: "lark", Target: "u1", Status: "sent"})
	id, err := s.Create("connect/notifications", data)
	if err != nil {
		t.Fatalf("seed notification: %v", err)
	}
	s.Update("connect/notifications", id, data)

	h := NewConnectHandler(s)
	mux := registerConnectRoutes(h)

	t.Run("Get notification by id", func(t *testing.T) {
		req := httptest.NewRequest("GET", "/api/v1/connect/notifications/"+id, nil)
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

	t.Run("List includes seeded notification", func(t *testing.T) {
		req := httptest.NewRequest("GET", "/api/v1/connect/notifications", nil)
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusOK {
			t.Fatalf("expected 200, got %d", rec.Code)
		}

		var items []any
		json.Unmarshal(rec.Body.Bytes(), &items)
		if len(items) < 1 {
			t.Errorf("expected at least 1 notification, got %d", len(items))
		}
	})
}
