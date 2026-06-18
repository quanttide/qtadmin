package model

type QtConsultProject struct {
	ID        string `json:"id"`
	Name      string `json:"name"`
	Stage     string `json:"stage"`
	Client    string `json:"client"`
	Status    string `json:"status"`
	CreatedAt string `json:"created_at"`
}
