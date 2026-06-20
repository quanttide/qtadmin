package model

type Employee struct {
	ID         string `json:"id"`
	Name       string `json:"name"`
	Department string `json:"department"`
	Position   string `json:"position"`
	HireDate   string `json:"hire_date"`
	Status     string `json:"status"`
}
