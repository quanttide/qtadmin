package model

import (
	"encoding/json"
	"testing"
)

func TestQtClassCourse(t *testing.T) {
	orig := QtClassCourse{
		ID:          "c1",
		Name:        "Go 101",
		Teacher:     "Alice",
		Schedule:    "Mon 10:00",
		MaxStudents: 30,
		Status:      "active",
	}
	data, err := json.Marshal(orig)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	var got QtClassCourse
	if err := json.Unmarshal(data, &got); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if got != orig {
		t.Errorf("got %+v, want %+v", got, orig)
	}
}
