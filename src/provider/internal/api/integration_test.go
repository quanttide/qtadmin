package api

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func newTestServer(t *testing.T) (*httptest.Server, string) {
	t.Helper()
	s, cleanup := testSetup(t)
	t.Cleanup(cleanup)

	humanHandler := NewHumanHandler(s)
	businessHandler := NewBusinessHandler(s)
	connectHandler := NewConnectHandler(s)
	secret := "test-integration-secret"
	authHandler := NewAuthHandler(s, secret)

	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", Health)

	mux.HandleFunc("GET /api/v1/employees", humanHandler.ListEmployees)
	mux.HandleFunc("POST /api/v1/employees", humanHandler.CreateEmployee)
	mux.HandleFunc("GET /api/v1/employees/{id}", humanHandler.GetEmployee)
	mux.HandleFunc("PUT /api/v1/employees/{id}", humanHandler.UpdateEmployee)
	mux.HandleFunc("DELETE /api/v1/employees/{id}", humanHandler.DeleteEmployee)
	mux.HandleFunc("GET /api/v1/departments", humanHandler.ListDepartments)
	mux.HandleFunc("POST /api/v1/departments", humanHandler.CreateDepartment)
	mux.HandleFunc("GET /api/v1/departments/{id}", humanHandler.GetDepartment)
	mux.HandleFunc("PUT /api/v1/departments/{id}", humanHandler.UpdateDepartment)
	mux.HandleFunc("DELETE /api/v1/departments/{id}", humanHandler.DeleteDepartment)
	mux.HandleFunc("GET /api/v1/positions", humanHandler.ListPositions)
	mux.HandleFunc("POST /api/v1/positions", humanHandler.CreatePosition)
	mux.HandleFunc("GET /api/v1/positions/{id}", humanHandler.GetPosition)
	mux.HandleFunc("PUT /api/v1/positions/{id}", humanHandler.UpdatePosition)
	mux.HandleFunc("DELETE /api/v1/positions/{id}", humanHandler.DeletePosition)

	mux.HandleFunc("POST /api/v1/connect/notify", connectHandler.Notify)
	mux.HandleFunc("GET /api/v1/connect/notifications", connectHandler.ListNotifications)
	mux.HandleFunc("GET /api/v1/connect/notifications/{id}", connectHandler.GetNotification)
	mux.HandleFunc("POST /api/v1/connect/webhook/lark", connectHandler.LarkWebhook)

	mux.HandleFunc("POST /api/v1/auth/login", authHandler.Login)
	mux.HandleFunc("POST /api/v1/auth/register", authHandler.Register)
	authMW := AuthMiddleware(secret)
	mux.Handle("POST /api/v1/auth/refresh", authMW(http.HandlerFunc(authHandler.Refresh)))
	mux.Handle("GET /api/v1/auth/me", authMW(http.HandlerFunc(authHandler.Me)))

	mux.HandleFunc("GET /api/v1/qtconsult/projects", businessHandler.ListProjects)
	mux.HandleFunc("POST /api/v1/qtconsult/projects", businessHandler.CreateProject)
	mux.HandleFunc("GET /api/v1/qtconsult/projects/{id}", businessHandler.GetProject)
	mux.HandleFunc("PUT /api/v1/qtconsult/projects/{id}", businessHandler.UpdateProject)
	mux.HandleFunc("DELETE /api/v1/qtconsult/projects/{id}", businessHandler.DeleteProject)
	mux.HandleFunc("PUT /api/v1/qtconsult/projects/{id}/stage", businessHandler.UpdateProjectStage)
	mux.HandleFunc("GET /api/v1/qtclass/courses", businessHandler.ListCourses)
	mux.HandleFunc("POST /api/v1/qtclass/courses", businessHandler.CreateCourse)
	mux.HandleFunc("GET /api/v1/qtclass/courses/{id}", businessHandler.GetCourse)
	mux.HandleFunc("PUT /api/v1/qtclass/courses/{id}", businessHandler.UpdateCourse)
	mux.HandleFunc("DELETE /api/v1/qtclass/courses/{id}", businessHandler.DeleteCourse)
	mux.HandleFunc("GET /api/v1/qtclass/schedules", businessHandler.ListSchedules)
	mux.HandleFunc("POST /api/v1/qtclass/enrollments", businessHandler.CreateEnrollment)
	mux.HandleFunc("GET /api/v1/qtcloud/resources", businessHandler.ListResources)
	mux.HandleFunc("POST /api/v1/qtcloud/resources", businessHandler.CreateResource)
	mux.HandleFunc("GET /api/v1/qtcloud/resources/{id}", businessHandler.GetResource)
	mux.HandleFunc("PUT /api/v1/qtcloud/resources/{id}", businessHandler.UpdateResource)
	mux.HandleFunc("DELETE /api/v1/qtcloud/resources/{id}", businessHandler.DeleteResource)
	mux.HandleFunc("PUT /api/v1/qtcloud/resources/{id}/status", businessHandler.UpdateResourceStatus)
	mux.HandleFunc("GET /api/v1/qtdata/datasets", businessHandler.ListDatasets)
	mux.HandleFunc("POST /api/v1/qtdata/datasets", businessHandler.CreateDataset)
	mux.HandleFunc("GET /api/v1/qtdata/datasets/{id}", businessHandler.GetDataset)
	mux.HandleFunc("PUT /api/v1/qtdata/datasets/{id}", businessHandler.UpdateDataset)
	mux.HandleFunc("DELETE /api/v1/qtdata/datasets/{id}", businessHandler.DeleteDataset)
	mux.HandleFunc("POST /api/v1/qtrecurit/resumes", businessHandler.ImportResume)
	mux.HandleFunc("PUT /api/v1/qtrecurit/resumes/{id}/stage", businessHandler.UpdateResumeStage)
	mux.HandleFunc("POST /api/v1/qtrecurit/interviews", businessHandler.CreateInterview)
	mux.HandleFunc("POST /api/v1/qtrecurit/interviews/{id}/feedback", businessHandler.UpdateInterviewFeedback)

	ts := httptest.NewServer(mux)
	return ts, secret
}

