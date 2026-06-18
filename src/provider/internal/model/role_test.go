package model

import (
	"encoding/json"
	"testing"
)

func TestRole(t *testing.T) {
	orig := Role{
		ID:          "r1",
		Name:        "Admin",
		Permissions: []string{"read", "write", "delete"},
	}
	data, err := json.Marshal(orig)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	var got Role
	if err := json.Unmarshal(data, &got); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if got.ID != orig.ID || got.Name != orig.Name {
		t.Errorf("field mismatch: got %+v, want %+v", got, orig)
	}
	if len(got.Permissions) != len(orig.Permissions) {
		t.Errorf("permissions length: got %d, want %d", len(got.Permissions), len(orig.Permissions))
	}
	for i := range got.Permissions {
		if got.Permissions[i] != orig.Permissions[i] {
			t.Errorf("permissions[%d]: got %s, want %s", i, got.Permissions[i], orig.Permissions[i])
		}
	}
}
