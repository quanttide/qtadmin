package model

type QtRecuritResume struct {
	ID            string `json:"id"`
	CandidateName string `json:"candidate_name"`
	Position      string `json:"position"`
	Stage         string `json:"stage"`
	Feedback      string `json:"feedback"`
	CreatedAt     string `json:"created_at"`
}

type QtRecuritInterview struct {
	ID        string `json:"id"`
	ResumeID  string `json:"resume_id"`
	Candidate string `json:"candidate"`
	Interviewer string `json:"interviewer"`
	Time      string `json:"time"`
	Feedback  string `json:"feedback"`
	CreatedAt string `json:"created_at"`
}
