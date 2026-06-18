package model

type QtCloudResource struct {
	ID        string `json:"id"`
	Name      string `json:"name"`
	Type      string `json:"type"`
	Status    string `json:"status"`
	Region    string `json:"region"`
	CreatedAt string `json:"created_at"`
}
