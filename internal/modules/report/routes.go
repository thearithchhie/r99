package report

import (
	"github.com/gofiber/fiber/v2"
	"github.com/jmoiron/sqlx"
)

func RegisterRoutes(app *fiber.App, db *sqlx.DB) {
	handler := NewHandler(db)

	api := app.Group("/api")
	reports := api.Group("/reports")

	reports.Get("/sales", handler.GetSalesReport)
	reports.Get("/inventory", handler.GetInventoryReport)
	reports.Get("/customers", handler.GetCustomerReport)
	reports.Get("/top-products", handler.GetTopProducts)
	reports.Get("/payment-methods", handler.GetPaymentReport)
	reports.Get("/daily-sales", handler.GetDailySales)
}