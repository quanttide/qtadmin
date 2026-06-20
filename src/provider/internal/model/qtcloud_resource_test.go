package model

import (
	"encoding/json"
	"testing"
)

func TestQtCloudResource(t *testing.T) {
	orig := QtCloudResource{
		ID:        "r1",
		Name:      "VM-01",
		Type:      "ecs",
		Status:    "running",
		Region:    "cn-east",
		CreatedAt: "2026-06-01",
	}
	data, err := json.Marshal(orig)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	var got QtCloudResource
	if err := json.Unmarshal(data, &got); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if got != orig {
		t.Errorf("got %+v, want %+v", got, orig)
	}
}
