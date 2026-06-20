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

// --- Classification Rules ---

func (h *ConnectHandler) ListRules(w http.ResponseWriter, r *http.Request) {
	data, err := h.store.List("connect/rules")
	if err != nil {
		slog.Error("list rules", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to list rules", http.StatusInternalServerError)
		return
	}
	var rules []model.PositionRule
	if err := json.Unmarshal(data, &rules); err != nil {
		slog.Error("parse rules", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse rules", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, rules, http.StatusOK)
}

func (h *ConnectHandler) CreateRule(w http.ResponseWriter, r *http.Request) {
	var rule model.PositionRule
	if err := json.NewDecoder(r.Body).Decode(&rule); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	if rule.Name == "" || len(rule.Keywords) == 0 {
		WriteError(w, "VALIDATION_ERROR", "name and keywords are required", http.StatusBadRequest)
		return
	}

	data, err := json.Marshal(rule)
	if err != nil {
		slog.Error("encode rule", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}

	id, err := h.store.Create("connect/rules", data)
	if err != nil {
		slog.Error("create rule", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to create rule", http.StatusInternalServerError)
		return
	}

	rule.ID = id
	data, err = json.Marshal(rule)
	if err != nil {
		slog.Error("encode rule with id", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("connect/rules", id, data); err != nil {
		slog.Error("persist rule id", "error", err)
	}

	WriteJSON(w, rule, http.StatusCreated)
}

func (h *ConnectHandler) UpdateRule(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	var rule model.PositionRule
	if err := json.NewDecoder(r.Body).Decode(&rule); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	rule.ID = id

	data, err := json.Marshal(rule)
	if err != nil {
		slog.Error("encode rule", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("connect/rules", id, data); err != nil {
		WriteError(w, "NOT_FOUND", "rule not found", http.StatusNotFound)
		return
	}
	WriteJSON(w, rule, http.StatusOK)
}

func (h *ConnectHandler) DeleteRule(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if err := h.store.Delete("connect/rules", id); err != nil {
		WriteError(w, "NOT_FOUND", "rule not found", http.StatusNotFound)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
