# R99 Shop API

A comprehensive shop management system built with Go, Fiber, and PostgreSQL.

## Features

- **Product Management**: CRUD operations for products with SKU tracking
- **Customer Management**: Customer database with contact information
- **Inventory Management**: Stock control with low stock alerts
- **Sales Processing**: Complete sales workflow with payment tracking
- **Reporting**: Comprehensive sales, inventory, and customer reports

## Tech Stack

- **Go 1.25+**
- **Fiber v2** - High-performance web framework
- **PostgreSQL** - Database (with sqlx)
- **golang-migrate** - Database migration tool
- **go-playground/validator/v10** - Request validation
- **JWT** - Authentication (prepared)

## Project Structure

```
├── cmd/api/main.go           # Application entry point
├── internal/
│   ├── core/
│   │   ├── config/           # Configuration management
│   │   ├── database/         # Database connection and migrations
│   │   └── middleware/       # HTTP middleware (CORS, Auth, Logger)
│   └── modules/
│       ├── product/          # Product module
│       ├── customer/         # Customer module
│       ├── inventory/        # Inventory module
│       ├── sale/             # Sale module
│       └── report/           # Report module
├── migrations/               # Database migrations
└── go.mod

## Getting Started

### Prerequisites

- Go 1.25+
- PostgreSQL 12+
- golang-migrate (optional, for manual migrations)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd r99_shop
```

2. Install dependencies:
```bash
go mod download
```

3. Create `.env` file:
```bash
cp .env.example .env
```

4. Update `.env` with your configuration:
```env
SERVER_PORT=3000
SERVER_HOST=localhost

DB_DRIVER=postgres
DB_HOST=localhost
DB_PORT=5432
DB_NAME=r99_shop
DB_USER=postgres
DB_PASSWORD=postgres
DB_SSLMODE=disable

JWT_SECRET=your-secret-key-change-this-in-production
JWT_EXPIRATION=24
```

5. Create database:
```bash
createdb r99_shop
```

6. Run the application (migrations will run automatically):
```bash
go run cmd/api/main.go
```

The API will be available at `http://localhost:3000`

### Using Makefile

Alternatively, use the provided Makefile:

```bash
# Install dependencies
make deps

# Run the application
make run

# Build the application
make build

# Clean build artifacts
make clean
```

### Manual Migrations (Optional)

If you want to run migrations manually using golang-migrate CLI:

```bash
# Install golang-migrate
# Follow instructions at: https://github.com/golang-migrate/migrate

# Run up migrations
migrate -path migrations -database "postgres://postgres:postgres@localhost:5432/r99_shop?sslmode=disable" up

# Run down migrations
migrate -path migrations -database "postgres://postgres:postgres@localhost:5432/r99_shop?sslmode=disable" down
```

## API Endpoints

### Health Check
- `GET /health` - Health check endpoint

### Products
- `POST /api/products` - Create product
- `GET /api/products` - List products (with pagination)
- `GET /api/products/:id` - Get product by ID
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product

### Customers
- `POST /api/customers` - Create customer
- `GET /api/customers` - List customers (with pagination)
- `GET /api/customers/:id` - Get customer by ID
- `PUT /api/customers/:id` - Update customer
- `DELETE /api/customers/:id` - Delete customer

### Inventory
- `POST /api/inventory` - Create inventory record
- `GET /api/inventory` - List all inventory
- `GET /api/inventory/low-stock` - Get low stock items
- `GET /api/inventory/:id` - Get inventory by ID
- `GET /api/inventory/product/:productId` - Get inventory by product
- `PUT /api/inventory/:id` - Update inventory
- `DELETE /api/inventory/:id` - Delete inventory
- `POST /api/inventory/:id/add-stock` - Add stock
- `POST /api/inventory/:id/remove-stock` - Remove stock
- `GET /api/inventory/:id/movements` - Get stock movements

### Sales
- `POST /api/sales` - Create sale
- `GET /api/sales` - List sales (with pagination)
- `GET /api/sales/:id` - Get sale by ID
- `GET /api/sales/date-range` - Get sales by date range
- `PUT /api/sales/:id` - Update sale
- `DELETE /api/sales/:id` - Delete sale

### Reports
- `GET /api/reports/sales` - Sales report
- `GET /api/reports/inventory` - Inventory report
- `GET /api/reports/customers` - Customer report
- `GET /api/reports/top-products` - Top selling products
- `GET /api/reports/payment-methods` - Payment methods report
- `GET /api/reports/daily-sales` - Daily sales report

## Database Schema

The application includes the following main tables:
- `products` - Product catalog
- `customers` - Customer information
- `inventory` - Stock management
- `sales` - Sales transactions
- `sale_items` - Line items for sales
- `stock_movements` - Inventory movement tracking

## Development

### Running Tests
```bash
go test ./...
```

### Building
```bash
go build -o r99-shop cmd/api/main.go
```

## Validation

All API requests are validated using **go-playground/validator/v10**. See [docs/VALIDATION.md](docs/VALIDATION.md) for detailed validation rules and examples.

**Quick validation examples:**
- Required fields return `400 Bad Request`
- Email validation ensures proper email format
- Numbers must be greater than zero where required
- Payment methods must match allowed values (cash, card, credit, transfer)
- String lengths are enforced (min/max)

## API Documentation

### Validation Errors

Invalid requests return detailed error messages:

```json
{
  "error": "validation failed: email must be a valid email, phone is required"
}
```

### Sample Requests

**Create Customer:**
```bash
curl -X POST http://localhost:3000/api/customers \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890"
  }'
```

**Create Product:**
```bash
curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Product Name",
    "sku": "PROD-001",
    "price": 29.99,
    "quantity": 100
  }'
```

**Create Sale:**
```bash
curl -X POST http://localhost:3000/api/sales \
  -H "Content-Type: application/json" \
  -d '{
    "payment_method": "card",
    "items": [{"product_id": 1, "quantity": 2}],
    "tax_rate": 0.1
  }'
```

## License

MIT License