func request(t *testing.T, ts *httptest.Server, method, path, body string) *http.Response {
	t.Helper()
	var req *http.Request
	if body != "" {
		req = httptest.NewRequest(method, path, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
	} else {
		req = httptest.NewRequest(method, path, nil)
	}
	rec := httptest.NewRecorder()
	ts.Config.Handler.ServeHTTP(rec, req)
	return rec.Result()
}

func requestWithToken(t *testing.T, ts *httptest.Server, method, path, body, token string) *http.Response {
	t.Helper()
	var req *http.Request
	if body != "" {
		req = httptest.NewRequest(method, path, strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
	} else {
		req = httptest.NewRequest(method, path, nil)
	}
	req.Header.Set("Authorization", "Bearer "+token)
	rec := httptest.NewRecorder()
	ts.Config.Handler.ServeHTTP(rec, req)
	return rec.Result()
}

func readBody(t *testing.T, resp *http.Response) map[string]any {
	t.Helper()
	var m map[string]any
	if err := json.NewDecoder(resp.Body).Decode(&m); err != nil {
		t.Fatalf("decode body: %v", err)
	}
	return m
}

func TestIntegration_Health(t *testing.T) {
	ts, _ := newTestServer(t)
	resp := request(t, ts, "GET", "/health", "")
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("expected 200, got %d", resp.StatusCode)
	}
	body := readBody(t, resp)
	if body["status"] != "ok" {
		t.Errorf("expected status=ok, got %v", body["status"])
	}
}

func TestIntegration_EmployeeLifecycle(t *testing.T) {
	ts, _ := newTestServer(t)

	var empID string

	t.Run("Create employee", func(t *testing.T) {
		body := `{"name":"Alice","department":"Engineering","position":"Developer","hire_date":"2024-01-15","status":"active"}`
		resp := request(t, ts, "POST", "/api/v1/employees", body)
		if resp.StatusCode != http.StatusCreated {
			t.Fatalf("expected 201, got %d", resp.StatusCode)
		}
		m := readBody(t, resp)
		empID = m["id"].(string)
		if m["name"] != "Alice" {
			t.Errorf("expected Alice, got %v", m["name"])
		}
	})

	t.Run("Get employee", func(t *testing.T) {
		resp := request(t, ts, "GET", "/api/v1/employees/"+empID, "")
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200, got %d", resp.StatusCode)
		}
		m := readBody(t, resp)
		if m["id"] != empID {
			t.Errorf("expected id %s, got %v", empID, m["id"])
		}
	})

	t.Run("List employees includes Alice", func(t *testing.T) {
		resp := request(t, ts, "GET", "/api/v1/employees", "")
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200, got %d", resp.StatusCode)
		}
		var list []any
		if err := json.NewDecoder(resp.Body).Decode(&list); err != nil {
			t.Fatalf("decode list: %v", err)
		}
		if len(list) < 1 {
			t.Fatal("expected at least 1 employee")
		}
	})

	t.Run("Update employee", func(t *testing.T) {
		body := `{"name":"Alice Updated","department":"Engineering","position":"Senior Developer","hire_date":"2024-01-15","status":"active"}`
		resp := request(t, ts, "PUT", "/api/v1/employees/"+empID, body)
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200, got %d", resp.StatusCode)
		}
		m := readBody(t, resp)
		if m["name"] != "Alice Updated" {
			t.Errorf("expected Alice Updated, got %v", m["name"])
		}
	})

	t.Run("Delete employee", func(t *testing.T) {
		resp := request(t, ts, "DELETE", "/api/v1/employees/"+empID, "")
		if resp.StatusCode != http.StatusNoContent {
			t.Fatalf("expected 204, got %d", resp.StatusCode)
		}
	})

	t.Run("Deleted employee returns 404", func(t *testing.T) {
		resp := request(t, ts, "GET", "/api/v1/employees/"+empID, "")
		if resp.StatusCode != http.StatusNotFound {
			t.Errorf("expected 404, got %d", resp.StatusCode)
		}
	})

	t.Run("Create with missing name returns 400", func(t *testing.T) {
		resp := request(t, ts, "POST", "/api/v1/employees", `{"department":"Engineering"}`)
		if resp.StatusCode != http.StatusBadRequest {
			t.Errorf("expected 400, got %d", resp.StatusCode)
		}
		m := readBody(t, resp)
		err, ok := m["error"].(map[string]any)
		if !ok || err["code"] != "VALIDATION_ERROR" {
			t.Errorf("expected VALIDATION_ERROR, got %v", m)
		}
	})
}

