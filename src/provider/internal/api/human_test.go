package api

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"

	"github.com/quanttide/qtadmin-provider/internal/store"
)

func testSetup(t *testing.T) (store.Store, func()) {
	t.Helper()
	dir, err := os.MkdirTemp("", "api-test-*")
	if err != nil {
		t.Fatalf("failed to create temp dir: %v", err)
	}
	s, err := store.New(store.Config{Driver: "file", Path: dir})
	if err != nil {
		os.RemoveAll(dir)
		t.Fatalf("failed to create store: %v", err)
	}
	return s, func() {
		s.Close()
		os.RemoveAll(dir)
	}
}

func registerHumanRoutes(h *HumanHandler) *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /api/v1/employees", h.ListEmployees)
	mux.HandleFunc("POST /api/v1/employees", h.CreateEmployee)
	mux.HandleFunc("GET /api/v1/employees/{id}", h.GetEmployee)
	mux.HandleFunc("PUT /api/v1/employees/{id}", h.UpdateEmployee)
	mux.HandleFunc("DELETE /api/v1/employees/{id}", h.DeleteEmployee)
	mux.HandleFunc("GET /api/v1/departments", h.ListDepartments)
	mux.HandleFunc("POST /api/v1/departments", h.CreateDepartment)
	mux.HandleFunc("GET /api/v1/departments/{id}", h.GetDepartment)
	mux.HandleFunc("PUT /api/v1/departments/{id}", h.UpdateDepartment)
	mux.HandleFunc("DELETE /api/v1/departments/{id}", h.DeleteDepartment)
	mux.HandleFunc("GET /api/v1/positions", h.ListPositions)
	mux.HandleFunc("POST /api/v1/positions", h.CreatePosition)
	mux.HandleFunc("GET /api/v1/positions/{id}", h.GetPosition)
	mux.HandleFunc("PUT /api/v1/positions/{id}", h.UpdatePosition)
	mux.HandleFunc("DELETE /api/v1/positions/{id}", h.DeletePosition)
	return mux
}

func TestHealth(t *testing.T) {
	req := httptest.NewRequest("GET", "/health", nil)
	rec := httptest.NewRecorder()
	Health(rec, req)

	if rec.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", rec.Code)
	}

	var body map[string]string
	if err := json.Unmarshal(rec.Body.Bytes(), &body); err != nil {
		t.Fatalf("unmarshal failed: %v", err)
	}
	if body["status"] != "ok" {
		t.Errorf("expected status=ok, got %v", body["status"])
	}
}

