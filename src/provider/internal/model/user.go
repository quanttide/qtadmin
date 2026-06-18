package model

type User struct {
	ID           string `json:"id"`
	Username     string `json:"username"`
	PasswordHash string `json:"password_hash"`
	RoleID       string `json:"role_id"`
	CreatedAt    string `json:"created_at"`
}
