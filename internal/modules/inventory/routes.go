package inventory

import (
	"github.com/gofiber/fiber/v2"
	"github.com/jmoiron/sqlx"
)

func RegisterRoutes(app *fiber.App, db *sqlx.DB) {
	handler := NewHandler(db)

	api := app.Group("/api")
	inventory := api.Group("/inventory")

	inventory.Post("/", handler.CreateInventory)
	inventory.Get("/", handler.GetAllInventory)
	inventory.Get("/low-stock", handler.GetLowStock)
	inventory.Get("/:id", handler.GetInventory)
	inventory.Get("/product/:productId", handler.GetInventoryByProduct)
	inventory.Put("/:id", handler.UpdateInventory)
	inventory.Delete("/:id", handler.DeleteInventory)
	inventory.Post("/:id/add-stock", handler.AddStock)
	inventory.Post("/:id/remove-stock", handler.RemoveStock)
	inventory.Get("/:id/movements", handler.GetMovements)
}