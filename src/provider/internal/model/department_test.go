package model

import (
	"encoding/json"
	"testing"
)

func TestDepartment(t *testing.T) {
	orig := Department{
		ID:     "d1",
		Name:   "Engineering",
		Parent: "d0",
		Leader: "e1",
	}
	data, err := json.Marshal(orig)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	var got Department
	if err := json.Unmarshal(data, &got); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if got != orig {
		t.Errorf("got %+v, want %+v", got, orig)
	}
}
