package customer

// Customer represents a customer in the shop
type Customer struct {
	ID        int     `db:"id" json:"id"`
	Name      string  `db:"name" json:"name"`
	Email     string  `db:"email" json:"email"`
	Phone     string  `db:"phone" json:"phone"`
	Address   string  `db:"address" json:"address"`
	City      string  `db:"city" json:"city"`
	Country   string  `db:"country" json:"country"`
	PostalCode string `db:"postal_code" json:"postal_code"`
	IsActive  bool    `db:"is_active" json:"is_active"`
	CreatedAt string  `db:"created_at" json:"created_at"`
	UpdatedAt string  `db:"updated_at" json:"updated_at"`
}

// CreateCustomerRequest represents the request to create a customer
type CreateCustomerRequest struct {
	Name       string `json:"name" validate:"required,min=2,max=255"`
	Email      string `json:"email" validate:"required,email,max=255"`
	Phone      string `json:"phone" validate:"required,min=10,max=50"`
	Address    string `json:"address" validate:"max=500"`
	City       string `json:"city" validate:"max=100"`
	Country    string `json:"country" validate:"max=100"`
	PostalCode string `json:"postal_code" validate:"max=20"`
}

// UpdateCustomerRequest represents the request to update a customer
type UpdateCustomerRequest struct {
	Name       *string `json:"name" validate:"omitempty,min=2,max=255"`
	Email      *string `json:"email" validate:"omitempty,email,max=255"`
	Phone      *string `json:"phone" validate:"omitempty,min=10,max=50"`
	Address    *string `json:"address" validate:"omitempty,max=500"`
	City       *string `json:"city" validate:"omitempty,max=100"`
	Country    *string `json:"country" validate:"omitempty,max=100"`
	PostalCode *string `json:"postal_code" validate:"omitempty,max=20"`
	IsActive   *bool   `json:"is_active"`
}