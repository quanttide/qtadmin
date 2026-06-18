package api

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func registerBusinessRoutes(h *BusinessHandler) *http.ServeMux {
	mux := http.NewServeMux()
	// qtconsult
	mux.HandleFunc("GET /api/v1/qtconsult/projects", h.ListProjects)
	mux.HandleFunc("POST /api/v1/qtconsult/projects", h.CreateProject)
	mux.HandleFunc("GET /api/v1/qtconsult/projects/{id}", h.GetProject)
	mux.HandleFunc("PUT /api/v1/qtconsult/projects/{id}", h.UpdateProject)
	mux.HandleFunc("DELETE /api/v1/qtconsult/projects/{id}", h.DeleteProject)
	mux.HandleFunc("PUT /api/v1/qtconsult/projects/{id}/stage", h.UpdateProjectStage)
	// qtclass
	mux.HandleFunc("GET /api/v1/qtclass/courses", h.ListCourses)
	mux.HandleFunc("POST /api/v1/qtclass/courses", h.CreateCourse)
	mux.HandleFunc("GET /api/v1/qtclass/courses/{id}", h.GetCourse)
	mux.HandleFunc("PUT /api/v1/qtclass/courses/{id}", h.UpdateCourse)
	mux.HandleFunc("DELETE /api/v1/qtclass/courses/{id}", h.DeleteCourse)
	mux.HandleFunc("GET /api/v1/qtclass/schedules", h.ListSchedules)
	mux.HandleFunc("POST /api/v1/qtclass/enrollments", h.CreateEnrollment)
	// qtcloud
	mux.HandleFunc("GET /api/v1/qtcloud/resources", h.ListResources)
	mux.HandleFunc("POST /api/v1/qtcloud/resources", h.CreateResource)
	mux.HandleFunc("GET /api/v1/qtcloud/resources/{id}", h.GetResource)
	mux.HandleFunc("PUT /api/v1/qtcloud/resources/{id}", h.UpdateResource)
	mux.HandleFunc("DELETE /api/v1/qtcloud/resources/{id}", h.DeleteResource)
	mux.HandleFunc("PUT /api/v1/qtcloud/resources/{id}/status", h.UpdateResourceStatus)
	// qtdata
	mux.HandleFunc("GET /api/v1/qtdata/datasets", h.ListDatasets)
	mux.HandleFunc("POST /api/v1/qtdata/datasets", h.CreateDataset)
	mux.HandleFunc("GET /api/v1/qtdata/datasets/{id}", h.GetDataset)
	mux.HandleFunc("PUT /api/v1/qtdata/datasets/{id}", h.UpdateDataset)
	mux.HandleFunc("DELETE /api/v1/qtdata/datasets/{id}", h.DeleteDataset)
	// qtrecurit
	mux.HandleFunc("POST /api/v1/qtrecurit/resumes", h.ImportResume)
	mux.HandleFunc("PUT /api/v1/qtrecurit/resumes/{id}/stage", h.UpdateResumeStage)
	mux.HandleFunc("POST /api/v1/qtrecurit/interviews", h.CreateInterview)
	mux.HandleFunc("POST /api/v1/qtrecurit/interviews/{id}/feedback", h.UpdateInterviewFeedback)
	return mux
}

