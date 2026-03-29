package product

import (
	"github.com/gofiber/fiber/v2"
	"github.com/jmoiron/sqlx"
)

func RegisterRoutes(app *fiber.App, db *sqlx.DB) {
	handler := NewHandler(db)

	api := app.Group("/api")
	products := api.Group("/products")

	products.Post("/", handler.CreateProduct)
	products.Get("/", handler.GetProducts)
	products.Get("/:id", handler.GetProduct)
	products.Put("/:id", handler.UpdateProduct)
	products.Delete("/:id", handler.DeleteProduct)
}
