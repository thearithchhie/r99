package auth

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
	"golang.org/x/crypto/bcrypt"
)

type Repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{db: db}
}

// Create creates a new user with hashed password
func (r *Repository) Create(ctx context.Context, user *User, plainPassword string) error {
	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(plainPassword), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("failed to hash password: %w", err)
	}

	query := `
		INSERT INTO users (name, email, password, is_active, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, uuid, created_at, updated_at`

	now := time.Now()
	err = r.db.QueryRowContext(ctx, query,
		user.Name,
		user.Email,
		string(hashedPassword),
		true,
		now,
		now,
	).Scan(&user.ID, &user.UUID, &user.CreatedAt, &user.UpdatedAt)

	return err
}

// GetByID retrieves a user by ID
func (r *Repository) GetByID(ctx context.Context, id int) (*User, error) {
	query := `SELECT id, uuid, name, email, password, is_active, created_at, updated_at
			  FROM users WHERE id = $1`

	var user User
	err := r.db.GetContext(ctx, &user, query, id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("user not found")
		}
		return nil, err
	}

	return &user, nil
}

// GetByEmail retrieves a user by email
func (r *Repository) GetByEmail(ctx context.Context, email string) (*User, error) {
	query := `SELECT id, uuid, name, email, password, is_active, created_at, updated_at
			  FROM users WHERE email = $1`

	var user User
	err := r.db.GetContext(ctx, &user, query, email)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("user not found")
		}
		return nil, err
	}

	return &user, nil
}

// EmailExists checks if an email already exists
func (r *Repository) EmailExists(ctx context.Context, email string) (bool, error) {
	query := `SELECT EXISTS(SELECT 1 FROM users WHERE email = $1)`
	var exists bool
	err := r.db.GetContext(ctx, &exists, query, email)
	return exists, err
}

// VerifyPassword verifies a plain password against a hashed password
func VerifyPassword(hashedPassword, plainPassword string) error {
	return bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(plainPassword))
}

// GetAll retrieves all users with pagination
func (r *Repository) GetAll(ctx context.Context, limit, offset int) ([]User, error) {
	query := `SELECT id, uuid, name, email, is_active, created_at, updated_at
			  FROM users ORDER BY created_at DESC LIMIT $1 OFFSET $2`

	var users []User
	err := r.db.SelectContext(ctx, &users, query, limit, offset)
	return users, err
}

// Update updates a user
func (r *Repository) Update(ctx context.Context, user *User) error {
	query := `
		UPDATE users
		SET name = $1, email = $2, is_active = $3, updated_at = $4
		WHERE id = $5`

	now := time.Now()
	result, err := r.db.ExecContext(ctx, query,
		user.Name,
		user.Email,
		user.IsActive,
		now,
		user.ID,
	)

	if err != nil {
		return err
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rows == 0 {
		return fmt.Errorf("user not found")
	}

	return nil
}

// Delete deletes a user
func (r *Repository) Delete(ctx context.Context, id int) error {
	query := `DELETE FROM users WHERE id = $1`

	result, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return err
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rows == 0 {
		return fmt.Errorf("user not found")
	}

	return nil
}

// Count returns total number of users
func (r *Repository) Count(ctx context.Context) (int, error) {
	query := `SELECT COUNT(*) FROM users`
	var count int
	err := r.db.GetContext(ctx, &count, query)
	return count, err
}
