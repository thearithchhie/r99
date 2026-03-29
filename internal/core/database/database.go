package database

import (
	"fmt"
	"log"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
	"github.com/thearithchhie/r99_shop/internal/core/config"
)

// DB holds the database connection
var DB *sqlx.DB

// Init initializes the database connection
func Init(cfg *config.Config) error {
	var err error

	switch cfg.Database.Driver {
	case "postgres":
		connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
			cfg.Database.Host,
			cfg.Database.Port,
			cfg.Database.Username,
			cfg.Database.Password,
			cfg.Database.Database,
			cfg.Database.SSLMode,
		)

		DB, err = sqlx.Connect("postgres", connStr)
		if err != nil {
			return fmt.Errorf("failed to connect to database: %w", err)
		}

		// Test connection
		if err := DB.Ping(); err != nil {
			return fmt.Errorf("failed to ping database: %w", err)
		}

		// Set connection pool settings
		DB.SetMaxOpenConns(25)
		DB.SetMaxIdleConns(5)

	case "sqlite":
		// Keep SQLite support for development/testing
		DB, err = sqlx.Connect("sqlite3", cfg.Database.Path)
		if err != nil {
			return fmt.Errorf("failed to connect to database: %w", err)
		}

		if err := DB.Ping(); err != nil {
			return fmt.Errorf("failed to ping database: %w", err)
		}

	default:
		return fmt.Errorf("unsupported database driver: %s", cfg.Database.Driver)
	}

	log.Println("Database connected successfully")
	return nil
}

// GetDB returns the database instance
func GetDB() *sqlx.DB {
	return DB
}

// Close closes the database connection
func Close() error {
	if DB != nil {
		return DB.Close()
	}
	return nil
}