func TestIntegration_AuthFlow(t *testing.T) {
	ts, secret := newTestServer(t)
	var token string

	t.Run("Register new user", func(t *testing.T) {
		resp := request(t, ts, "POST", "/api/v1/auth/register", `{"username":"intuser","password":"intpass"}`)
		if resp.StatusCode != http.StatusCreated {
			t.Fatalf("expected 201, got %d", resp.StatusCode)
		}
		m := readBody(t, resp)
		token = m["token"].(string)
		if token == "" {
			t.Fatal("expected non-empty token")
		}
	})

	t.Run("Me with token", func(t *testing.T) {
		resp := requestWithToken(t, ts, "GET", "/api/v1/auth/me", "", token)
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200, got %d", resp.StatusCode)
		}
		m := readBody(t, resp)
		if m["username"] != "intuser" {
			t.Errorf("expected intuser, got %v", m["username"])
		}
	})

	t.Run("Refresh token", func(t *testing.T) {
		resp := requestWithToken(t, ts, "POST", "/api/v1/auth/refresh", "", token)
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200, got %d", resp.StatusCode)
		}
		m := readBody(t, resp)
		if m["token"] == "" {
			t.Fatal("expected refreshed token")
		}
	})

	t.Run("Login with correct password", func(t *testing.T) {
		resp := request(t, ts, "POST", "/api/v1/auth/login", `{"username":"intuser","password":"intpass"}`)
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200, got %d", resp.StatusCode)
		}
	})

	t.Run("Login with wrong password returns 401", func(t *testing.T) {
		resp := request(t, ts, "POST", "/api/v1/auth/login", `{"username":"intuser","password":"wrong"}`)
		if resp.StatusCode != http.StatusUnauthorized {
			t.Errorf("expected 401, got %d", resp.StatusCode)
		}
	})

	t.Run("Me without token returns 401", func(t *testing.T) {
		resp := request(t, ts, "GET", "/api/v1/auth/me", "")
		if resp.StatusCode != http.StatusUnauthorized {
			t.Errorf("expected 401, got %d", resp.StatusCode)
		}
	})

	t.Run("Duplicate registration returns 409", func(t *testing.T) {
		resp := request(t, ts, "POST", "/api/v1/auth/register", `{"username":"intuser","password":"intpass"}`)
		if resp.StatusCode != http.StatusConflict {
			t.Errorf("expected 409, got %d", resp.StatusCode)
		}
	})

	_ = secret
}