func TestProjectCRUD(t *testing.T) {
	s, cleanup := testSetup(t)
	defer cleanup()

	h := NewBusinessHandler(s)
	mux := registerBusinessRoutes(h)
	base := "/api/v1/qtconsult/projects"

	t.Run("Create and Get", func(t *testing.T) {
		body := `{"name":"Project Alpha","client":"Client X","stage":"init","status":"active"}`
		req := httptest.NewRequest("POST", base, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusCreated {
			t.Fatalf("expected 201, got %d: %s", rec.Code, rec.Body.String())
		}

		var item map[string]any
		json.Unmarshal(rec.Body.Bytes(), &item)
		id := item["id"].(string)

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
		body := `{"name":"Project Alpha","client":"Client X","stage":"init","status":"active"}`
		req := httptest.NewRequest("POST", base, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		var item map[string]any
		json.Unmarshal(rec.Body.Bytes(), &item)
		id := item["id"].(string)

		updateBody := `{"name":"Project Alpha Updated","client":"Client X","stage":"planning","status":"active"}`
		req = httptest.NewRequest("PUT", base+"/"+id, strings.NewReader(updateBody))
		req.Header.Set("Content-Type", "application/json")
		rec = httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusOK {
			t.Fatalf("expected 200, got %d: %s", rec.Code, rec.Body.String())
		}

		var updated map[string]any
		json.Unmarshal(rec.Body.Bytes(), &updated)
		if updated["name"] != "Project Alpha Updated" {
			t.Errorf("expected updated name, got %v", updated["name"])
		}
	})

	t.Run("Delete", func(t *testing.T) {
		body := `{"name":"Temp Project"}`
		req := httptest.NewRequest("POST", base, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		var item map[string]any
		json.Unmarshal(rec.Body.Bytes(), &item)
		id := item["id"].(string)

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

func TestProjectStageTransition(t *testing.T) {
	s, cleanup := testSetup(t)
	defer cleanup()

	h := NewBusinessHandler(s)
	mux := registerBusinessRoutes(h)
	base := "/api/v1/qtconsult/projects"

	body := `{"name":"Project Beta","stage":"init"}`
	req := httptest.NewRequest("POST", base, strings.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, req)

	var item map[string]any
	json.Unmarshal(rec.Body.Bytes(), &item)
	id := item["id"].(string)

	t.Run("Transition to planning", func(t *testing.T) {
		stageBody := `{"stage":"planning"}`
		req := httptest.NewRequest("PUT", base+"/"+id+"/stage", strings.NewReader(stageBody))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusOK {
			t.Fatalf("expected 200, got %d: %s", rec.Code, rec.Body.String())
		}

		var updated map[string]any
		json.Unmarshal(rec.Body.Bytes(), &updated)
		if updated["stage"] != "planning" {
			t.Errorf("expected stage=planning, got %v", updated["stage"])
		}
	})
}

func TestCourseCRUD(t *testing.T) {
	s, cleanup := testSetup(t)
	defer cleanup()

	h := NewBusinessHandler(s)
	mux := registerBusinessRoutes(h)
	base := "/api/v1/qtclass/courses"

	t.Run("Create and Get", func(t *testing.T) {
		body := `{"name":"Go 101","teacher":"Alice","max_students":30,"status":"active"}`
		req := httptest.NewRequest("POST", base, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusCreated {
			t.Fatalf("expected 201, got %d", rec.Code)
		}

		var item map[string]any
		json.Unmarshal(rec.Body.Bytes(), &item)
		id := item["id"].(string)

		req = httptest.NewRequest("GET", base+"/"+id, nil)
		rec = httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusOK {
			t.Fatalf("expected 200, got %d", rec.Code)
		}
	})

	t.Run("Schedules", func(t *testing.T) {
		req := httptest.NewRequest("GET", "/api/v1/qtclass/schedules", nil)
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusOK {
			t.Errorf("expected 200, got %d", rec.Code)
		}
	})

	t.Run("Enrollment", func(t *testing.T) {
		body := `{"course_id":"c1","student":"Bob"}`
		req := httptest.NewRequest("POST", "/api/v1/qtclass/enrollments", strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusCreated {
			t.Errorf("expected 201, got %d", rec.Code)
		}
	})
}

func TestResourceStatusUpdate(t *testing.T) {
	s, cleanup := testSetup(t)
	defer cleanup()

	h := NewBusinessHandler(s)
	mux := registerBusinessRoutes(h)
	base := "/api/v1/qtcloud/resources"

	body := `{"name":"VM-01","type":"ecs","region":"cn-east","status":"running"}`
	req := httptest.NewRequest("POST", base, strings.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, req)

	var item map[string]any
	json.Unmarshal(rec.Body.Bytes(), &item)
	id := item["id"].(string)

	t.Run("Update status to stopped", func(t *testing.T) {
		statusBody := `{"status":"stopped"}`
		req := httptest.NewRequest("PUT", base+"/"+id+"/status", strings.NewReader(statusBody))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusOK {
			t.Fatalf("expected 200, got %d: %s", rec.Code, rec.Body.String())
		}

		var updated map[string]any
		json.Unmarshal(rec.Body.Bytes(), &updated)
		if updated["status"] != "stopped" {
			t.Errorf("expected status=stopped, got %v", updated["status"])
		}
	})
}

func TestDatasetCRUD(t *testing.T) {
	s, cleanup := testSetup(t)
	defer cleanup()

	h := NewBusinessHandler(s)
	mux := registerBusinessRoutes(h)
	base := "/api/v1/qtdata/datasets"

	t.Run("Create and Get", func(t *testing.T) {
		body := `{"name":"Sales Data","description":"Q1 sales figures","version":"1.0","status":"ready"}`
		req := httptest.NewRequest("POST", base, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusCreated {
			t.Fatalf("expected 201, got %d", rec.Code)
		}

		var item map[string]any
		json.Unmarshal(rec.Body.Bytes(), &item)
		id := item["id"].(string)

		req = httptest.NewRequest("GET", base+"/"+id, nil)
		rec = httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusOK {
			t.Fatalf("expected 200, got %d", rec.Code)
		}
	})
}

func TestResumeFlow(t *testing.T) {
	s, cleanup := testSetup(t)
	defer cleanup()

	h := NewBusinessHandler(s)
	mux := registerBusinessRoutes(h)

	var resumeID string

	t.Run("Import resume", func(t *testing.T) {
		body := `{"candidate_name":"Charlie","position":"Developer","stage":"new"}`
		req := httptest.NewRequest("POST", "/api/v1/qtrecurit/resumes", strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusCreated {
			t.Fatalf("expected 201, got %d: %s", rec.Code, rec.Body.String())
		}

		var item map[string]any
		json.Unmarshal(rec.Body.Bytes(), &item)
		if item["candidate_name"] != "Charlie" {
			t.Errorf("expected candidate_name=Charlie, got %v", item["candidate_name"])
		}
		resumeID = item["id"].(string)
	})

	t.Run("Stage transition", func(t *testing.T) {
		stageBody := `{"stage":"interview"}`
		req := httptest.NewRequest("PUT", "/api/v1/qtrecurit/resumes/"+resumeID+"/stage", strings.NewReader(stageBody))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusOK {
			t.Fatalf("expected 200, got %d: %s", rec.Code, rec.Body.String())
		}
	})

	t.Run("Schedule interview", func(t *testing.T) {
		body := `{"candidate":"` + resumeID + `","interviewer":"Alice","date":"2026-06-20"}`
		req := httptest.NewRequest("POST", "/api/v1/qtrecurit/interviews", strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusCreated {
			t.Fatalf("expected 201, got %d: %s", rec.Code, rec.Body.String())
		}

		var interview map[string]any
		json.Unmarshal(rec.Body.Bytes(), &interview)
		interviewID := interview["id"].(string)

		t.Run("Submit feedback", func(t *testing.T) {
			fbBody := `{"feedback":"Strong hire","rating":5}`
			req := httptest.NewRequest("POST", "/api/v1/qtrecurit/interviews/"+interviewID+"/feedback", strings.NewReader(fbBody))
			req.Header.Set("Content-Type", "application/json")
			rec := httptest.NewRecorder()
			mux.ServeHTTP(rec, req)
			if rec.Code != http.StatusOK {
				t.Fatalf("expected 200, got %d: %s", rec.Code, rec.Body.String())
			}
		})
	})
}
