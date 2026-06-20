package model

type Department struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	Parent   string `json:"parent"`
	Leader   string `json:"leader"`
}