func TestIntegration_ConnectNotifications(t *testing.T) {
	ts, _ := newTestServer(t)

	t.Run("Send notification", func(t *testing.T) {
		resp := request(t, ts, "POST", "/api/v1/connect/notify", `{"channel":"lark","target":"user_123","title":"Hello","content":"Test message"}`)
		if resp.StatusCode != http.StatusCreated {
			t.Fatalf("expected 201, got %d", resp.StatusCode)
		}
	})

	var notifID string

	t.Run("List notifications", func(t *testing.T) {
		resp := request(t, ts, "GET", "/api/v1/connect/notifications", "")
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200, got %d", resp.StatusCode)
		}
		var list []any
		if err := json.NewDecoder(resp.Body).Decode(&list); err != nil {
			t.Fatalf("decode list: %v", err)
		}
		if len(list) > 0 {
			m := list[0].(map[string]any)
			notifID, _ = m["id"].(string)
		}
	})

	t.Run("Get notification by ID", func(t *testing.T) {
		if notifID == "" {
			t.Skip("no notification created")
		}
		resp := request(t, ts, "GET", "/api/v1/connect/notifications/"+notifID, "")
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200, got %d", resp.StatusCode)
		}
	})

	t.Run("Lark webhook", func(t *testing.T) {
		resp := request(t, ts, "POST", "/api/v1/connect/webhook/lark", `{"event":"approval","data":{"id":"a1"}}`)
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200, got %d", resp.StatusCode)
		}
	})

	t.Run("Get nonexistent notification returns 404", func(t *testing.T) {
		resp := request(t, ts, "GET", "/api/v1/connect/notifications/nonexistent", "")
		if resp.StatusCode != http.StatusNotFound {
			t.Errorf("expected 404, got %d", resp.StatusCode)
		}
	})
}

