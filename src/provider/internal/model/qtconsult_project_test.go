package model

import (
	"encoding/json"
	"testing"
)

func TestQtConsultProject(t *testing.T) {
	orig := QtConsultProject{
		ID:        "pr1",
		Name:      "Project Alpha",
		Stage:     "planning",
		Client:    "Client X",
		Status:    "active",
		CreatedAt: "2026-06-01",
	}
	data, err := json.Marshal(orig)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	var got QtConsultProject
	if err := json.Unmarshal(data, &got); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if got != orig {
		t.Errorf("got %+v, want %+v", got, orig)
	}
}
