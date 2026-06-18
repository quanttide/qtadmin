package model

import (
	"encoding/json"
	"testing"
)

func TestPositionRule(t *testing.T) {
	orig := PositionRule{
		ID:       "r1",
		Name:     "全栈工程师",
		Keywords: []string{"全栈", "后端"},
		Exclude:  []string{"实习"},
		Priority: 10,
	}
	data, err := json.Marshal(orig)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	var got PositionRule
	if err := json.Unmarshal(data, &got); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if got.Name != orig.Name {
		t.Errorf("name: got %q, want %q", got.Name, orig.Name)
	}
	if len(got.Keywords) != 2 {
		t.Errorf("keywords len: got %d, want 2", len(got.Keywords))
	}
	if got.Priority != 10 {
		t.Errorf("priority: got %d, want 10", got.Priority)
	}
}

func TestPositionRuleDefaultPriority(t *testing.T) {
	data := []byte(`{"name":"Test","keywords":["a"]}`)
	var rule PositionRule
	if err := json.Unmarshal(data, &rule); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if rule.Priority != 0 {
		t.Errorf("default priority: got %d, want 0", rule.Priority)
	}
}
