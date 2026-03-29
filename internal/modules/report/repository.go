package report

import (
	"context"
	"github.com/jmoiron/sqlx"
)

type Repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{db: db}
}

// GetSalesReport generates a sales report for a date range
func (r *Repository) GetSalesReport(ctx context.Context, startDate, endDate string) (*SalesReport, error) {
	query := `
		SELECT
			COUNT(*) as total_sales,
			COALESCE(SUM(total), 0) as total_revenue,
			COALESCE(SUM(tax), 0) as total_tax,
			COALESCE(SUM(discount), 0) as total_discount,
			COALESCE(AVG(total), 0) as average_order
		FROM sales
		WHERE sale_date >= $1 AND sale_date <= $2`

	var report SalesReport
	err := r.db.GetContext(ctx, &report, query, startDate, endDate)
	if err != nil {
		return nil, err
	}

	report.StartDate = startDate
	report.EndDate = endDate

	return &report, nil
}

// GetInventoryReport generates an inventory report
func (r *Repository) GetInventoryReport(ctx context.Context) (*InventoryReport, error) {
	query := `
		SELECT
			COUNT(*) as total_products,
			COALESCE(SUM(quantity * cost), 0) as total_value,
			COUNT(CASE WHEN quantity <= reorder_level AND quantity > 0 THEN 1 END) as low_stock_items,
			COUNT(CASE WHEN quantity = 0 THEN 1 END) as out_of_stock_items
		FROM products p
		LEFT JOIN inventory i ON p.id = i.product_id`

	var report InventoryReport
	err := r.db.GetContext(ctx, &report, query)
	return &report, err
}

// GetCustomerReport generates a customer report
func (r *Repository) GetCustomerReport(ctx context.Context) (*CustomerReport, error) {
	query := `
		SELECT
			COUNT(*) as total_customers,
			COUNT(CASE WHEN is_active = true THEN 1 END) as active_customers
		FROM customers`

	var report CustomerReport
	err := r.db.GetContext(ctx, &report, query)
	if err != nil {
		return nil, err
	}

	// Get total purchases and average spending
	salesQuery := `
		SELECT
			COALESCE(COUNT(*), 0) as total_purchases,
			COALESCE(AVG(total), 0) as average_spending
		FROM sales`
	err = r.db.GetContext(ctx, &report, salesQuery)

	return &report, err
}

// GetTopProducts generates a product sales report
func (r *Repository) GetTopProducts(ctx context.Context, startDate, endDate string, limit int) ([]TopProduct, error) {
	query := `
		SELECT
			p.id as product_id,
			p.name as product_name,
			COALESCE(SUM(si.quantity), 0) as total_sold,
			COALESCE(SUM(si.subtotal), 0) as revenue
		FROM products p
		LEFT JOIN sale_items si ON p.id = si.product_id
		LEFT JOIN sales s ON si.sale_id = s.id
		WHERE s.sale_date >= $1 AND s.sale_date <= $2
		GROUP BY p.id, p.name
		ORDER BY total_sold DESC
		LIMIT $3`

	var products []TopProduct
	err := r.db.SelectContext(ctx, &products, query, startDate, endDate, limit)
	return products, err
}

// GetPaymentReport generates a payment methods report
func (r *Repository) GetPaymentReport(ctx context.Context, startDate, endDate string) ([]RevenueByPaymentMethod, error) {
	query := `
		SELECT
			payment_method,
			COALESCE(SUM(total), 0) as total_revenue,
			COUNT(*) as count
		FROM sales
		WHERE sale_date >= $1 AND sale_date <= $2
		GROUP BY payment_method
		ORDER BY total_revenue DESC`

	var methods []RevenueByPaymentMethod
	err := r.db.SelectContext(ctx, &methods, query, startDate, endDate)
	return methods, err
}

// GetDailySales generates a daily sales report
func (r *Repository) GetDailySales(ctx context.Context, startDate, endDate string) ([]DailySale, error) {
	query := `
		SELECT
			DATE(sale_date) as date,
			COUNT(*) as total_sales,
			COALESCE(SUM(total), 0) as revenue
		FROM sales
		WHERE sale_date >= $1 AND sale_date <= $2
		GROUP BY DATE(sale_date)
		ORDER BY date ASC`

	var dailyData []DailySale
	err := r.db.SelectContext(ctx, &dailyData, query, startDate, endDate)
	return dailyData, err
}