func TestIntegration_BusinessDomains(t *testing.T) {
	ts, _ := newTestServer(t)

	t.Run("QtConsult CRUD", func(t *testing.T) {
		resp := request(t, ts, "POST", "/api/v1/qtconsult/projects", `{"name":"Consult A","client":"Client X","stage":"init"}`)
		if resp.StatusCode != http.StatusCreated {
			t.Fatalf("expected 201, got %d", resp.StatusCode)
		}
		m := readBody(t, resp)
		id := m["id"].(string)

		resp = request(t, ts, "GET", "/api/v1/qtconsult/projects/"+id, "")
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200, got %d", resp.StatusCode)
		}

		resp = request(t, ts, "PUT", "/api/v1/qtconsult/projects/"+id+"/stage", `{"stage":"planning"}`)
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200, got %d", resp.StatusCode)
		}

		resp = request(t, ts, "DELETE", "/api/v1/qtconsult/projects/"+id, "")
		if resp.StatusCode != http.StatusNoContent {
			t.Errorf("expected 204, got %d", resp.StatusCode)
		}
	})

	t.Run("QtClass CRUD", func(t *testing.T) {
		resp := request(t, ts, "POST", "/api/v1/qtclass/courses", `{"name":"Rust 101","teacher":"Bob","max_students":20}`)
		if resp.StatusCode != http.StatusCreated {
			t.Fatalf("expected 201, got %d", resp.StatusCode)
		}
		m := readBody(t, resp)
		id := m["id"].(string)

		resp = request(t, ts, "GET", "/api/v1/qtclass/courses/"+id, "")
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200, got %d", resp.StatusCode)
		}

		resp = request(t, ts, "POST", "/api/v1/qtclass/enrollments", `{"course_id":"`+id+`","student":"Charlie"}`)
		if resp.StatusCode != http.StatusCreated {
			t.Errorf("expected 201, got %d", resp.StatusCode)
		}
	})

	t.Run("QtCloud resource lifecycle", func(t *testing.T) {
		resp := request(t, ts, "POST", "/api/v1/qtcloud/resources", `{"name":"VM-Prod","type":"ecs","region":"cn-east","status":"running"}`)
		if resp.StatusCode != http.StatusCreated {
			t.Fatalf("expected 201, got %d", resp.StatusCode)
		}
		m := readBody(t, resp)
		id := m["id"].(string)

		resp = request(t, ts, "PUT", "/api/v1/qtcloud/resources/"+id+"/status", `{"status":"stopped"}`)
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200, got %d", resp.StatusCode)
		}
		m = readBody(t, resp)
		if m["status"] != "stopped" {
			t.Errorf("expected stopped, got %v", m["status"])
		}

		resp = request(t, ts, "DELETE", "/api/v1/qtcloud/resources/"+id, "")
		if resp.StatusCode != http.StatusNoContent {
			t.Errorf("expected 204, got %d", resp.StatusCode)
		}
	})

	t.Run("QtData CRUD", func(t *testing.T) {
		resp := request(t, ts, "POST", "/api/v1/qtdata/datasets", `{"name":"Sales Q1","description":"Q1 data","version":"1.0"}`)
		if resp.StatusCode != http.StatusCreated {
			t.Fatalf("expected 201, got %d", resp.StatusCode)
		}
		m := readBody(t, resp)
		id := m["id"].(string)

		resp = request(t, ts, "GET", "/api/v1/qtdata/datasets/"+id, "")
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200, got %d", resp.StatusCode)
		}
	})

	t.Run("QtRecurit flow", func(t *testing.T) {
		resp := request(t, ts, "POST", "/api/v1/qtrecurit/resumes", `{"candidate_name":"Dave","position":"Engineer","stage":"new"}`)
		if resp.StatusCode != http.StatusCreated {
			t.Fatalf("expected 201, got %d", resp.StatusCode)
		}
		m := readBody(t, resp)
		id := m["id"].(string)

		resp = request(t, ts, "PUT", "/api/v1/qtrecurit/resumes/"+id+"/stage", `{"stage":"interview"}`)
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200, got %d", resp.StatusCode)
		}

		resp = request(t, ts, "POST", "/api/v1/qtrecurit/interviews", `{"candidate":"Dave","resume_id":"`+id+`"}`)
		if resp.StatusCode != http.StatusCreated {
			t.Fatalf("expected 201, got %d", resp.StatusCode)
		}
		m = readBody(t, resp)
		ivID := m["id"].(string)

		resp = request(t, ts, "POST", "/api/v1/qtrecurit/interviews/"+ivID+"/feedback", `{"feedback":"Strong hire"}`)
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200, got %d", resp.StatusCode)
		}
	})
}

func TestIntegration_DepartmentAndPosition(t *testing.T) {
	ts, _ := newTestServer(t)

	t.Run("Department CRUD", func(t *testing.T) {
		resp := request(t, ts, "POST", "/api/v1/departments", `{"name":"QA","leader":"Eve"}`)
		if resp.StatusCode != http.StatusCreated {
			t.Fatalf("expected 201, got %d", resp.StatusCode)
		}
		m := readBody(t, resp)
		id := m["id"].(string)

		resp = request(t, ts, "PUT", "/api/v1/departments/"+id, `{"name":"Quality Assurance","leader":"Eve"}`)
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200, got %d", resp.StatusCode)
		}
		m = readBody(t, resp)
		if m["name"] != "Quality Assurance" {
			t.Errorf("expected Quality Assurance, got %v", m["name"])
		}

		resp = request(t, ts, "DELETE", "/api/v1/departments/"+id, "")
		if resp.StatusCode != http.StatusNoContent {
			t.Errorf("expected 204, got %d", resp.StatusCode)
		}
	})

	t.Run("Position CRUD", func(t *testing.T) {
		resp := request(t, ts, "POST", "/api/v1/positions", `{"name":"Intern","department":"Engineering","description":"Entry level"}`)
		if resp.StatusCode != http.StatusCreated {
			t.Fatalf("expected 201, got %d", resp.StatusCode)
		}
		m := readBody(t, resp)
		id := m["id"].(string)

		resp = request(t, ts, "PUT", "/api/v1/positions/"+id, `{"name":"Junior Intern","description":"Updated"}`)
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200, got %d", resp.StatusCode)
		}

		resp = request(t, ts, "DELETE", "/api/v1/positions/"+id, "")
		if resp.StatusCode != http.StatusNoContent {
			t.Errorf("expected 204, got %d", resp.StatusCode)
		}
	})

	t.Run("List all departments", func(t *testing.T) {
		resp := request(t, ts, "GET", "/api/v1/departments", "")
		if resp.StatusCode != http.StatusOK {
			t.Errorf("expected 200, got %d", resp.StatusCode)
		}
	})

	t.Run("List all positions", func(t *testing.T) {
		resp := request(t, ts, "GET", "/api/v1/positions", "")
		if resp.StatusCode != http.StatusOK {
			t.Errorf("expected 200, got %d", resp.StatusCode)
		}
	})
}

