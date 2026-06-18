package main

import (
	"log"
	"net/http"
	"os"

	"github.com/quanttide/qtadmin-provider/internal/api"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", api.Health)

	addr := os.Getenv("ADDR")
	if addr == "" {
		addr = ":8000"
	}

	log.Printf("listening on %s", addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatal(err)
	}
}
