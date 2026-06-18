package api

import (
	"encoding/json"
	"log/slog"
	"net/http"

	"github.com/quanttide/qtadmin-provider/internal/model"
	"github.com/quanttide/qtadmin-provider/internal/store"
)

type ConnectHandler struct {
	store store.Store
}

func NewConnectHandler(st store.Store) *ConnectHandler {
	return &ConnectHandler{store: st}
}

func (h *ConnectHandler) ListNotifications(w http.ResponseWriter, r *http.Request) {
	data, err := h.store.List("connect/notifications")
	if err != nil {
		slog.Error("list notifications", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to list notifications", http.StatusInternalServerError)
		return
	}
	var notifications []model.Notification
	if err := json.Unmarshal(data, &notifications); err != nil {
		slog.Error("parse notifications", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse notifications", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, notifications, http.StatusOK)
}

func (h *ConnectHandler) GetNotification(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	data, err := h.store.Get("connect/notifications", id)
	if err != nil {
		WriteError(w, "NOT_FOUND", "notification not found", http.StatusNotFound)
		return
	}
	var notification model.Notification
	if err := json.Unmarshal(data, &notification); err != nil {
		slog.Error("parse notification", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse notification", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, notification, http.StatusOK)
}
