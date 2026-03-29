.PHONY: run build clean test killport

# Run the application
run:
	gow run cmd/api/main.go

# Kill process using port 3000
killport:
	@lsof -ti:3000 | xargs kill -9 2>/dev/null || echo "Port 3000 is free"

# Build the application
build:
	go build -o bin/r99-shop cmd/api/main.go

# Clean build artifacts
clean:
	rm -rf bin/

# Run tests
test:
	go test ./...

# Install dependencies
deps:
	go mod download
	go mod tidy

# Database migration (manual)
# Migrations are run automatically on startup