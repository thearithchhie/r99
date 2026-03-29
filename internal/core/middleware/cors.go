package middleware

import (
	"github.com/gofiber/fiber/v2"
	fiberCors "github.com/gofiber/fiber/v2/middleware/cors"
)

// CORS returns configured CORS middleware for Fiber.
func CORS(allowedOrigins string) fiber.Handler {
	return fiberCors.New(fiberCors.Config{
		AllowOrigins:     allowedOrigins,
		AllowMethods:     "GET,POST,PUT,DELETE,OPTIONS",
		AllowHeaders:     "Origin, Content-Type, Accept, Authorization",
		AllowCredentials: false,
	})
}
