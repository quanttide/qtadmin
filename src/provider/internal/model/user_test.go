package model

import (
	"encoding/json"
	"testing"
)

func TestUser(t *testing.T) {
	orig := User{
		ID:           "u1",
		Username:     "alice",
		PasswordHash: "hash123",
		RoleID:       "r1",
		CreatedAt:    "2026-06-01",
	}
	data, err := json.Marshal(orig)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	var got User
	if err := json.Unmarshal(data, &got); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if got != orig {
		t.Errorf("got %+v, want %+v", got, orig)
	}
}
