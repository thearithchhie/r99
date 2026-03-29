package sale

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

// Create creates a new sale with items
func (r *Repository) Create(ctx context.Context, sale *Sale, items []SaleItem) error {
	tx, err := r.db.BeginTxx(ctx, nil)
	if err != nil {
		return err
	}

	defer tx.Rollback()

	// Create sale
	query := `
		INSERT INTO sales (customer_id, sale_date, subtotal, tax, discount, total, payment_method, payment_status, status, notes, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
		RETURNING id, created_at, updated_at`

	now := time.Now()
	err = tx.QueryRowContext(ctx, query,
		sale.CustomerID,
		sale.SaleDate,
		sale.Subtotal,
		sale.Tax,
		sale.Discount,
		sale.Total,
		sale.PaymentMethod,
		sale.PaymentStatus,
		sale.Status,
		sale.Notes,
		now,
		now,
	).Scan(&sale.ID, &sale.CreatedAt, &sale.UpdatedAt)

	if err != nil {
		return err
	}

	// Create sale items
	for i := range items {
		items[i].SaleID = sale.ID
		itemQuery := `
			INSERT INTO sale_items (sale_id, product_id, quantity, unit_price, discount, subtotal, created_at)
			VALUES ($1, $2, $3, $4, $5, $6, $7)
			RETURNING id, created_at`

		err = tx.QueryRowContext(ctx, itemQuery,
			items[i].SaleID,
			items[i].ProductID,
			items[i].Quantity,
			items[i].UnitPrice,
			items[i].Discount,
			items[i].Subtotal,
			now,
		).Scan(&items[i].ID, &items[i].CreatedAt)

		if err != nil {
			return err
		}

		// Update inventory
		_, err = tx.ExecContext(ctx,
			`UPDATE inventory SET quantity = quantity - $1, updated_at = $2
			 WHERE product_id = $3`,
			items[i].Quantity, now, items[i].ProductID,
		)

		if err != nil {
			return err
		}
	}

	return tx.Commit()
}

// GetByID retrieves a sale by ID
func (r *Repository) GetByID(ctx context.Context, id int) (*Sale, error) {
	query := `SELECT id, customer_id, sale_date, subtotal, tax, discount, total,
			  payment_method, payment_status, status, notes, created_at, updated_at
			  FROM sales WHERE id = $1`

	var sale Sale
	err := r.db.GetContext(ctx, &sale, query, id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("sale not found")
		}
		return nil, err
	}

	return &sale, nil
}

// GetItems retrieves sale items
func (r *Repository) GetItems(ctx context.Context, saleID int) ([]SaleItem, error) {
	query := `SELECT id, sale_id, product_id, quantity, unit_price, discount, subtotal, created_at
			  FROM sale_items WHERE sale_id = $1`

	var items []SaleItem
	err := r.db.SelectContext(ctx, &items, query, saleID)
	return items, err
}

// GetAll retrieves all sales with pagination
func (r *Repository) GetAll(ctx context.Context, limit, offset int) ([]Sale, error) {
	query := `SELECT id, customer_id, sale_date, subtotal, tax, discount, total,
			  payment_method, payment_status, status, notes, created_at, updated_at
			  FROM sales ORDER BY sale_date DESC LIMIT $1 OFFSET $2`

	var sales []Sale
	err := r.db.SelectContext(ctx, &sales, query, limit, offset)
	return sales, err
}

// GetByCustomerID retrieves sales by customer ID
func (r *Repository) GetByCustomerID(ctx context.Context, customerID int, limit, offset int) ([]Sale, error) {
	query := `SELECT id, customer_id, sale_date, subtotal, tax, discount, total,
			  payment_method, payment_status, status, notes, created_at, updated_at
			  FROM sales WHERE customer_id = $1 ORDER BY sale_date DESC LIMIT $2 OFFSET $3`

	var sales []Sale
	err := r.db.SelectContext(ctx, &sales, query, customerID, limit, offset)
	return sales, err
}

// GetByDateRange retrieves sales within a date range
func (r *Repository) GetByDateRange(ctx context.Context, startDate, endDate string) ([]Sale, error) {
	query := `SELECT id, customer_id, sale_date, subtotal, tax, discount, total,
			  payment_method, payment_status, status, notes, created_at, updated_at
			  FROM sales WHERE sale_date >= $1 AND sale_date <= $2 ORDER BY sale_date DESC`

	var sales []Sale
	err := r.db.SelectContext(ctx, &sales, query, startDate, endDate)
	return sales, err
}

// Update updates a sale
func (r *Repository) Update(ctx context.Context, sale *Sale) error {
	query := `
		UPDATE sales
		SET customer_id = $1, payment_method = $2, payment_status = $3, status = $4, notes = $5, updated_at = $6
		WHERE id = $7`

	sale.UpdatedAt = time.Now().Format(time.RFC3339)
	result, err := r.db.ExecContext(ctx, query,
		sale.CustomerID,
		sale.PaymentMethod,
		sale.PaymentStatus,
		sale.Status,
		sale.Notes,
		sale.UpdatedAt,
		sale.ID,
	)

	if err != nil {
		return err
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rows == 0 {
		return fmt.Errorf("sale not found")
	}

	return nil
}

// Delete deletes a sale
func (r *Repository) Delete(ctx context.Context, id int) error {
	query := `DELETE FROM sales WHERE id = $1`

	result, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return err
	}

	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rows == 0 {
		return fmt.Errorf("sale not found")
	}

	return nil
}

// GetReport retrieves sales report for a date range
func (r *Repository) GetReport(ctx context.Context, startDate, endDate string) (*SaleReport, error) {
	query := `
		SELECT
			COUNT(*) as total_sales,
			COALESCE(SUM(total), 0) as total_revenue,
			COALESCE(SUM((SELECT SUM(quantity) FROM sale_items si WHERE si.sale_id = s.id)), 0) as total_items,
			COALESCE(AVG(total), 0) as average_order
		FROM sales s
		WHERE s.sale_date >= $1 AND s.sale_date <= $2 AND s.status = 'completed'`

	var report SaleReport
	err := r.db.GetContext(ctx, &report, query, startDate, endDate)
	return &report, err
}

// Count returns total number of sales
func (r *Repository) Count(ctx context.Context) (int, error) {
	query := `SELECT COUNT(*) FROM sales`
	var count int
	err := r.db.GetContext(ctx, &count, query)
	return count, err
}