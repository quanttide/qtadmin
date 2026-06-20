package model

import (
	"encoding/json"
	"testing"
	"time"
)

func TestNotification(t *testing.T) {
	now := time.Date(2026, 6, 18, 10, 0, 0, 0, time.UTC)
	orig := Notification{
		ID:        "n1",
		Title:     "Test Alert",
		Content:   "Something happened",
		Channel:   "email",
		Status:    "sent",
		Target:    "all",
		CreatedAt: now,
		ReadAt:    nil,
	}
	data, err := json.Marshal(orig)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	var got Notification
	if err := json.Unmarshal(data, &got); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if got.ID != orig.ID || got.Title != orig.Title || got.Content != orig.Content {
		t.Errorf("field mismatch: got %+v, want %+v", got, orig)
	}
	if !got.CreatedAt.Equal(orig.CreatedAt) {
		t.Errorf("created_at: got %v, want %v", got.CreatedAt, orig.CreatedAt)
	}
	if got.ReadAt != nil {
		t.Errorf("expected nil read_at, got %v", got.ReadAt)
	}
}

func TestNotificationWithReadAt(t *testing.T) {
	now := time.Date(2026, 6, 18, 10, 0, 0, 0, time.UTC)
	read := time.Date(2026, 6, 18, 11, 0, 0, 0, time.UTC)
	orig := Notification{
		ID:        "n2",
		Title:     "Read Alert",
		Content:   "Check this",
		Channel:   "lark",
		Status:    "read",
		Target:    "user1",
		CreatedAt: now,
		ReadAt:    &read,
	}
	data, err := json.Marshal(orig)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	var got Notification
	if err := json.Unmarshal(data, &got); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if got.ReadAt == nil || !got.ReadAt.Equal(read) {
		t.Errorf("read_at: got %v, want %v", got.ReadAt, read)
	}
}
