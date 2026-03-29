package customer

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
)

type Repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{db: db}
}

// Create creates a new customer
func (r *Repository) Create(ctx context.Context, customer *Customer) error {
	query := `
		INSERT INTO customers (name, email, phone, address, city, country, postal_code, is_active, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		RETURNING id, created_at, updated_at`

	now := time.Now()
	err := r.db.QueryRowContext(ctx, query,
		customer.Name,
		customer.Email,
		customer.Phone,
		customer.Address,
		customer.City,
		customer.Country,
		customer.PostalCode,
		customer.IsActive,
		now,
		now,
	).Scan(&customer.ID, &customer.CreatedAt, &customer.UpdatedAt)

	return err
}

// GetByID retrieves a customer by ID
func (r *Repository) GetByID(ctx context.Context, id int) (*Customer, error) {
	query := `SELECT id, name, email, phone, address, city, country, postal_code, is_active, created_at, updated_at
			  FROM customers WHERE id = $1`

	var customer Customer
	err := r.db.GetContext(ctx, &customer, query, id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("customer not found")
		}
		return nil, err
	}

	return &customer, nil
}

// GetByEmail retrieves a customer by email
func (r *Repository) GetByEmail(ctx context.Context, email string) (*Customer, error) {
	query := `SELECT id, name, email, phone, address, city, country, postal_code, is_active, created_at, updated_at
			  FROM customers WHERE email = $1`

	var customer Customer
	err := r.db.GetContext(ctx, &customer, query, email)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("customer not found")
		}
		return nil, err
	}

	return &customer, nil
}

// GetAll retrieves all customers with pagination
func (r *Repository) GetAll(ctx context.Context, limit, offset int) ([]Customer, error) {
	query := `SELECT id, name, email, phone, address, city, country, postal_code, is_active, created_at, updated_at
			  FROM customers ORDER BY created_at DESC LIMIT $1 OFFSET $2`

	var customers []Customer
	err := r.db.SelectContext(ctx, &customers, query, limit, offset)
	return customers, err
}

// Update updates a customer
func (r *Repository) Update(ctx context.Context, customer *Customer) error {
	query := `
		UPDATE customers
		SET name = $1, email = $2, phone = $3, address = $4, city = $5,
			country = $6, postal_code = $7, is_active = $8, updated_at = $9
		WHERE id = $10`

	customer.UpdatedAt = time.Now().Format(time.RFC3339)
	result, err := r.db.ExecContext(ctx, query,
		customer.Name,
		customer.Email,
		customer.Phone,
		customer.Address,
		customer.City,
		customer.Country,
		customer.PostalCode,
		customer.IsActive,
		customer.UpdatedAt,
		customer.ID,
	)

	if err != nil {
		return err
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rows == 0 {
		return fmt.Errorf("customer not found")
	}

	return nil
}

// Delete deletes a customer
func (r *Repository) Delete(ctx context.Context, id int) error {
	query := `DELETE FROM customers WHERE id = $1`

	result, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return err
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rows == 0 {
		return fmt.Errorf("customer not found")
	}

	return nil
}

// Count returns total number of customers
func (r *Repository) Count(ctx context.Context) (int, error) {
	query := `SELECT COUNT(*) FROM customers`
	var count int
	err := r.db.GetContext(ctx, &count, query)
	return count, err
}