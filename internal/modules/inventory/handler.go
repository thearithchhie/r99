package inventory

import (
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

// CreateInventory creates a new inventory record
func (h *Handler) CreateInventory(c *fiber.Ctx) error {
	var req CreateInventoryRequest
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

	inventory := &Inventory{
		ProductID:       req.ProductID,
		Quantity:        req.Quantity,
		ReorderLevel:    req.ReorderLevel,
		ReorderQuantity: req.ReorderQuantity,
		Location:        req.Location,
	}

	if err := h.repo.Create(c.Context(), inventory); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to create inventory",
		})
	}

	return c.Status(fiber.StatusCreated).JSON(inventory)
}

// GetInventory retrieves inventory by ID
func (h *Handler) GetInventory(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid inventory ID",
		})
	}

	inventory, err := h.repo.GetByID(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "Inventory not found",
		})
	}

	return c.JSON(inventory)
}

// GetInventoryByProduct retrieves inventory by product ID
func (h *Handler) GetInventoryByProduct(c *fiber.Ctx) error {
	productID, err := c.ParamsInt("productId")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid product ID",
		})
	}

	inventory, err := h.repo.GetByProductID(c.Context(), productID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "Inventory not found",
		})
	}

	return c.JSON(inventory)
}

// GetAllInventory retrieves all inventory
func (h *Handler) GetAllInventory(c *fiber.Ctx) error {
	page := c.QueryInt("page", 1)
	limit := c.QueryInt("limit", 10)
	offset := (page - 1) * limit

	inventory, err := h.repo.GetAll(c.Context(), limit, offset)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve inventory",
		})
	}

	return c.JSON(inventory)
}

// GetLowStock retrieves low stock items
func (h *Handler) GetLowStock(c *fiber.Ctx) error {
	inventory, err := h.repo.GetLowStock(c.Context())
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve low stock items",
		})
	}

	return c.JSON(inventory)
}

// AddStock adds stock to inventory
func (h *Handler) AddStock(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid inventory ID",
		})
	}

	var req AddStockRequest
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

	if err := h.repo.AddStock(c.Context(), id, req.Quantity); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to add stock",
		})
	}

	// Record movement
	movement := &StockMovement{
		InventoryID: id,
		Quantity:    req.Quantity,
		Type:        "in",
		Reference:   req.Reference,
		Notes:       req.Notes,
	}
	_ = h.repo.RecordMovement(c.Context(), movement)

	return c.JSON(fiber.Map{
		"message": "Stock added successfully",
	})
}

// RemoveStock removes stock from inventory
func (h *Handler) RemoveStock(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid inventory ID",
		})
	}

	var req RemoveStockRequest
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

	if err := h.repo.RemoveStock(c.Context(), id, req.Quantity); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// Record movement
	movement := &StockMovement{
		InventoryID: id,
		Quantity:    req.Quantity,
		Type:        "out",
		Reference:   req.Reference,
		Notes:       req.Notes,
	}
	_ = h.repo.RecordMovement(c.Context(), movement)

	return c.JSON(fiber.Map{
		"message": "Stock removed successfully",
	})
}

// GetMovements retrieves stock movements
func (h *Handler) GetMovements(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid inventory ID",
		})
	}

	page := c.QueryInt("page", 1)
	limit := c.QueryInt("limit", 10)
	offset := (page - 1) * limit

	movements, err := h.repo.GetMovements(c.Context(), id, limit, offset)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to retrieve movements",
		})
	}

	return c.JSON(movements)
}

// UpdateInventory updates inventory
func (h *Handler) UpdateInventory(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid inventory ID",
		})
	}

	var req UpdateInventoryRequest
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

	inventory, err := h.repo.GetByID(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "Inventory not found",
		})
	}

	if req.Quantity != nil {
		inventory.Quantity = *req.Quantity
	}
	if req.ReorderLevel != nil {
		inventory.ReorderLevel = *req.ReorderLevel
	}
	if req.ReorderQuantity != nil {
		inventory.ReorderQuantity = *req.ReorderQuantity
	}
	if req.Location != nil {
		inventory.Location = *req.Location
	}

	if err := h.repo.Update(c.Context(), inventory); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to update inventory",
		})
	}

	return c.JSON(inventory)
}

// DeleteInventory deletes inventory
func (h *Handler) DeleteInventory(c *fiber.Ctx) error {
	id, err := c.ParamsInt("id")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid inventory ID",
		})
	}

	if err := h.repo.Delete(c.Context(), id); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to delete inventory",
		})
	}

	return c.SendStatus(fiber.StatusNoContent)
}