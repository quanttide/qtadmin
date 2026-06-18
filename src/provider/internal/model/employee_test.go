package model

import (
	"encoding/json"
	"testing"
)

func TestEmployee(t *testing.T) {
	orig := Employee{
		ID:         "e1",
		Name:       "Alice",
		Department: "D1",
		Position:   "Engineer",
		HireDate:   "2026-01-15",
		Status:     "active",
	}
	data, err := json.Marshal(orig)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	var got Employee
	if err := json.Unmarshal(data, &got); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if got != orig {
		t.Errorf("got %+v, want %+v", got, orig)
	}
}
