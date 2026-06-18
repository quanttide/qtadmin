package model

type PositionRule struct {
	ID       string   `json:"id"`
	Name     string   `json:"name"`
	Keywords []string `json:"keywords"`
	Exclude  []string `json:"exclude"`
	Priority int      `json:"priority"`
}
