package sale

// Sale represents a sale transaction
type Sale struct {
	ID          int        `db:"id" json:"id"`
	CustomerID  *int       `db:"customer_id" json:"customer_id,omitempty"`
	SaleDate    string     `db:"sale_date" json:"sale_date"`
	Subtotal    float64    `db:"subtotal" json:"subtotal"`
	Tax         float64    `db:"tax" json:"tax"`
	Discount    float64    `db:"discount" json:"discount"`
	Total       float64    `db:"total" json:"total"`
	PaymentMethod string  `db:"payment_method" json:"payment_method"`
	PaymentStatus string  `db:"payment_status" json:"payment_status"`
	Status      string     `db:"status" json:"status"` // pending, completed, cancelled
	Notes       string     `db:"notes" json:"notes"`
	CreatedAt   string     `db:"created_at" json:"created_at"`
	UpdatedAt   string     `db:"updated_at" json:"updated_at"`
}

// SaleItem represents an item in a sale
type SaleItem struct {
	ID          int     `db:"id" json:"id"`
	SaleID      int     `db:"sale_id" json:"sale_id"`
	ProductID   int     `db:"product_id" json:"product_id"`
	Quantity    int     `db:"quantity" json:"quantity"`
	UnitPrice   float64 `db:"unit_price" json:"unit_price"`
	Discount    float64 `db:"discount" json:"discount"`
	Subtotal    float64 `db:"subtotal" json:"subtotal"`
	CreatedAt   string  `db:"created_at" json:"created_at"`
}

// CreateSaleRequest represents the request to create a sale
type CreateSaleRequest struct {
	CustomerID     *int                     `json:"customer_id" validate:"omitempty,gte=1"`
	PaymentMethod  string                   `json:"payment_method" validate:"required,oneof=cash card credit transfer"`
	Items          []CreateSaleItemRequest  `json:"items" validate:"required,min=1,dive"`
	Discount       float64                  `json:"discount" validate="gte=0"`
	TaxRate        float64                  `json:"tax_rate" validate="gte=0,lte=1"`
	Notes          string                   `json:"notes" validate:"max=1000"`
}

// CreateSaleItemRequest represents an item in a sale
type CreateSaleItemRequest struct {
	ProductID int     `json:"product_id" validate:"required,gte=1"`
	Quantity  int     `json:"quantity" validate:"required,gt=0"`
	Discount  float64 `json:"discount" validate="gte=0"`
}

// UpdateSaleRequest represents the request to update a sale
type UpdateSaleRequest struct {
	CustomerID     *int    `json:"customer_id" validate:"omitempty,gte=1"`
	PaymentMethod *string  `json:"payment_method" validate:"omitempty,oneof=cash card credit transfer"`
	PaymentStatus *string  `json:"payment_status" validate:"omitempty,oneof=pending paid failed refunded"`
	Status        *string  `json:"status" validate:"omitempty,oneof=pending completed cancelled"`
	Notes         *string  `json:"notes" validate:"omitempty,max=1000"`
}

// SaleReport represents a sales report
type SaleReport struct {
	TotalSales     float64 `json:"total_sales"`
	TotalRevenue   float64 `json:"total_revenue"`
	TotalItems     int     `json:"total_items"`
	AverageOrder   float64 `json:"average_order"`
}