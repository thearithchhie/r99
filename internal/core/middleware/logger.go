package middleware

import (
	"log"
	"time"

	"github.com/gofiber/fiber/v2"
)

// Logger middleware for request logging
func Logger() fiber.Handler {
	return func(c *fiber.Ctx) error {
		start := time.Now()
		path := c.Path()
		method := c.Method()

		err := c.Next()

		duration := time.Since(start)
		status := c.Response().StatusCode()

		log.Printf("[%s] %s %s - Status: %d - Duration: %v",
			time.Now().Format("2006-01-02 15:04:05"),
			method,
			path,
			status,
			duration,
		)

		return err
	}
}
