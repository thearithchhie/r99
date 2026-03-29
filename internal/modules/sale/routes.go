package sale

import (
	"github.com/gofiber/fiber/v2"
	"github.com/jmoiron/sqlx"
)

func RegisterRoutes(app *fiber.App, db *sqlx.DB) {
	handler := NewHandler(db)

	api := app.Group("/api")
	sales := api.Group("/sales")

	sales.Post("/", handler.CreateSale)
	sales.Get("/", handler.GetSales)
	sales.Get("/report", handler.GetSalesReport)
	sales.Get("/date-range", handler.GetSalesByDateRange)
	sales.Get("/:id", handler.GetSale)
	sales.Put("/:id", handler.UpdateSale)
	sales.Delete("/:id", handler.DeleteSale)
}