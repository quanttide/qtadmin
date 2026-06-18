package db

import "fmt"

type DB struct {
	dsn string
}

func Open(dsn string) (*DB, error) {
	return &DB{dsn: dsn}, fmt.Errorf("database driver not available: compile with GORM or sqlc")
}

func (db *DB) DSN() string { return db.dsn }