func TestEmployeeCRUD(t *testing.T) {
	s, cleanup := testSetup(t)
	defer cleanup()

	h := NewHumanHandler(s)
	mux := registerHumanRoutes(h)
	base := "/api/v1/employees"

	t.Run("Create", func(t *testing.T) {
		body := `{"name":"Alice","department":"Engineering","position":"Developer","hire_date":"2024-01-15","status":"active"}`
		req := httptest.NewRequest("POST", base, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusCreated {
			t.Fatalf("expected 201, got %d: %s", rec.Code, rec.Body.String())
		}

		var emp map[string]any
		if err := json.Unmarshal(rec.Body.Bytes(), &emp); err != nil {
			t.Fatalf("unmarshal failed: %v", err)
		}
		if emp["id"] == "" {
			t.Error("expected non-empty id")
		}
		if emp["name"] != "Alice" {
			t.Errorf("expected name=Alice, got %v", emp["name"])
		}

		t.Run("Get", func(t *testing.T) {
			id := emp["id"].(string)
			req := httptest.NewRequest("GET", base+"/"+id, nil)
			rec := httptest.NewRecorder()
			mux.ServeHTTP(rec, req)

			if rec.Code != http.StatusOK {
				t.Fatalf("expected 200, got %d: %s", rec.Code, rec.Body.String())
			}

			var got map[string]any
			json.Unmarshal(rec.Body.Bytes(), &got)
			if got["id"] != id {
				t.Errorf("expected id=%s, got %v", id, got["id"])
			}
		})

		t.Run("List", func(t *testing.T) {
			req := httptest.NewRequest("GET", base, nil)
			rec := httptest.NewRecorder()
			mux.ServeHTTP(rec, req)

			if rec.Code != http.StatusOK {
				t.Fatalf("expected 200, got %d", rec.Code)
			}

			var items []any
			json.Unmarshal(rec.Body.Bytes(), &items)
			if len(items) < 1 {
				t.Error("expected at least 1 employee")
			}
		})

		t.Run("Update", func(t *testing.T) {
			id := emp["id"].(string)
			updateBody := `{"name":"Alice Updated","department":"Engineering","position":"Senior Developer","hire_date":"2024-01-15","status":"active"}`
			req := httptest.NewRequest("PUT", base+"/"+id, strings.NewReader(updateBody))
			req.Header.Set("Content-Type", "application/json")
			rec := httptest.NewRecorder()
			mux.ServeHTTP(rec, req)

			if rec.Code != http.StatusOK {
				t.Fatalf("expected 200, got %d: %s", rec.Code, rec.Body.String())
			}

			var updated map[string]any
			json.Unmarshal(rec.Body.Bytes(), &updated)
			if updated["name"] != "Alice Updated" {
				t.Errorf("expected name=Alice Updated, got %v", updated["name"])
			}
		})

		t.Run("Delete", func(t *testing.T) {
			id := emp["id"].(string)
			req := httptest.NewRequest("DELETE", base+"/"+id, nil)
			rec := httptest.NewRecorder()
			mux.ServeHTTP(rec, req)

			if rec.Code != http.StatusNoContent {
				t.Fatalf("expected 204, got %d", rec.Code)
			}

			req = httptest.NewRequest("GET", base+"/"+id, nil)
			rec = httptest.NewRecorder()
			mux.ServeHTTP(rec, req)
			if rec.Code != http.StatusNotFound {
				t.Errorf("expected 404 after delete, got %d", rec.Code)
			}
		})
	})
}

func TestEmployeeValidation(t *testing.T) {
	s, cleanup := testSetup(t)
	defer cleanup()

	h := NewHumanHandler(s)
	mux := registerHumanRoutes(h)
	base := "/api/v1/employees"

	t.Run("missing name returns 400", func(t *testing.T) {
		body := `{"department":"Engineering"}`
		req := httptest.NewRequest("POST", base, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusBadRequest {
			t.Fatalf("expected 400, got %d: %s", rec.Code, rec.Body.String())
		}

		var errResp ErrorResponse
		json.Unmarshal(rec.Body.Bytes(), &errResp)
		if errResp.Error.Code != "VALIDATION_ERROR" {
			t.Errorf("expected VALIDATION_ERROR, got %s", errResp.Error.Code)
		}
	})

	t.Run("invalid json returns 400", func(t *testing.T) {
		req := httptest.NewRequest("POST", base, strings.NewReader("not json"))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusBadRequest {
			t.Errorf("expected 400, got %d", rec.Code)
		}
	})
}

func TestDepartmentCRUD(t *testing.T) {
	s, cleanup := testSetup(t)
	defer cleanup()

	h := NewHumanHandler(s)
	mux := registerHumanRoutes(h)
	base := "/api/v1/departments"

	t.Run("Create and Get", func(t *testing.T) {
		body := `{"name":"Engineering","leader":"Alice"}`
		req := httptest.NewRequest("POST", base, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusCreated {
			t.Fatalf("expected 201, got %d: %s", rec.Code, rec.Body.String())
		}

		var dept map[string]any
		json.Unmarshal(rec.Body.Bytes(), &dept)
		id := dept["id"].(string)

		req = httptest.NewRequest("GET", base+"/"+id, nil)
		rec = httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusOK {
			t.Fatalf("expected 200, got %d", rec.Code)
		}
	})

	t.Run("List", func(t *testing.T) {
		req := httptest.NewRequest("GET", base, nil)
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusOK {
			t.Errorf("expected 200, got %d", rec.Code)
		}
	})

	t.Run("Update", func(t *testing.T) {
		body := `{"name":"Engineering","leader":"Alice"}`
		req := httptest.NewRequest("POST", base, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		var dept map[string]any
		json.Unmarshal(rec.Body.Bytes(), &dept)
		id := dept["id"].(string)

		updateBody := `{"name":"Engineering Dept","leader":"Bob"}`
		req = httptest.NewRequest("PUT", base+"/"+id, strings.NewReader(updateBody))
		req.Header.Set("Content-Type", "application/json")
		rec = httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusOK {
			t.Fatalf("expected 200, got %d: %s", rec.Code, rec.Body.String())
		}

		var updated map[string]any
		json.Unmarshal(rec.Body.Bytes(), &updated)
		if updated["name"] != "Engineering Dept" {
			t.Errorf("expected name=Engineering Dept, got %v", updated["name"])
		}
	})

	t.Run("Delete", func(t *testing.T) {
		body := `{"name":"DeleteMe"}`
		req := httptest.NewRequest("POST", base, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		var dept map[string]any
		json.Unmarshal(rec.Body.Bytes(), &dept)
		id := dept["id"].(string)

		req = httptest.NewRequest("DELETE", base+"/"+id, nil)
		rec = httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusNoContent {
			t.Errorf("expected 204, got %d", rec.Code)
		}
	})

	t.Run("missing name returns 400", func(t *testing.T) {
		req := httptest.NewRequest("POST", base, strings.NewReader(`{}`))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusBadRequest {
			t.Errorf("expected 400, got %d", rec.Code)
		}
	})
}

func TestPositionCRUD(t *testing.T) {
	s, cleanup := testSetup(t)
	defer cleanup()

	h := NewHumanHandler(s)
	mux := registerHumanRoutes(h)
	base := "/api/v1/positions"

	t.Run("Create and Get", func(t *testing.T) {
		body := `{"name":"Developer","department":"Engineering","description":"Writes code"}`
		req := httptest.NewRequest("POST", base, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusCreated {
			t.Fatalf("expected 201, got %d: %s", rec.Code, rec.Body.String())
		}

		var pos map[string]any
		json.Unmarshal(rec.Body.Bytes(), &pos)
		id := pos["id"].(string)

		req = httptest.NewRequest("GET", base+"/"+id, nil)
		rec = httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusOK {
			t.Fatalf("expected 200, got %d", rec.Code)
		}
	})

	t.Run("List", func(t *testing.T) {
		req := httptest.NewRequest("GET", base, nil)
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusOK {
			t.Errorf("expected 200, got %d", rec.Code)
		}
	})

	t.Run("Update", func(t *testing.T) {
		body := `{"name":"Developer","department":"Engineering","description":"Writes code"}`
		req := httptest.NewRequest("POST", base, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		var pos map[string]any
		json.Unmarshal(rec.Body.Bytes(), &pos)
		id := pos["id"].(string)

		updateBody := `{"name":"Senior Developer","description":"Writes more code"}`
		req = httptest.NewRequest("PUT", base+"/"+id, strings.NewReader(updateBody))
		req.Header.Set("Content-Type", "application/json")
		rec = httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusOK {
			t.Fatalf("expected 200, got %d: %s", rec.Code, rec.Body.String())
		}
	})

	t.Run("Delete", func(t *testing.T) {
		body := `{"name":"Temp Position"}`
		req := httptest.NewRequest("POST", base, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		var pos map[string]any
		json.Unmarshal(rec.Body.Bytes(), &pos)
		id := pos["id"].(string)

		req = httptest.NewRequest("DELETE", base+"/"+id, nil)
		rec = httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusNoContent {
			t.Errorf("expected 204, got %d", rec.Code)
		}
	})

	t.Run("missing name returns 400", func(t *testing.T) {
		req := httptest.NewRequest("POST", base, strings.NewReader(`{}`))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusBadRequest {
			t.Errorf("expected 400, got %d", rec.Code)
		}
	})
}
