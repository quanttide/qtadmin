package api

import "net/http"

func Health(w http.ResponseWriter, r *http.Request) {
	WriteJSON(w, map[string]string{"status": "ok"}, http.StatusOK)
}
