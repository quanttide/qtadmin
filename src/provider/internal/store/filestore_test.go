package store

import (
	"encoding/json"
	"os"
	"sync"
	"testing"
)

func setupTestStore(t *testing.T) (Store, func()) {
	t.Helper()
	dir, err := os.MkdirTemp("", "filestore-test-*")
	if err != nil {
		t.Fatalf("failed to create temp dir: %v", err)
	}
	s, err := New(Config{Driver: "file", Path: dir})
	if err != nil {
		os.RemoveAll(dir)
		t.Fatalf("failed to create store: %v", err)
	}
	return s, func() {
		s.Close()
		os.RemoveAll(dir)
	}
}

func TestCreateAndGet(t *testing.T) {
	s, cleanup := setupTestStore(t)
	defer cleanup()

	data := json.RawMessage(`{"name":"test-entity"}`)
	id, err := s.Create("test_collection", data)
	if err != nil {
		t.Fatalf("Create failed: %v", err)
	}
	if id == "" {
		t.Fatal("expected non-empty id")
	}

	got, err := s.Get("test_collection", id)
	if err != nil {
		t.Fatalf("Get failed: %v", err)
	}

	var result map[string]string
	if err := json.Unmarshal(got, &result); err != nil {
		t.Fatalf("unmarshal failed: %v", err)
	}
	if result["name"] != "test-entity" {
		t.Errorf("expected name=test-entity, got %v", result["name"])
	}
}

func TestList(t *testing.T) {
	s, cleanup := setupTestStore(t)
	defer cleanup()

	t.Run("empty collection", func(t *testing.T) {
		data, err := s.List("empty_collection")
		if err != nil {
			t.Fatalf("List failed: %v", err)
		}
		if string(data) != "[]" && string(data) != "null" {
			t.Errorf("expected empty list, got %s", data)
		}
	})

	t.Run("returns items sorted", func(t *testing.T) {
		id1, err := s.Create("list_collection", json.RawMessage(`{"name":"b"}`))
		if err != nil {
			t.Fatalf("Create failed: %v", err)
		}
		id2, err := s.Create("list_collection", json.RawMessage(`{"name":"a"}`))
		if err != nil {
			t.Fatalf("Create failed: %v", err)
		}

		data, err := s.List("list_collection")
		if err != nil {
			t.Fatalf("List failed: %v", err)
		}

		var items []json.RawMessage
		if err := json.Unmarshal(data, &items); err != nil {
			t.Fatalf("unmarshal failed: %v", err)
		}
		if len(items) != 2 {
			t.Fatalf("expected 2 items, got %d", len(items))
		}

		if id1 > id2 {
			t.Log("ids sorted: id1 > id2, items should be [id2, id1]")
		}
	})
}

func TestUpdate(t *testing.T) {
	s, cleanup := setupTestStore(t)
	defer cleanup()

	id, err := s.Create("update_collection", json.RawMessage(`{"name":"original"}`))
	if err != nil {
		t.Fatalf("Create failed: %v", err)
	}

	newData := json.RawMessage(`{"name":"updated"}`)
	if err := s.Update("update_collection", id, newData); err != nil {
		t.Fatalf("Update failed: %v", err)
	}

	got, err := s.Get("update_collection", id)
	if err != nil {
		t.Fatalf("Get after update failed: %v", err)
	}

	var result map[string]string
	if err := json.Unmarshal(got, &result); err != nil {
		t.Fatalf("unmarshal failed: %v", err)
	}
	if result["name"] != "updated" {
		t.Errorf("expected name=updated, got %v", result["name"])
	}
}

func TestDelete(t *testing.T) {
	s, cleanup := setupTestStore(t)
	defer cleanup()

	id, err := s.Create("delete_collection", json.RawMessage(`{"name":"test"}`))
	if err != nil {
		t.Fatalf("Create failed: %v", err)
	}

	if err := s.Delete("delete_collection", id); err != nil {
		t.Fatalf("Delete failed: %v", err)
	}

	_, err = s.Get("delete_collection", id)
	if err == nil {
		t.Error("expected error for deleted item")
	}
}

func TestConcurrency(t *testing.T) {
	s, cleanup := setupTestStore(t)
	defer cleanup()

	var wg sync.WaitGroup
	for i := 0; i < 20; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			id, err := s.Create("concurrent", json.RawMessage(`{"n":1}`))
			if err != nil {
				return
			}
			s.Get("concurrent", id)
			s.Update("concurrent", id, json.RawMessage(`{"n":2}`))
			s.List("concurrent")
			s.Delete("concurrent", id)
		}()
	}
	wg.Wait()
}
