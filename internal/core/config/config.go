package config

import (
	"fmt"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

// Config holds all configuration for the application
type Config struct {
	Server   ServerConfig
	Database DatabaseConfig
	JWT      JWTConfig
	CORS     CORSConfig
}

// ServerConfig holds server configuration
type ServerConfig struct {
	Port string
	Host string
}

// CORSConfig holds CORS configuration
type CORSConfig struct {
	AllowedOrigins string
}

// DatabaseConfig holds database configuration
type DatabaseConfig struct {
	Driver   string
	Host     string
	Port     string
	Database string
	Username string
	Password string
	SSLMode  string
	Path     string // For SQLite
}

// JWTConfig holds JWT configuration
type JWTConfig struct {
	Secret     string
	Expiration int // hours
}

// Load loads configuration from environment variables
func Load() (*Config, error) {
	// Load .env file if exists (don't fail if it doesn't exist)
	if err := godotenv.Load(); err != nil {
		fmt.Println("No .env file found, using environment variables or defaults")
	}

	cfg := &Config{
		Server: ServerConfig{
			Port: getEnv("SERVER_PORT", "3000"),
			Host: getEnv("SERVER_HOST", "localhost"),
		},
		Database: DatabaseConfig{
			Driver:   getEnv("DB_DRIVER", "sqlite"),
			Host:     getEnv("DB_HOST", "localhost"),
			Port:     getEnv("DB_PORT", "5432"),
			Database: getEnv("DB_NAME", "r99_shop"),
			Username: getEnv("DB_USER", ""),
			Password: getEnv("DB_PASSWORD", ""),
			SSLMode:  getEnv("DB_SSLMODE", "disable"),
			Path:     getEnv("DB_PATH", "./r99_shop.db"),
		},
		JWT: JWTConfig{
			Secret:     getEnv("JWT_SECRET", "your-secret-key-change-this"),
			Expiration: getEnvAsInt("JWT_EXPIRATION", 24),
		},
		CORS: CORSConfig{
			AllowedOrigins: getEnv("CORS_ALLOWED_ORIGINS", "http://localhost:3001,http://127.0.0.1:3001"),
		},
	}

	// Validate configuration
	if cfg.JWT.Secret == "your-secret-key-change-this" {
		fmt.Println("WARNING: Using default JWT secret. Please change JWT_SECRET in production!")
	}

	return cfg, nil
}

// getEnv gets environment variable with fallback
func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

// getEnvAsInt gets environment variable as integer with fallback
func getEnvAsInt(key string, fallback int) int {
	if value := os.Getenv(key); value != "" {
		if intVal, err := strconv.Atoi(value); err == nil {
			return intVal
		}
	}
	return fallback
}