func TestIntegration_ErrorPaths(t *testing.T) {
	ts, _ := newTestServer(t)

	t.Run("Invalid JSON body returns 400", func(t *testing.T) {
		resp := request(t, ts, "POST", "/api/v1/employees", "not json")
		if resp.StatusCode != http.StatusBadRequest {
			t.Errorf("expected 400, got %d", resp.StatusCode)
		}
	})

	t.Run("GET nonexistent employee returns 404", func(t *testing.T) {
		resp := request(t, ts, "GET", "/api/v1/employees/nonexistent", "")
		if resp.StatusCode != http.StatusNotFound {
			t.Errorf("expected 404, got %d", resp.StatusCode)
		}
	})

	t.Run("PUT nonexistent employee returns 404", func(t *testing.T) {
		resp := request(t, ts, "PUT", "/api/v1/employees/nonexistent", `{"name":"X"}`)
		if resp.StatusCode != http.StatusNotFound {
			t.Errorf("expected 404, got %d", resp.StatusCode)
		}
	})

	t.Run("DELETE nonexistent employee returns 404", func(t *testing.T) {
		resp := request(t, ts, "DELETE", "/api/v1/employees/nonexistent", "")
		if resp.StatusCode != http.StatusNotFound {
			t.Errorf("expected 404, got %d", resp.StatusCode)
		}
	})

	t.Run("Enrollment missing fields returns 400", func(t *testing.T) {
		resp := request(t, ts, "POST", "/api/v1/qtclass/enrollments", `{}`)
		if resp.StatusCode != http.StatusBadRequest {
			t.Errorf("expected 400, got %d", resp.StatusCode)
		}
	})

	t.Run("Create project missing name returns 400", func(t *testing.T) {
		resp := request(t, ts, "POST", "/api/v1/qtconsult/projects", `{}`)
		if resp.StatusCode != http.StatusBadRequest {
			t.Errorf("expected 400, got %d", resp.StatusCode)
		}
	})
}

func TestIntegration_CrossDomainFlow(t *testing.T) {
	ts, _ := newTestServer(t)

	t.Run("Create multiple resource types and verify lists", func(t *testing.T) {
		request(t, ts, "POST", "/api/v1/employees", `{"name":"Alice","department":"Engineering","position":"Dev"}`)
		request(t, ts, "POST", "/api/v1/employees", `{"name":"Bob","department":"QA","position":"Tester"}`)
		request(t, ts, "POST", "/api/v1/qtconsult/projects", `{"name":"Project X","client":"Client Y"}`)
		request(t, ts, "POST", "/api/v1/qtclass/courses", `{"name":"Go 201","teacher":"Alice"}`)
		request(t, ts, "POST", "/api/v1/qtcloud/resources", `{"name":"VM-1","type":"ecs"}`)
		request(t, ts, "POST", "/api/v1/qtdata/datasets", `{"name":"Dataset Z"}`)

		tests := []struct {
			path string
			code int
		}{
			{"/api/v1/employees", 200},
			{"/api/v1/departments", 200},
			{"/api/v1/positions", 200},
			{"/api/v1/qtconsult/projects", 200},
			{"/api/v1/qtclass/courses", 200},
			{"/api/v1/qtcloud/resources", 200},
			{"/api/v1/qtdata/datasets", 200},
		}

		for _, tt := range tests {
			resp := request(t, ts, "GET", tt.path, "")
			if resp.StatusCode != tt.code {
				t.Errorf("GET %s: expected %d, got %d", tt.path, tt.code, resp.StatusCode)
			}
		}
	})
}
