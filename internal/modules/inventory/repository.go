package inventory

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

// Create creates a new inventory record
func (r *Repository) Create(ctx context.Context, inventory *Inventory) error {
	query := `
		INSERT INTO inventory (product_id, quantity, reorder_level, reorder_quantity, location, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, created_at, updated_at`

	now := time.Now()
	err := r.db.QueryRowContext(ctx, query,
		inventory.ProductID,
		inventory.Quantity,
		inventory.ReorderLevel,
		inventory.ReorderQuantity,
		inventory.Location,
		now,
		now,
	).Scan(&inventory.ID, &inventory.CreatedAt, &inventory.UpdatedAt)

	return err
}

// GetByID retrieves inventory by ID
func (r *Repository) GetByID(ctx context.Context, id int) (*Inventory, error) {
	query := `SELECT id, product_id, quantity, reorder_level, reorder_quantity, last_stock_in, last_stock_out, location, created_at, updated_at
			  FROM inventory WHERE id = $1`

	var inventory Inventory
	err := r.db.GetContext(ctx, &inventory, query, id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("inventory not found")
		}
		return nil, err
	}

	return &inventory, nil
}

// GetByProductID retrieves inventory by product ID
func (r *Repository) GetByProductID(ctx context.Context, productID int) (*Inventory, error) {
	query := `SELECT id, product_id, quantity, reorder_level, reorder_quantity, last_stock_in, last_stock_out, location, created_at, updated_at
			  FROM inventory WHERE product_id = $1`

	var inventory Inventory
	err := r.db.GetContext(ctx, &inventory, query, productID)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("inventory not found")
		}
		return nil, err
	}

	return &inventory, nil
}

// GetAll retrieves all inventory with pagination
func (r *Repository) GetAll(ctx context.Context, limit, offset int) ([]Inventory, error) {
	query := `SELECT id, product_id, quantity, reorder_level, reorder_quantity, last_stock_in, last_stock_out, location, created_at, updated_at
			  FROM inventory ORDER BY created_at DESC LIMIT $1 OFFSET $2`

	var inventory []Inventory
	err := r.db.SelectContext(ctx, &inventory, query, limit, offset)
	return inventory, err
}

// GetLowStock retrieves inventory items below reorder level
func (r *Repository) GetLowStock(ctx context.Context) ([]Inventory, error) {
	query := `SELECT id, product_id, quantity, reorder_level, reorder_quantity, last_stock_in, last_stock_out, location, created_at, updated_at
			  FROM inventory WHERE quantity <= reorder_level ORDER BY quantity ASC`

	var inventory []Inventory
	err := r.db.SelectContext(ctx, &inventory, query)
	return inventory, err
}

// Update updates inventory
func (r *Repository) Update(ctx context.Context, inventory *Inventory) error {
	query := `
		UPDATE inventory
		SET quantity = $1, reorder_level = $2, reorder_quantity = $3, location = $4, updated_at = $5
		WHERE id = $6`

	inventory.UpdatedAt = time.Now().Format(time.RFC3339)
	result, err := r.db.ExecContext(ctx, query,
		inventory.Quantity,
		inventory.ReorderLevel,
		inventory.ReorderQuantity,
		inventory.Location,
		inventory.UpdatedAt,
		inventory.ID,
	)

	if err != nil {
		return err
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rows == 0 {
		return fmt.Errorf("inventory not found")
	}

	return nil
}

// AddStock adds stock to inventory
func (r *Repository) AddStock(ctx context.Context, inventoryID int, quantity int) error {
	query := `
		UPDATE inventory
		SET quantity = quantity + $1, last_stock_in = $2, updated_at = $2
		WHERE id = $3`

	now := time.Now().Format(time.RFC3339)
	result, err := r.db.ExecContext(ctx, query, quantity, now, inventoryID)
	if err != nil {
		return err
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rows == 0 {
		return fmt.Errorf("inventory not found")
	}

	return nil
}

// RemoveStock removes stock from inventory
func (r *Repository) RemoveStock(ctx context.Context, inventoryID int, quantity int) error {
	query := `
		UPDATE inventory
		SET quantity = quantity - $1, last_stock_out = $2, updated_at = $2
		WHERE id = $3 AND quantity >= $1`

	now := time.Now().Format(time.RFC3339)
	result, err := r.db.ExecContext(ctx, query, quantity, now, inventoryID)
	if err != nil {
		return err
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rows == 0 {
		return fmt.Errorf("insufficient stock or inventory not found")
	}

	return nil
}

// RecordMovement records a stock movement
func (r *Repository) RecordMovement(ctx context.Context, movement *StockMovement) error {
	query := `
		INSERT INTO stock_movements (inventory_id, quantity, type, reference, notes, created_at)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, created_at`

	movement.CreatedAt = time.Now().Format(time.RFC3339)
	err := r.db.QueryRowContext(ctx, query,
		movement.InventoryID,
		movement.Quantity,
		movement.Type,
		movement.Reference,
		movement.Notes,
		movement.CreatedAt,
	).Scan(&movement.ID)

	return err
}

// GetMovements retrieves stock movements for inventory
func (r *Repository) GetMovements(ctx context.Context, inventoryID int, limit, offset int) ([]StockMovement, error) {
	query := `SELECT id, inventory_id, quantity, type, reference, notes, created_at
			  FROM stock_movements WHERE inventory_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3`

	var movements []StockMovement
	err := r.db.SelectContext(ctx, &movements, query, inventoryID, limit, offset)
	return movements, err
}

// Delete deletes inventory
func (r *Repository) Delete(ctx context.Context, id int) error {
	query := `DELETE FROM inventory WHERE id = $1`

	result, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return err
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rows == 0 {
		return fmt.Errorf("inventory not found")
	}

	return nil
}