package auth

import (
	"github.com/gofiber/fiber/v2"
	"github.com/jmoiron/sqlx"
	"github.com/thearithchhie/r99_shop/internal/core/middleware"
)

// RegisterRoutes registers auth routes
func RegisterRoutes(app *fiber.App, db *sqlx.DB, jwtService *JWTService) {
	handler := NewHandler(db, jwtService)

	// Public routes
	api := app.Group("/api/auth")
	api.Post("/register", handler.Register)
	api.Post("/login", handler.Login)

	// Protected routes (require authentication)
	api.Get("/users", middleware.JWTAuth(jwtService.secretKey), handler.GetUsers)
	api.Get("/users/:id", middleware.JWTAuth(jwtService.secretKey), handler.GetUserByID)
	api.Delete("/users/:id", middleware.JWTAuth(jwtService.secretKey), handler.DeleteUser)
	api.Patch("/users/:id/toggle", middleware.JWTAuth(jwtService.secretKey), handler.ToggleUserActive)
}
