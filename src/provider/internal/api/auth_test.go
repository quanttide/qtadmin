package api

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/quanttide/qtadmin-provider/internal/auth"
)

func registerAuthRoutes(h *AuthHandler, secret string) *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("POST /api/v1/auth/register", h.Register)
	mux.HandleFunc("POST /api/v1/auth/login", h.Login)
	mux.Handle("POST /api/v1/auth/refresh", AuthMiddleware(secret)(http.HandlerFunc(h.Refresh)))
	mux.Handle("GET /api/v1/auth/me", AuthMiddleware(secret)(http.HandlerFunc(h.Me)))
	return mux
}

func TestRegisterAndLogin(t *testing.T) {
	s, cleanup := testSetup(t)
	defer cleanup()

	secret := "test-jwt-secret"
	h := NewAuthHandler(s, secret)
	mux := registerAuthRoutes(h, secret)

	var token string

	t.Run("Register", func(t *testing.T) {
		body := `{"username":"testuser","password":"pass123"}`
		req := httptest.NewRequest("POST", "/api/v1/auth/register", strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusCreated {
			t.Fatalf("expected 201, got %d: %s", rec.Code, rec.Body.String())
		}

		var resp authResponse
		if err := json.Unmarshal(rec.Body.Bytes(), &resp); err != nil {
			t.Fatalf("unmarshal failed: %v", err)
		}
		if resp.Token == "" {
			t.Error("expected non-empty token")
		}
		if resp.User.Username != "testuser" {
			t.Errorf("expected username=testuser, got %s", resp.User.Username)
		}
		token = resp.Token
	})

	t.Run("Login", func(t *testing.T) {
		body := `{"username":"testuser","password":"pass123"}`
		req := httptest.NewRequest("POST", "/api/v1/auth/login", strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusOK {
			t.Fatalf("expected 200, got %d: %s", rec.Code, rec.Body.String())
		}

		var resp authResponse
		if err := json.Unmarshal(rec.Body.Bytes(), &resp); err != nil {
			t.Fatalf("unmarshal failed: %v", err)
		}
		if resp.Token == "" {
			t.Error("expected non-empty token")
		}
	})

	t.Run("Duplicate registration returns 409", func(t *testing.T) {
		body := `{"username":"testuser","password":"pass123"}`
		req := httptest.NewRequest("POST", "/api/v1/auth/register", strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusConflict {
			t.Errorf("expected 409, got %d: %s", rec.Code, rec.Body.String())
		}
	})

	t.Run("Me with token", func(t *testing.T) {
		req := httptest.NewRequest("GET", "/api/v1/auth/me", nil)
		req.Header.Set("Authorization", "Bearer "+token)
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusOK {
			t.Fatalf("expected 200, got %d: %s", rec.Code, rec.Body.String())
		}
	})

	t.Run("Refresh", func(t *testing.T) {
		req := httptest.NewRequest("POST", "/api/v1/auth/refresh", nil)
		req.Header.Set("Authorization", "Bearer "+token)
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)

		if rec.Code != http.StatusOK {
			t.Fatalf("expected 200, got %d: %s", rec.Code, rec.Body.String())
		}
	})
}

func TestLoginInvalid(t *testing.T) {
	s, cleanup := testSetup(t)
	defer cleanup()

	secret := "test-jwt-secret"
	h := NewAuthHandler(s, secret)
	mux := registerAuthRoutes(h, secret)

	t.Run("wrong password returns 401", func(t *testing.T) {
		body := `{"username":"testuser","password":"pass123"}`
		req := httptest.NewRequest("POST", "/api/v1/auth/register", strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusCreated {
			t.Fatalf("register failed: %d: %s", rec.Code, rec.Body.String())
		}

		body = `{"username":"testuser","password":"wrongpass"}`
		req = httptest.NewRequest("POST", "/api/v1/auth/login", strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec = httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusUnauthorized {
			t.Errorf("expected 401 for wrong password, got %d", rec.Code)
		}
	})

	t.Run("nonexistent user returns 401", func(t *testing.T) {
		body := `{"username":"nobody","password":"pass"}`
		req := httptest.NewRequest("POST", "/api/v1/auth/login", strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusUnauthorized {
			t.Errorf("expected 401, got %d", rec.Code)
		}
	})

	t.Run("empty credentials returns 400", func(t *testing.T) {
		body := `{"username":"","password":""}`
		req := httptest.NewRequest("POST", "/api/v1/auth/login", strings.NewReader(body))
		req.Header.Set("Content-Type", "application/json")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		if rec.Code != http.StatusBadRequest {
			t.Errorf("expected 400, got %d", rec.Code)
		}
	})
}

func TestAuthMiddleware(t *testing.T) {
	secret := "test-jwt-secret"

	t.Run("no token returns 401", func(t *testing.T) {
		handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusOK)
		})
		mw := AuthMiddleware(secret)(handler)

		req := httptest.NewRequest("GET", "/", nil)
		rec := httptest.NewRecorder()
		mw.ServeHTTP(rec, req)

		if rec.Code != http.StatusUnauthorized {
			t.Errorf("expected 401, got %d", rec.Code)
		}
	})

	t.Run("invalid token returns 401", func(t *testing.T) {
		handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusOK)
		})
		mw := AuthMiddleware(secret)(handler)

		req := httptest.NewRequest("GET", "/", nil)
		req.Header.Set("Authorization", "Bearer invalidtoken")
		rec := httptest.NewRecorder()
		mw.ServeHTTP(rec, req)

		if rec.Code != http.StatusUnauthorized {
			t.Errorf("expected 401, got %d", rec.Code)
		}
	})

	t.Run("valid token passes through", func(t *testing.T) {
		handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			claims := r.Context().Value(ClaimsKey).(map[string]any)
			if claims["sub"] != "testuser" {
				t.Errorf("expected sub=testuser, got %v", claims["sub"])
			}
			w.WriteHeader(http.StatusOK)
			w.Write([]byte("ok"))
		})
		mw := AuthMiddleware(secret)(handler)

		claims := map[string]any{
			"sub": "testuser",
		}
		token, err := auth.Sign(claims, secret)
		if err != nil {
			t.Fatalf("Sign failed: %v", err)
		}

		req := httptest.NewRequest("GET", "/", nil)
		req.Header.Set("Authorization", "Bearer "+token)
		rec := httptest.NewRecorder()
		mw.ServeHTTP(rec, req)

		if rec.Code != http.StatusOK {
			t.Errorf("expected 200, got %d", rec.Code)
		}
		if rec.Body.String() != "ok" {
			t.Errorf("expected body 'ok', got '%s'", rec.Body.String())
		}
	})

	t.Run("missing bearer prefix returns 401", func(t *testing.T) {
		handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusOK)
		})
		mw := AuthMiddleware(secret)(handler)

		req := httptest.NewRequest("GET", "/", nil)
		req.Header.Set("Authorization", "Token sometoken")
		rec := httptest.NewRecorder()
		mw.ServeHTTP(rec, req)

		if rec.Code != http.StatusUnauthorized {
			t.Errorf("expected 401, got %d", rec.Code)
		}
	})
}
