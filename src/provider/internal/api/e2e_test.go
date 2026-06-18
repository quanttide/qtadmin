package api

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func assertStatus(t *testing.T, resp *http.Response, want int) {
	t.Helper()
	if resp.StatusCode != want {
		t.Errorf("expected status %d, got %d", want, resp.StatusCode)
	}
}

func e2eRequest(t *testing.T, ts *httptest.Server, method, path, body string) *http.Response {
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

func e2eRequestAuth(t *testing.T, ts *httptest.Server, method, path, body, token string) *http.Response {
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

func e2eReadBody(t *testing.T, resp *http.Response) map[string]any {
	t.Helper()
	var m map[string]any
	if err := json.NewDecoder(resp.Body).Decode(&m); err != nil {
		t.Fatalf("decode body: %v", err)
	}
	return m
}

func e2eReadList(t *testing.T, resp *http.Response) []any {
	t.Helper()
	var list []any
	if err := json.NewDecoder(resp.Body).Decode(&list); err != nil {
		t.Fatalf("decode list: %v", err)
	}
	return list
}

func TestE2E_HumanEmployeeLifecycle(t *testing.T) {
	ts, _ := newTestServer(t)

	t.Run("Hire employee", func(t *testing.T) {
		resp := e2eRequest(t, ts, "POST", "/api/v1/employees", `{
			"name":"张三","department":"研发部","position":"后端工程师",
			"hire_date":"2026-01-15","status":"active"
		}`)
		assertStatus(t, resp, http.StatusCreated)
		m := e2eReadBody(t, resp)
		if m["name"] != "张三" {
			t.Errorf("expected 张三, got %v", m["name"])
		}
		if m["department"] != "研发部" {
			t.Errorf("expected 研发部, got %v", m["department"])
		}
	})

	t.Run("Transfer employee", func(t *testing.T) {
		resp := e2eRequest(t, ts, "POST", "/api/v1/employees", `{
			"name":"李四","department":"市场部","position":"市场专员",
			"hire_date":"2025-06-01","status":"active"
		}`)
		assertStatus(t, resp, http.StatusCreated)
		m := e2eReadBody(t, resp)
		id := m["id"].(string)

		resp = e2eRequest(t, ts, "PUT", "/api/v1/employees/"+id, `{
			"name":"李四","department":"研发部","position":"产品经理",
			"hire_date":"2025-06-01","status":"active"
		}`)
		assertStatus(t, resp, http.StatusOK)
	})

	t.Run("List all employees", func(t *testing.T) {
		resp := e2eRequest(t, ts, "GET", "/api/v1/employees", "")
		assertStatus(t, resp, http.StatusOK)
		list := e2eReadList(t, resp)
		if len(list) < 2 {
			t.Errorf("expected at least 2 employees, got %d", len(list))
		}
	})

	t.Run("Depart employee (delete)", func(t *testing.T) {
		resp := e2eRequest(t, ts, "POST", "/api/v1/employees", `{
			"name":"王五","department":"行政部","position":"行政助理",
			"hire_date":"2024-03-01","status":"active"
		}`)
		assertStatus(t, resp, http.StatusCreated)
		m := e2eReadBody(t, resp)
		id := m["id"].(string)

		resp = e2eRequest(t, ts, "DELETE", "/api/v1/employees/"+id, "")
		assertStatus(t, resp, http.StatusNoContent)

		resp = e2eRequest(t, ts, "GET", "/api/v1/employees/"+id, "")
		assertStatus(t, resp, http.StatusNotFound)
	})
}

func TestE2E_RecruitmentFlow(t *testing.T) {
	ts, _ := newTestServer(t)

	t.Run("Import resume from招聘平台", func(t *testing.T) {
		resp := e2eRequest(t, ts, "POST", "/api/v1/qtrecurit/resumes", `{
			"candidate_name":"赵六","position":"Go后端工程师",
			"source":"Boss直聘","stage":"new"
		}`)
		assertStatus(t, resp, http.StatusCreated)
		m := e2eReadBody(t, resp)
		if m["candidate_name"] != "赵六" {
			t.Errorf("expected 赵六, got %v", m["candidate_name"])
		}
		if m["stage"] != "new" {
			t.Errorf("expected stage=new, got %v", m["stage"])
		}
	})

	t.Run("Schedule interview", func(t *testing.T) {
		resp := e2eRequest(t, ts, "POST", "/api/v1/qtrecurit/interviews", `{
			"candidate":"赵六","interviewer":"陈经理",
			"date":"2026-06-20","type":"技术面"
		}`)
		assertStatus(t, resp, http.StatusCreated)
	})
}

func TestE2E_BusinessProjectLifecycle(t *testing.T) {
	ts, _ := newTestServer(t)

	var projectID string

	t.Run("Create consulting project", func(t *testing.T) {
		resp := e2eRequest(t, ts, "POST", "/api/v1/qtconsult/projects", `{
			"name":"某银行数字化转型咨询",
			"client":"某银行","stage":"调研","status":"active"
		}`)
		assertStatus(t, resp, http.StatusCreated)
		m := e2eReadBody(t, resp)
		projectID = m["id"].(string)
	})

	t.Run("Update project to planning stage", func(t *testing.T) {
		resp := e2eRequest(t, ts, "PUT", "/api/v1/qtconsult/projects/"+projectID, `{
			"name":"某银行数字化转型咨询",
			"client":"某银行","stage":"方案设计","status":"active"
		}`)
		assertStatus(t, resp, http.StatusOK)
		m := e2eReadBody(t, resp)
		if m["stage"] != "方案设计" {
			t.Errorf("expected stage=方案设计, got %v", m["stage"])
		}
	})

	t.Run("Complete project", func(t *testing.T) {
		resp := e2eRequest(t, ts, "PUT", "/api/v1/qtconsult/projects/"+projectID, `{
			"name":"某银行数字化转型咨询",
			"client":"某银行","stage":"已交付","status":"completed"
		}`)
		assertStatus(t, resp, http.StatusOK)
	})

	t.Run("List projects across stages", func(t *testing.T) {
		resp := e2eRequest(t, ts, "GET", "/api/v1/qtconsult/projects", "")
		assertStatus(t, resp, http.StatusOK)
		list := e2eReadList(t, resp)
		if len(list) < 1 {
			t.Errorf("expected at least 1 project")
		}
	})
}

func TestE2E_EducationCourseFlow(t *testing.T) {
	ts, _ := newTestServer(t)

	t.Run("Create course", func(t *testing.T) {
		resp := e2eRequest(t, ts, "POST", "/api/v1/qtclass/courses", `{
			"name":"Go语言进阶实战","teacher":"王教授",
			"max_students":30,"status":"active"
		}`)
		assertStatus(t, resp, http.StatusCreated)
	})

	t.Run("Student enrollment", func(t *testing.T) {
		resp := e2eRequest(t, ts, "POST", "/api/v1/qtclass/enrollments", `{
			"course_id":"c1","student":"小明"
		}`)
		assertStatus(t, resp, http.StatusCreated)
	})

	t.Run("View course schedule", func(t *testing.T) {
		resp := e2eRequest(t, ts, "GET", "/api/v1/qtclass/schedules", "")
		assertStatus(t, resp, http.StatusOK)
	})
}

func TestE2E_CloudResourceManagement(t *testing.T) {
	ts, _ := newTestServer(t)

	t.Run("Provision cloud resource", func(t *testing.T) {
		resp := e2eRequest(t, ts, "POST", "/api/v1/qtcloud/resources", `{
			"name":"生产环境ECS-01","type":"ecs",
			"region":"cn-east","spec":"8C16G","status":"running"
		}`)
		assertStatus(t, resp, http.StatusCreated)
	})

	t.Run("Stop resource", func(t *testing.T) {
		resp := e2eRequest(t, ts, "POST", "/api/v1/qtcloud/resources", `{
			"name":"测试环境ECS-01","type":"ecs",
			"region":"cn-east","spec":"4C8G","status":"running"
		}`)
		assertStatus(t, resp, http.StatusCreated)
		m := e2eReadBody(t, resp)
		id := m["id"].(string)

		resp = e2eRequest(t, ts, "PUT", "/api/v1/qtcloud/resources/"+id, `{
			"name":"测试环境ECS-01","type":"ecs",
			"region":"cn-east","spec":"4C8G","status":"stopped"
		}`)
		assertStatus(t, resp, http.StatusOK)
	})
}

func TestE2E_DataAssetManagement(t *testing.T) {
	ts, _ := newTestServer(t)

	t.Run("Create dataset", func(t *testing.T) {
		resp := e2eRequest(t, ts, "POST", "/api/v1/qtdata/datasets", `{
			"name":"2026年Q1销售数据","description":"第一季度销售明细",
			"version":"1.0","status":"ready"
		}`)
		assertStatus(t, resp, http.StatusCreated)
	})

	t.Run("Version update", func(t *testing.T) {
		resp := e2eRequest(t, ts, "POST", "/api/v1/qtdata/datasets", `{
			"name":"2026年Q1销售数据","description":"第一季度销售明细（含退款）",
			"version":"1.1","status":"ready"
		}`)
		assertStatus(t, resp, http.StatusCreated)
		m := e2eReadBody(t, resp)
		id := m["id"].(string)

		resp = e2eRequest(t, ts, "GET", "/api/v1/qtdata/datasets/"+id, "")
		assertStatus(t, resp, http.StatusOK)
		if m["version"] != "1.1" {
			t.Errorf("expected version=1.1, got %v", m["version"])
		}
	})
}

func TestE2E_AdminAuthFlow(t *testing.T) {
	ts, _ := newTestServer(t)

	var token string

	t.Run("Admin login", func(t *testing.T) {
		resp := e2eRequest(t, ts, "POST", "/api/v1/auth/login", `{"username":"admin","password":"adminpass"}`)
		assertStatus(t, resp, http.StatusOK)
		m := e2eReadBody(t, resp)
		token = m["token"].(string)
		if token == "" {
			t.Fatal("expected non-empty token")
		}
		if m["user"].(map[string]any)["username"] != "admin" {
			t.Errorf("expected username=admin")
		}
	})

	t.Run("Access protected me endpoint", func(t *testing.T) {
		resp := e2eRequestAuth(t, ts, "GET", "/api/v1/auth/me", "", token)
		assertStatus(t, resp, http.StatusOK)
	})

	t.Run("Refresh token", func(t *testing.T) {
		resp := e2eRequestAuth(t, ts, "POST", "/api/v1/auth/refresh", "", token)
		assertStatus(t, resp, http.StatusOK)
		m := e2eReadBody(t, resp)
		if m["token"] == "" {
			t.Fatal("expected refreshed token")
		}
	})

	t.Run("Protected endpoint without token returns 401", func(t *testing.T) {
		resp := e2eRequest(t, ts, "GET", "/api/v1/auth/me", "")
		assertStatus(t, resp, http.StatusUnauthorized)
	})
}

func TestE2E_CrossDomainWorkflow(t *testing.T) {
	ts, _ := newTestServer(t)

	t.Run("Create department and position", func(t *testing.T) {
		e2eRequest(t, ts, "POST", "/api/v1/departments", `{"name":"研发部","leader":"陈总"}`)
		e2eRequest(t, ts, "POST", "/api/v1/positions", `{"name":"高级工程师","department":"研发部"}`)
	})

	t.Run("Hire employee into department", func(t *testing.T) {
		resp := e2eRequest(t, ts, "POST", "/api/v1/employees", `{
			"name":"小李","department":"研发部","position":"高级工程师",
			"hire_date":"2026-06-01","status":"active"
		}`)
		assertStatus(t, resp, http.StatusCreated)
		m := e2eReadBody(t, resp)
		if m["department"] != "研发部" {
			t.Errorf("expected 研发部, got %v", m["department"])
		}
		if m["position"] != "高级工程师" {
			t.Errorf("expected 高级工程师, got %v", m["position"])
		}
	})

	t.Run("Create project and assign employee context", func(t *testing.T) {
		resp := e2eRequest(t, ts, "POST", "/api/v1/qtconsult/projects", `{
			"name":"AI平台建设项目","client":"某科技公司",
			"stage":"调研","status":"active"
		}`)
		assertStatus(t, resp, http.StatusCreated)

		resp = e2eRequest(t, ts, "POST", "/api/v1/qtclass/courses", `{
			"name":"AI基础培训","teacher":"小李","max_students":50
		}`)
		assertStatus(t, resp, http.StatusCreated)
	})

	t.Run("Verify all data accessible", func(t *testing.T) {
		for _, path := range []string{
			"/api/v1/employees",
			"/api/v1/departments",
			"/api/v1/positions",
			"/api/v1/qtconsult/projects",
			"/api/v1/qtclass/courses",
		} {
			resp := e2eRequest(t, ts, "GET", path, "")
			assertStatus(t, resp, http.StatusOK)
		}
	})
}
