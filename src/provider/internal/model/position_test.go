package model

import (
	"encoding/json"
	"testing"
)

func TestPosition(t *testing.T) {
	orig := Position{
		ID:          "p1",
		Name:        "Engineer",
		Department:  "D1",
		Description: "Develops software",
	}
	data, err := json.Marshal(orig)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	var got Position
	if err := json.Unmarshal(data, &got); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if got != orig {
		t.Errorf("got %+v, want %+v", got, orig)
	}
}
