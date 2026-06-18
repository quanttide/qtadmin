package api

import (
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"time"

	"github.com/quanttide/qtadmin-provider/internal/connect"
	"github.com/quanttide/qtadmin-provider/internal/model"
	"github.com/quanttide/qtadmin-provider/internal/store"
)

type ConnectHandler struct {
	store       store.Store
	larkClient  *connect.LarkClient
	emailClient *connect.EmailClient
}

func NewConnectHandler(st store.Store) *ConnectHandler {
	return &ConnectHandler{
		store:       st,
		larkClient:  connect.NewLarkClient(connect.LoadLarkConfig()),
		emailClient: connect.NewEmailClient(connect.LoadSMTPConfig()),
	}
}

type NotifyRequest struct {
	Channel string `json:"channel"`
	Title   string `json:"title"`
	Content string `json:"content"`
	Target  string `json:"target"`
}

func (h *ConnectHandler) Notify(w http.ResponseWriter, r *http.Request) {
	var req NotifyRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	if req.Channel == "" || req.Title == "" || req.Content == "" || req.Target == "" {
		WriteError(w, "VALIDATION_ERROR", "channel, title, content, target are required", http.StatusBadRequest)
		return
	}

	now := time.Now()
	notification := model.Notification{
		Title:     req.Title,
		Content:   req.Content,
		Channel:   req.Channel,
		Target:    req.Target,
		Status:    "pending",
		CreatedAt: now,
	}

	data, err := json.Marshal(notification)
	if err != nil {
		slog.Error("encode notification", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}

	id, err := h.store.Create("connect/notifications", data)
	if err != nil {
		slog.Error("create notification", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to create notification", http.StatusInternalServerError)
		return
	}

	notification.ID = id
	notification.Status = "sent"

	switch req.Channel {
	case "lark":
		if err := h.larkClient.SendTextMessage(req.Target, req.Content); err != nil {
			slog.Error("lark send", "error", err)
			notification.Status = "failed"
		}
	case "email":
		if err := h.emailClient.Send(req.Target, req.Title, req.Content); err != nil {
			slog.Error("email send", "error", err)
			notification.Status = "failed"
		}
	default:
		notification.Status = "failed"
	}

	data, err = json.Marshal(notification)
	if err != nil {
		slog.Error("encode notification with id", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to encode data", http.StatusInternalServerError)
		return
	}
	if err := h.store.Update("connect/notifications", id, data); err != nil {
		slog.Error("persist notification status", "error", err)
	}

	WriteJSON(w, notification, http.StatusCreated)
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

func (h *ConnectHandler) LarkWebhook(w http.ResponseWriter, r *http.Request) {
	body, err := io.ReadAll(r.Body)
	if err != nil {
		WriteError(w, "INTERNAL_ERROR", "failed to read body", http.StatusInternalServerError)
		return
	}
	defer r.Body.Close()
	if err := h.larkClient.HandleApprovalWebhook(body); err != nil {
		slog.Error("lark webhook", "error", err)
		WriteError(w, "INTERNAL_ERROR", "webhook processing failed", http.StatusInternalServerError)
		return
	}
	WriteJSON(w, map[string]string{"status": "ok"}, http.StatusOK)
}
