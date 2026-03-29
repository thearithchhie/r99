package inventory

// Inventory represents inventory items
type Inventory struct {
	ID              int     `db:"id" json:"id"`
	ProductID       int     `db:"product_id" json:"product_id"`
	Quantity        int     `db:"quantity" json:"quantity"`
	ReorderLevel    int     `db:"reorder_level" json:"reorder_level"`
	ReorderQuantity int     `db:"reorder_quantity" json:"reorder_quantity"`
	LastStockIn     *string `db:"last_stock_in" json:"last_stock_in,omitempty"`
	LastStockOut    *string `db:"last_stock_out" json:"last_stock_out,omitempty"`
	Location        string  `db:"location" json:"location"`
	CreatedAt       string  `db:"created_at" json:"created_at"`
	UpdatedAt       string  `db:"updated_at" json:"updated_at"`
}

// StockMovement represents a stock movement
type StockMovement struct {
	ID          int     `db:"id" json:"id"`
	InventoryID int     `db:"inventory_id" json:"inventory_id"`
	Quantity    int     `db:"quantity" json:"quantity"`
	Type        string  `db:"type" json:"type"` // "in" or "out"
	Reference   string  `db:"reference" json:"reference"`
	Notes       string  `db:"notes" json:"notes"`
	CreatedAt   string  `db:"created_at" json:"created_at"`
}

// AddStockRequest represents the request to add stock
type AddStockRequest struct {
	Quantity  int    `json:"quantity" validate:"required,gt=0"`
	Reference string `json:"reference" validate:"max=255"`
	Notes     string `json:"notes" validate:"max=1000"`
}

// RemoveStockRequest represents the request to remove stock
type RemoveStockRequest struct {
	Quantity  int    `json:"quantity" validate:"required,gt=0"`
	Reference string `json:"reference" validate:"max=255"`
	Notes     string `json:"notes" validate:"max=1000"`
}

// CreateInventoryRequest represents the request to create inventory
type CreateInventoryRequest struct {
	ProductID       int    `json:"product_id" validate:"required,gte=1"`
	Quantity        int    `json:"quantity" validate:"gte=0"`
	ReorderLevel    int    `json:"reorder_level" validate:"gte=0"`
	ReorderQuantity int    `json:"reorder_quantity" validate:"gte=0"`
	Location        string `json:"location" validate:"max=100"`
}

// UpdateInventoryRequest represents the request to update inventory
type UpdateInventoryRequest struct {
	Quantity        *int    `json:"quantity" validate:"omitempty,gte=0"`
	ReorderLevel    *int    `json:"reorder_level" validate:"omitempty,gte=0"`
	ReorderQuantity *int    `json:"reorder_quantity" validate:"omitempty,gte=0"`
	Location        *string `json:"location" validate:"omitempty,max=100"`
}