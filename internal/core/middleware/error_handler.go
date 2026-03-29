package middleware

import (
	"log"

	"github.com/gofiber/fiber/v2"
)

// ErrorHandler global error handler
func ErrorHandler() fiber.Handler {
	return func(c *fiber.Ctx) error {
		// Continue to next handler
		err := c.Next()

		// Check if there's an error
		if err != nil {
			// Log the error
			log.Printf("Error: %v", err)

			// Return error response
			code := fiber.StatusInternalServerError
			message := "Internal Server Error"

			if e, ok := err.(*fiber.Error); ok {
				code = e.Code
				message = e.Message
			}

			return c.Status(code).JSON(fiber.Map{
				"error": message,
			})
		}

		return nil
	}
}
