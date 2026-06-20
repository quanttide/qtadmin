package model

type QtClassCourse struct {
	ID         string `json:"id"`
	Name       string `json:"name"`
	Teacher    string `json:"teacher"`
	Schedule   string `json:"schedule"`
	MaxStudents int    `json:"max_students"`
	Status     string `json:"status"`
}
