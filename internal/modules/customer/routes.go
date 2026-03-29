package customer

import (
	"github.com/gofiber/fiber/v2"
	"github.com/jmoiron/sqlx"
)

func RegisterRoutes(app *fiber.App, db *sqlx.DB) {
	handler := NewHandler(db)

	api := app.Group("/api")
	customers := api.Group("/customers")

	customers.Post("/", handler.CreateCustomer)
	customers.Get("/", handler.GetCustomers)
	customers.Get("/:id", handler.GetCustomer)
	customers.Put("/:id", handler.UpdateCustomer)
	customers.Delete("/:id", handler.DeleteCustomer)
}
