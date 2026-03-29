package sale

import (
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/jmoiron/sqlx"
	appvalidator "github.com/thearithchhie/r99_shop/internal/core/validator"
)

type Handler struct {
	repo *Repository
}

func NewHandler(db *sqlx.DB) *Handler {
	return &Handler{
		repo: NewRepository(db),
	}
}

// CreateSale creates a new sale
func (h *Handler) CreateSale(c *fiber.Ctx) error {
	var req CreateSaleRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	// Validate request
	if err := appvalidator.Validate(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// TODO: Validate items and get product prices
	// For now, calculate totals
	subtotal := 0.0
	items := make([]SaleItem, len(req.Items))

	for i, item := range req.Items {
		// TODO: Get actual product price from database
		unitPrice := 0.0 // This should come from product table
		itemDiscount := item.Discount
		itemSubtotal := (unitPrice * float64(item.Quantity)) - itemDiscount

		items[i] = SaleItem{
			ProductID: item.ProductID,
			Quantity:  item.Quantity,
			UnitPrice: unitPrice,
			Discount:  itemDiscount,
			Subtotal:  itemSubtotal,
		}

		subtotal += itemSubtotal
	}

	tax := subtotal * req.TaxRate
	total := subtotal + tax - req.Discount

	sale := &Sale{
		CustomerID:     req.CustomerID,
		SaleDate:       time.Now().Format(time.RFC3339),
		Subtotal:       subtotal,
		Tax:            tax,
		Discount:       req.Discount,
		Total:          total,
		PaymentMethod:  req.PaymentMethod,
		PaymentStatus:  "pending",
		Status:         "pending",
		Notes:          req.Notes,
	}

	if err := h.repo.Create(c.Context(), sale, items); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to create sale",
		})
	}

	return c.Status(fiber.StatusCreated).JSON(sale)
}

// GetSale retrieves a sale by ID
func (h *Handler) GetSale(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid sale ID",
		})
	}

	sale, err := h.repo.GetByID(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "Sale not found",
		})
	}

	items, err := h.repo.GetItems(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve sale items",
		})
	}

	return c.JSON(fiber.Map{
		"sale":  sale,
		"items": items,
	})
}

// GetSales retrieves all sales
func (h *Handler) GetSales(c *fiber.Ctx) error {
	page := c.QueryInt("page", 1)
	limit := c.QueryInt("limit", 10)
	offset := (page - 1) * limit

	sales, err := h.repo.GetAll(c.Context(), limit, offset)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve sales",
		})
	}

	return c.JSON(sales)
}

// GetSalesByDateRange retrieves sales within a date range
func (h *Handler) GetSalesByDateRange(c *fiber.Ctx) error {
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	if startDate == "" || endDate == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "start_date and end_date are required",
		})
	}

	sales, err := h.repo.GetByDateRange(c.Context(), startDate, endDate)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve sales",
		})
	}

	return c.JSON(sales)
}

// UpdateSale updates a sale
func (h *Handler) UpdateSale(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid sale ID",
		})
	}

	var req UpdateSaleRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	// Validate request
	if err := appvalidator.Validate(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	sale, err := h.repo.GetByID(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "Sale not found",
		})
	}

	if req.PaymentMethod != nil {
		sale.PaymentMethod = *req.PaymentMethod
	}
	if req.PaymentStatus != nil {
		sale.PaymentStatus = *req.PaymentStatus
	}
	if req.Status != nil {
		sale.Status = *req.Status
	}
	if req.Notes != nil {
		sale.Notes = *req.Notes
	}

	if err := h.repo.Update(c.Context(), sale); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to update sale",
		})
	}

	return c.JSON(sale)
}

// DeleteSale deletes a sale
func (h *Handler) DeleteSale(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid sale ID",
		})
	}

	if err := h.repo.Delete(c.Context(), id); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to delete sale",
		})
	}

	return c.SendStatus(fiber.StatusNoContent)
}

// GetSalesReport retrieves sales report
func (h *Handler) GetSalesReport(c *fiber.Ctx) error {
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	if startDate == "" || endDate == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "start_date and end_date are required",
		})
	}

	report, err := h.repo.GetReport(c.Context(), startDate, endDate)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to generate report",
		})
	}

	return c.JSON(report)
}
