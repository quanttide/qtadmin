package model

import "time"

type Notification struct {
	ID        string     `json:"id"`
	Title     string     `json:"title"`
	Content   string     `json:"content"`
	Channel   string     `json:"channel"`
	Status    string     `json:"status"`
	Target    string     `json:"target"`
	CreatedAt time.Time  `json:"created_at"`
	ReadAt    *time.Time `json:"read_at,omitempty"`
}
