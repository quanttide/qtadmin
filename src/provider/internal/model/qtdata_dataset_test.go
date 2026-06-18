package model

import (
	"encoding/json"
	"testing"
)

func TestQtDataDataset(t *testing.T) {
	orig := QtDataDataset{
		ID:          "ds1",
		Name:        "Sales Data",
		Description: "Q1 sales figures",
		Version:     "1.0",
		Status:      "ready",
		CreatedAt:   "2026-06-01",
	}
	data, err := json.Marshal(orig)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	var got QtDataDataset
	if err := json.Unmarshal(data, &got); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if got != orig {
		t.Errorf("got %+v, want %+v", got, orig)
	}
}
