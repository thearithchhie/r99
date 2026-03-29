package product

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

// Create creates a new product
func (r *Repository) Create(ctx context.Context, product *Product) error {
	query := `
		INSERT INTO products (name, description, sku, price, cost, quantity, category_id, is_active, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		RETURNING id, created_at, updated_at`

	now := time.Now()
	err := r.db.QueryRowContext(ctx, query,
		product.Name,
		product.Description,
		product.SKU,
		product.Price,
		product.Cost,
		product.Quantity,
		product.CategoryID,
		product.IsActive,
		now,
		now,
	).Scan(&product.ID, &product.CreatedAt, &product.UpdatedAt)

	return err
}

// GetByID retrieves a product by ID
func (r *Repository) GetByID(ctx context.Context, id int) (*Product, error) {
	query := `SELECT id, name, description, sku, price, cost, quantity, category_id, is_active, created_at, updated_at
			  FROM products WHERE id = $1`

	var product Product
	err := r.db.GetContext(ctx, &product, query, id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("product not found")
		}
		return nil, err
	}

	return &product, nil
}

// GetAll retrieves all products with pagination
func (r *Repository) GetAll(ctx context.Context, limit, offset int) ([]Product, error) {
	query := `SELECT id, name, description, sku, price, cost, quantity, category_id, is_active, created_at, updated_at
			  FROM products ORDER BY created_at DESC LIMIT $1 OFFSET $2`

	var products []Product
	err := r.db.SelectContext(ctx, &products, query, limit, offset)
	return products, err
}

// GetBySKU retrieves a product by SKU
func (r *Repository) GetBySKU(ctx context.Context, sku string) (*Product, error) {
	query := `SELECT id, name, description, sku, price, cost, quantity, category_id, is_active, created_at, updated_at
			  FROM products WHERE sku = $1`

	var product Product
	err := r.db.GetContext(ctx, &product, query, sku)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("product not found")
		}
		return nil, err
	}

	return &product, nil
}

// Update updates a product
func (r *Repository) Update(ctx context.Context, product *Product) error {
	query := `
		UPDATE products
		SET name = $1, description = $2, sku = $3, price = $4, cost = $5,
			quantity = $6, category_id = $7, is_active = $8, updated_at = $9
		WHERE id = $10`

	product.UpdatedAt = time.Now().Format(time.RFC3339)
	result, err := r.db.ExecContext(ctx, query,
		product.Name,
		product.Description,
		product.SKU,
		product.Price,
		product.Cost,
		product.Quantity,
		product.CategoryID,
		product.IsActive,
		product.UpdatedAt,
		product.ID,
	)

	if err != nil {
		return err
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rows == 0 {
		return fmt.Errorf("product not found")
	}

	return nil
}

// Delete deletes a product
func (r *Repository) Delete(ctx context.Context, id int) error {
	query := `DELETE FROM products WHERE id = $1`

	result, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return err
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rows == 0 {
		return fmt.Errorf("product not found")
	}

	return nil
}

// UpdateQuantity updates product quantity
func (r *Repository) UpdateQuantity(ctx context.Context, id int, quantity int) error {
	query := `UPDATE products SET quantity = $1, updated_at = $2 WHERE id = $3`

	result, err := r.db.ExecContext(ctx, query, quantity, time.Now(), id)
	if err != nil {
		return err
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rows == 0 {
		return fmt.Errorf("product not found")
	}

	return nil
}

// Count returns total number of products
func (r *Repository) Count(ctx context.Context) (int, error) {
	query := `SELECT COUNT(*) FROM products`
	var count int
	err := r.db.GetContext(ctx, &count, query)
	return count, err
}
