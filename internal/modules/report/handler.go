package report

import (
	"github.com/gofiber/fiber/v2"
	"github.com/jmoiron/sqlx"
)

type Handler struct {
	repo *Repository
}

func NewHandler(db *sqlx.DB) *Handler {
	return &Handler{
		repo: NewRepository(db),
	}
}

// GetSalesReport generates a sales report
func (h *Handler) GetSalesReport(c *fiber.Ctx) error {
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	if startDate == "" || endDate == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "start_date and end_date are required",
		})
	}

	report, err := h.repo.GetSalesReport(c.Context(), startDate, endDate)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to generate sales report",
		})
	}

	return c.JSON(report)
}

// GetInventoryReport generates an inventory report
func (h *Handler) GetInventoryReport(c *fiber.Ctx) error {
	report, err := h.repo.GetInventoryReport(c.Context())
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to generate inventory report",
		})
	}

	return c.JSON(report)
}

// GetCustomerReport generates a customer report
func (h *Handler) GetCustomerReport(c *fiber.Ctx) error {
	report, err := h.repo.GetCustomerReport(c.Context())
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to generate customer report",
		})
	}

	return c.JSON(report)
}

// GetTopProducts generates a top products report
func (h *Handler) GetTopProducts(c *fiber.Ctx) error {
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")
	limit := c.QueryInt("limit", 10)

	if startDate == "" || endDate == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "start_date and end_date are required",
		})
	}

	products, err := h.repo.GetTopProducts(c.Context(), startDate, endDate, limit)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to generate product report",
		})
	}

	return c.JSON(ProductSalesReport{
		StartDate:   startDate,
		EndDate:     endDate,
		TopProducts: products,
	})
}

// GetPaymentReport generates a payment methods report
func (h *Handler) GetPaymentReport(c *fiber.Ctx) error {
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	if startDate == "" || endDate == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "start_date and end_date are required",
		})
	}

	methods, err := h.repo.GetPaymentReport(c.Context(), startDate, endDate)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to generate payment report",
		})
	}

	return c.JSON(PaymentReport{
		StartDate:      startDate,
		EndDate:        endDate,
		PaymentMethods: methods,
	})
}

// GetDailySales generates a daily sales report
func (h *Handler) GetDailySales(c *fiber.Ctx) error {
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	if startDate == "" || endDate == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "start_date and end_date are required",
		})
	}

	dailyData, err := h.repo.GetDailySales(c.Context(), startDate, endDate)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to generate daily sales report",
		})
	}

	return c.JSON(DailySalesReport{
		StartDate:  startDate,
		EndDate:    endDate,
		DailyData:  dailyData,
	})
}