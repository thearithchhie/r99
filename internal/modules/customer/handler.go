package customer

import (
	"github.com/gofiber/fiber/v2"
	"github.com/jmoiron/sqlx"
	"github.com/thearithchhie/r99_shop/internal/core/validator"
)

type Handler struct {
	repo *Repository
}

func NewHandler(db *sqlx.DB) *Handler {
	return &Handler{
		repo: NewRepository(db),
	}
}

// CreateCustomer creates a new customer
func (h *Handler) CreateCustomer(c *fiber.Ctx) error {
	var req CreateCustomerRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	// Validate request
	if err := validator.Validate(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	customer := &Customer{
		Name:       req.Name,
		Email:      req.Email,
		Phone:      req.Phone,
		Address:    req.Address,
		City:       req.City,
		Country:    req.Country,
		PostalCode: req.PostalCode,
		IsActive:   true,
	}

	if err := h.repo.Create(c.Context(), customer); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to create customer",
		})
	}

	return c.Status(fiber.StatusCreated).JSON(customer)
}

// GetCustomer retrieves a customer by ID
func (h *Handler) GetCustomer(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid customer ID",
		})
	}

	customer, err := h.repo.GetByID(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "Customer not found",
		})
	}

	return c.JSON(customer)
}

// GetCustomers retrieves all customers with pagination
func (h *Handler) GetCustomers(c *fiber.Ctx) error {
	page := c.QueryInt("page", 1)
	limit := c.QueryInt("limit", 10)
	offset := (page - 1) * limit

	customers, err := h.repo.GetAll(c.Context(), limit, offset)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve customers",
		})
	}

	return c.JSON(customers)
}

// UpdateCustomer updates a customer
func (h *Handler) UpdateCustomer(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid customer ID",
		})
	}

	var req UpdateCustomerRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	// Validate request
	if err := validator.Validate(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// Get existing customer
	customer, err := h.repo.GetByID(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "Customer not found",
		})
	}

	// Update fields if provided
	if req.Name != nil {
		customer.Name = *req.Name
	}
	if req.Email != nil {
		customer.Email = *req.Email
	}
	if req.Phone != nil {
		customer.Phone = *req.Phone
	}
	if req.Address != nil {
		customer.Address = *req.Address
	}
	if req.City != nil {
		customer.City = *req.City
	}
	if req.Country != nil {
		customer.Country = *req.Country
	}
	if req.PostalCode != nil {
		customer.PostalCode = *req.PostalCode
	}
	if req.IsActive != nil {
		customer.IsActive = *req.IsActive
	}

	if err := h.repo.Update(c.Context(), customer); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to update customer",
		})
	}

	return c.JSON(customer)
}

// DeleteCustomer deletes a customer
func (h *Handler) DeleteCustomer(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid customer ID",
		})
	}

	if err := h.repo.Delete(c.Context(), id); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to delete customer",
		})
	}

	return c.SendStatus(fiber.StatusNoContent)
}
