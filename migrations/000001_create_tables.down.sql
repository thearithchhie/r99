-- Drop triggers
DROP TRIGGER IF EXISTS update_products_updated_at ON products;
DROP TRIGGER IF EXISTS update_customers_updated_at ON customers;
DROP TRIGGER IF EXISTS update_inventory_updated_at ON inventory;
DROP TRIGGER IF EXISTS update_sales_updated_at ON sales;

-- Drop function
DROP FUNCTION IF EXISTS update_updated_at_column();

-- Drop indexes
DROP INDEX IF EXISTS idx_stock_movements_date;
DROP INDEX IF EXISTS idx_stock_movements_inventory;
DROP INDEX IF EXISTS idx_sale_items_product;
DROP INDEX IF EXISTS idx_sale_items_sale;
DROP INDEX IF EXISTS idx_sales_date;
DROP INDEX IF EXISTS idx_sales_customer;
DROP INDEX IF EXISTS idx_inventory_product;
DROP INDEX IF EXISTS idx_customers_email;
DROP INDEX IF EXISTS idx_products_category;
DROP INDEX IF EXISTS idx_products_sku;

-- Drop tables
DROP TABLE IF EXISTS stock_movements;
DROP TABLE IF EXISTS sale_items;
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;