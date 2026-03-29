package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/thearithchhie/r99_shop/internal/core/config"
	"github.com/thearithchhie/r99_shop/internal/core/database"
	"github.com/thearithchhie/r99_shop/internal/core/middleware"
	"github.com/thearithchhie/r99_shop/internal/modules/auth"
	"github.com/thearithchhie/r99_shop/internal/modules/customer"
	"github.com/thearithchhie/r99_shop/internal/modules/inventory"
	"github.com/thearithchhie/r99_shop/internal/modules/product"
	"github.com/thearithchhie/r99_shop/internal/modules/report"
	"github.com/thearithchhie/r99_shop/internal/modules/sale"
)

func main() {
	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	// Initialize database
	if err := database.Init(cfg); err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}
	defer database.Close()

	// Run migrations
	if err := database.Migrate(cfg); err != nil {
		log.Printf("Warning: Failed to run migrations: %v", err)
	}

	// Create Fiber app
	app := fiber.New(fiber.Config{
		AppName:      "R99 Shop API",
		ServerHeader: "R99 Shop",
		ErrorHandler: func(c *fiber.Ctx, err error) error {
			code := fiber.StatusInternalServerError
			if e, ok := err.(*fiber.Error); ok {
				code = e.Code
			}
			return c.Status(code).JSON(fiber.Map{
				"error": err.Error(),
			})
		},
	})

	// Middleware
	app.Use(recover.New())
	app.Use(middleware.Logger())
	app.Use(middleware.ErrorHandler())
	app.Use(middleware.CORS(cfg.CORS.AllowedOrigins))

	// Health check
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"status": "healthy",
			"database": "connected",
		})
	})

	// Register module routes
	db := database.GetDB()

	// Initialize JWT service
	jwtService := auth.NewJWTService(cfg.JWT.Secret, cfg.JWT.Expiration)

	// Register routes
	auth.RegisterRoutes(app, db, jwtService)
	product.RegisterRoutes(app, db)
	customer.RegisterRoutes(app, db)
	inventory.RegisterRoutes(app, db)
	sale.RegisterRoutes(app, db)
	report.RegisterRoutes(app, db)

	// Start server
	addr := fmt.Sprintf("%s:%s", cfg.Server.Host, cfg.Server.Port)
	log.Printf("Starting server on %s", addr)

	// Graceful shutdown
	go func() {
		if err := app.Listen(addr); err != nil {
			log.Fatalf("Failed to start server: %v", err)
		}
	}()

	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)
	<-quit

	log.Println("Shutting down server...")
	if err := app.Shutdown(); err != nil {
		log.Fatalf("Error during server shutdown: %v", err)
	}

	log.Println("Server stopped gracefully")
}
