package product

// Product represents a product in the shop
type Product struct {
	ID          int     `db:"id" json:"id"`
	Name        string  `db:"name" json:"name"`
	Description string  `db:"description" json:"description"`
	SKU         string  `db:"sku" json:"sku"`
	Price       float64 `db:"price" json:"price"`
	Cost        float64 `db:"cost" json:"cost"`
	Quantity    int     `db:"quantity" json:"quantity"`
	CategoryID  *int    `db:"category_id" json:"category_id,omitempty"`
	IsActive    bool    `db:"is_active" json:"is_active"`
	CreatedAt   string  `db:"created_at" json:"created_at"`
	UpdatedAt   string  `db:"updated_at" json:"updated_at"`
}

// CreateProductRequest represents the request to create a product
type CreateProductRequest struct {
	Name        string  `json:"name" validate:"required,min=2,max=255"`
	Description string  `json:"description" validate:"max=2000"`
	SKU         string  `json:"sku" validate:"required,min=3,max=100"`
	Price       float64 `json:"price" validate:"required,gt=0"`
	Cost        float64 `json:"cost" validate:"gte=0"`
	Quantity    int     `json:"quantity" validate:"gte=0"`
	CategoryID  *int    `json:"category_id" validate:"omitempty,gte=1"`
}

// UpdateProductRequest represents the request to update a product
type UpdateProductRequest struct {
	Name        *string `json:"name" validate:"omitempty,min=2,max=255"`
	Description *string `json:"description" validate:"omitempty,max=2000"`
	SKU         *string `json:"sku" validate:"omitempty,min=3,max=100"`
	Price       *float64 `json:"price" validate:"omitempty,gt=0"`
	Cost        *float64 `json:"cost" validate:"omitempty,gte=0"`
	Quantity    *int     `json:"quantity" validate:"omitempty,gte=0"`
	CategoryID  *int     `json:"category_id" validate:"omitempty,gte=1"`
	IsActive    *bool    `json:"is_active"`
}