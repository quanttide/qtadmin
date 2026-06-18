package api

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"log/slog"
	"net/http"
	"time"

	"github.com/quanttide/qtadmin-provider/internal/auth"
	"github.com/quanttide/qtadmin-provider/internal/model"
	"github.com/quanttide/qtadmin-provider/internal/store"
)

type AuthHandler struct {
	store  store.Store
	secret string
}

func NewAuthHandler(st store.Store, secret string) *AuthHandler {
	return &AuthHandler{store: st, secret: secret}
}

type loginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type authResponse struct {
	Token string      `json:"token"`
	User  model.User `json:"user"`
}

func hashPassword(username, password string) string {
	h := sha256.Sum256([]byte(username + ":" + password))
	return hex.EncodeToString(h[:])
}

func (h *AuthHandler) findUserByUsername(username string) (*model.User, error) {
	data, err := h.store.List("auth/users")
	if err != nil {
		return nil, err
	}
	var users []model.User
	if err := json.Unmarshal(data, &users); err != nil {
		return nil, err
	}
	for _, u := range users {
		if u.Username == username {
			return &u, nil
		}
	}
	return nil, nil
}

func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	var req loginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		WriteError(w, "INVALID_INPUT", "invalid request body", http.StatusBadRequest)
		return
	}
	if req.Username == "" || req.Password == "" {
		WriteError(w, "VALIDATION_ERROR", "username and password are required", http.StatusBadRequest)
		return
	}

	user, err := h.findUserByUsername(req.Username)
	if err != nil {
		slog.Error("find user", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to find user", http.StatusInternalServerError)
		return
	}
	if user == nil || user.PasswordHash != hashPassword(req.Username, req.Password) {
		WriteError(w, "INVALID_CREDENTIALS", "invalid username or password", http.StatusUnauthorized)
		return
	}

	claims := map[string]any{
		"sub":  user.ID,
		"role": user.RoleID,
		"exp":  time.Now().Add(24 * time.Hour).Unix(),
	}
	token, err := auth.Sign(claims, h.secret)
	if err != nil {
		slog.Error("sign token", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to generate token", http.StatusInternalServerError)
		return
	}

	WriteJSON(w, authResponse{Token: token, User: *user}, http.StatusOK)
}

func (h *AuthHandler) EnsureAdmin(password string) error {
	existing, err := h.findUserByUsername("admin")
	if err != nil {
		return err
	}
	if existing != nil {
		slog.Info("admin user already exists, skipping seed")
		return nil
	}

	user := model.User{
		Username:     "admin",
		PasswordHash: hashPassword("admin", password),
		CreatedAt:    time.Now().Format(time.RFC3339),
	}
	data, err := json.Marshal(user)
	if err != nil {
		return err
	}
	id, err := h.store.Create("auth/users", data)
	if err != nil {
		return err
	}
	user.ID = id
	data, err = json.Marshal(user)
	if err != nil {
		return err
	}
	if err := h.store.Update("auth/users", id, data); err != nil {
		return err
	}
	slog.Info("admin user created")
	return nil
}

func (h *AuthHandler) Refresh(w http.ResponseWriter, r *http.Request) {
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" || len(authHeader) < 7 || authHeader[:7] != "Bearer " {
		WriteError(w, "UNAUTHORIZED", "missing or invalid authorization header", http.StatusUnauthorized)
		return
	}

	oldToken := authHeader[7:]
	claims, err := auth.Verify(oldToken, h.secret)
	if err != nil {
		WriteError(w, "UNAUTHORIZED", "invalid or expired token", http.StatusUnauthorized)
		return
	}

	claims["exp"] = time.Now().Add(24 * time.Hour).Unix()
	newToken, err := auth.Sign(claims, h.secret)
	if err != nil {
		slog.Error("sign token", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to generate token", http.StatusInternalServerError)
		return
	}

	WriteJSON(w, map[string]string{"token": newToken}, http.StatusOK)
}

func (h *AuthHandler) Me(w http.ResponseWriter, r *http.Request) {
	claims, ok := r.Context().Value(ClaimsKey).(map[string]any)
	if !ok {
		WriteError(w, "UNAUTHORIZED", "unauthorized", http.StatusUnauthorized)
		return
	}

	sub, ok := claims["sub"].(string)
	if !ok {
		WriteError(w, "UNAUTHORIZED", "invalid token claims", http.StatusUnauthorized)
		return
	}

	data, err := h.store.Get("auth/users", sub)
	if err != nil {
		WriteError(w, "NOT_FOUND", "user not found", http.StatusNotFound)
		return
	}

	var user model.User
	if err := json.Unmarshal(data, &user); err != nil {
		slog.Error("parse user", "error", err)
		WriteError(w, "INTERNAL_ERROR", "failed to parse user", http.StatusInternalServerError)
		return
	}

	WriteJSON(w, user, http.StatusOK)
}
