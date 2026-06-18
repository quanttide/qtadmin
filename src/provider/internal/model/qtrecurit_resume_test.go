package model

import (
	"encoding/json"
	"testing"
)

func TestQtRecuritResume(t *testing.T) {
	orig := QtRecuritResume{
		ID:            "rev1",
		CandidateName: "Charlie",
		Position:      "Developer",
		Stage:         "interview",
		Feedback:      "Strong hire",
		CreatedAt:     "2026-06-01",
	}
	data, err := json.Marshal(orig)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	var got QtRecuritResume
	if err := json.Unmarshal(data, &got); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if got != orig {
		t.Errorf("got %+v, want %+v", got, orig)
	}
}

func TestQtRecuritInterview(t *testing.T) {
	orig := QtRecuritInterview{
		ID:          "iv1",
		ResumeID:    "rev1",
		Candidate:   "Charlie",
		Interviewer: "Alice",
		Time:        "2026-06-20T10:00:00Z",
		Feedback:    "Good",
		CreatedAt:   "2026-06-01",
	}
	data, err := json.Marshal(orig)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	var got QtRecuritInterview
	if err := json.Unmarshal(data, &got); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if got != orig {
		t.Errorf("got %+v, want %+v", got, orig)
	}
}
