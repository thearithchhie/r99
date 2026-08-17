# R99 Admin — PostgreSQL Database Schema

Full schema reference for the r99_admin backend. All tables, columns, relationships, and sample data.

---

## Overview

| Group | Tables |
|---|---|
| Auth & Access | `roles`, `permissions`, `role_permissions`, `users`, `user_permissions`, `sessions` |
| Customers | `customers` |
| Catalogue | `product_categories`, `product_lines`, `product_models`, `model_variants`, `model_variant_images`, `products` |
| Stock | `stock_levels`, `stock_movements` |
| E-Commerce Orders | `orders`, `order_items` |
| Marketing | `discounts` |
| Delivery | `drivers`, `shop_orders`, `shop_order_items`, `driver_settlements`, `delivery_products` |
| Audit | `activity_logs` |

---

## ENUMs

```sql
CREATE TYPE user_role AS ENUM ('owner', 'manager', 'staff', 'viewer');

CREATE TYPE customer_status AS ENUM ('active', 'inactive');

CREATE TYPE product_status AS ENUM ('in_stock', 'low_stock', 'out_of_stock');

-- Reason for every stock change
CREATE TYPE stock_reason AS ENUM (
  'initial',    -- first entry when product/variant is created
  'purchase',   -- new stock received from supplier
  'sale',       -- deducted when order is placed
  'return',     -- customer returned item, stock restored
  'adjustment', -- manual correction by admin
  'damage',     -- item damaged or written off
  'import'      -- bulk imported from external source
);

CREATE TYPE order_status AS ENUM ('Paid', 'Processing', 'Shipped', 'Delivered', 'Refunded');

CREATE TYPE shop_order_status AS ENUM ('pending', 'delivered', 'failed', 'returned');

CREATE TYPE item_outcome AS ENUM ('delivered', 'returned', 'exchanged');

CREATE TYPE discount_type AS ENUM ('percentage', 'fixed', 'shipping');

CREATE TYPE driver_status AS ENUM ('active', 'inactive');

CREATE TYPE activity_type AS ENUM ('users', 'orders', 'products', 'stock', 'discounts', 'log');

CREATE TYPE permission_group AS ENUM (
  'Dashboard', 'Orders', 'Products', 'Catalogue',
  'Customers', 'Reports', 'Marketing', 'Team', 'Settings'
);
```

---

## Auth & Access Control

### `roles`

Defines the 4 access levels in the system.

```sql
CREATE TABLE roles (
  id          SERIAL PRIMARY KEY,
  name        user_role UNIQUE NOT NULL,
  description TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

| Column | Type | Description |
|---|---|---|
| `id` | SERIAL | Auto-increment primary key |
| `name` | user_role | One of: `owner`, `manager`, `staff`, `viewer` |
| `description` | TEXT | Human-readable description of the role |

**Sample data:**

| id | name | description |
|---|---|---|
| 1 | owner | Full system access, can manage team and settings |
| 2 | manager | Can manage orders, products, stock, customers |
| 3 | staff | Can view and process orders, limited edits |
| 4 | viewer | Read-only access across all sections |

---

### `permissions`

Individual capability keys. Each represents one action in the UI (e.g. "can export orders").

```sql
CREATE TABLE permissions (
  id         SERIAL PRIMARY KEY,
  key        VARCHAR(100)     UNIQUE NOT NULL,
  label      VARCHAR(150)     NOT NULL,
  grp        permission_group NOT NULL,
  created_at TIMESTAMPTZ      NOT NULL DEFAULT now()
);
```

| Column | Type | Description |
|---|---|---|
| `key` | VARCHAR | Unique machine key, e.g. `orders.export` |
| `label` | VARCHAR | Human label shown in the UI |
| `grp` | permission_group | Groups permissions by section in settings UI |

**Sample data:**

| id | key | label | grp |
|---|---|---|---|
| 1 | orders.view | View Orders | Orders |
| 2 | orders.export | Export Orders | Orders |
| 3 | orders.print | Print Invoices | Orders |
| 4 | products.create | Create Products | Products |
| 5 | stock.adjust | Adjust Stock | Products |
| 6 | team.manage | Manage Team | Team |

---

### `role_permissions`

Maps which permissions belong to each role.

```sql
CREATE TABLE role_permissions (
  role_id       INTEGER NOT NULL REFERENCES roles(id)       ON DELETE CASCADE,
  permission_id INTEGER NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
  PRIMARY KEY (role_id, permission_id)
);
```

**Sample data** (owner gets everything, viewer gets only view permissions):

| role_id | permission_id |
|---|---|
| 1 (owner) | 1 (orders.view) |
| 1 (owner) | 2 (orders.export) |
| 1 (owner) | 6 (team.manage) |
| 4 (viewer) | 1 (orders.view) |

---

### `users`

Admin staff accounts. Each user has one role.

```sql
CREATE TABLE users (
  id            UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  name          VARCHAR(255) NOT NULL,
  email         VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role_id       INTEGER      NOT NULL REFERENCES roles(id),
  last_login_at TIMESTAMPTZ,
  created_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ  NOT NULL DEFAULT now()
);
```

| Column | Type | Description |
|---|---|---|
| `id` | UUID | Auto-generated primary key |
| `email` | VARCHAR | Login email, must be unique |
| `password_hash` | VARCHAR | bcrypt hash — never store plain text |
| `role_id` | INTEGER | FK to `roles` |
| `last_login_at` | TIMESTAMPTZ | Updated on every successful login |

**Sample data:**

| id | name | email | role_id |
|---|---|---|---|
| uuid-1 | Thearith | thearith@r99.com | 1 (owner) |
| uuid-2 | Sreymom | sreymom@r99.com | 2 (manager) |
| uuid-3 | Dara | dara@r99.com | 3 (staff) |

---

### `user_permissions`

Per-user permission overrides on top of their role. Lets you grant or deny a specific permission to one user without changing their role.

```sql
CREATE TABLE user_permissions (
  user_id       UUID    NOT NULL REFERENCES users(id)       ON DELETE CASCADE,
  permission_id INTEGER NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
  granted       BOOLEAN NOT NULL,
  PRIMARY KEY (user_id, permission_id)
);
```

| Column | Type | Description |
|---|---|---|
| `granted` | BOOLEAN | `true` = grant even if role lacks it. `false` = deny even if role has it |

**Example:** Staff user Dara is temporarily allowed to export orders:

| user_id | permission_id | granted |
|---|---|---|
| uuid-3 (Dara) | 2 (orders.export) | true |

---

### `sessions`

Active login tokens. Expired sessions can be cleaned up by a cron job.

```sql
CREATE TABLE sessions (
  id         UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token      VARCHAR(512) UNIQUE NOT NULL,
  expires_at TIMESTAMPTZ  NOT NULL,
  created_at TIMESTAMPTZ  NOT NULL DEFAULT now()
);
```

| Column | Type | Description |
|---|---|---|
| `token` | VARCHAR | JWT or opaque token string |
| `expires_at` | TIMESTAMPTZ | Token is invalid after this time |

---

## Customers

### `customers`

End customers who place e-commerce orders.

```sql
CREATE TABLE customers (
  id         UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
  name       VARCHAR(255)    NOT NULL,
  email      VARCHAR(255)    UNIQUE NOT NULL,
  status     customer_status NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ     NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ     NOT NULL DEFAULT now()
);
```

**Sample data:**

| id | name | email | status |
|---|---|---|---|
| uuid-c1 | Sophea Chan | sophea@gmail.com | active |
| uuid-c2 | Bunna Keo | bunna@gmail.com | active |
| uuid-c3 | Maly Nhem | maly@gmail.com | inactive |

---

## Product Catalogue

### `product_categories`

Top-level groupings for products.

```sql
CREATE TABLE product_categories (
  id   SERIAL PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL
);
```

**Sample data:**

| id | name |
|---|---|
| 1 | Women |
| 2 | Men |
| 3 | Accessories |
| 4 | Outerwear |

---

### `product_lines`

Style/collection lines within the catalogue.

```sql
CREATE TABLE product_lines (
  id   SERIAL PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL
);
```

**Sample data:**

| id | name |
|---|---|
| 1 | Shirting |
| 2 | Knitwear |
| 3 | Tailoring |
| 4 | Outerwear |
| 5 | Essentials |
| 6 | Occasion |

---

### `product_models`

A garment template that groups multiple size × color variants under one parent. For example "Floral Blouse" is a model — each size/color combination is a variant.

```sql
CREATE TABLE product_models (
  id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  name        VARCHAR(255) NOT NULL,
  description TEXT,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);
```

**Sample data:**

| id | name | description |
|---|---|---|
| uuid-m1 | Floral Blouse | Lightweight cotton blouse with floral print |
| uuid-m2 | Classic Linen Shirt | Relaxed fit linen, available in neutral tones |

---

### `model_variants`

Each unique size × color combination under a model. Stock is NOT stored here — it lives in `stock_levels`.

```sql
CREATE TABLE model_variants (
  id         UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id   UUID         NOT NULL REFERENCES product_models(id) ON DELETE CASCADE,
  size       VARCHAR(20)  NOT NULL,
  color      VARCHAR(50)  NOT NULL,
  created_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
  UNIQUE (model_id, size, color)
);
```

**Sample data** (variants of Floral Blouse):

| id | model_id | size | color |
|---|---|---|---|
| uuid-v1 | uuid-m1 | S | White |
| uuid-v2 | uuid-m1 | M | White |
| uuid-v3 | uuid-m1 | S | Pink |
| uuid-v4 | uuid-m1 | M | Pink |

---

### `model_variant_images`

Ordered photos for each variant. Multiple images per variant, sorted by `sort_order`.

```sql
CREATE TABLE model_variant_images (
  id         UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  variant_id UUID          NOT NULL REFERENCES model_variants(id) ON DELETE CASCADE,
  url        VARCHAR(1000) NOT NULL,
  sort_order SMALLINT      NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ   NOT NULL DEFAULT now()
);
```

**Sample data:**

| variant_id | url | sort_order |
|---|---|---|
| uuid-v1 | https://cdn.r99.com/floral-white-s-1.jpg | 0 |
| uuid-v1 | https://cdn.r99.com/floral-white-s-2.jpg | 1 |

---

### `products`

Individual catalogue SKUs. Each product can optionally be linked to a model variant. Stock is NOT stored here.

```sql
CREATE TABLE products (
  id          UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  name        VARCHAR(255)   NOT NULL,
  sku         VARCHAR(100)   UNIQUE NOT NULL,
  category_id INTEGER        REFERENCES product_categories(id) ON DELETE SET NULL,
  line_id     INTEGER        REFERENCES product_lines(id)      ON DELETE SET NULL,
  size        VARCHAR(20),
  price       NUMERIC(10,2)  NOT NULL CHECK (price >= 0),
  cost        NUMERIC(10,2)  NOT NULL CHECK (cost  >= 0),
  tone        SMALLINT       NOT NULL DEFAULT 0 CHECK (tone BETWEEN 0 AND 5),
  status      product_status NOT NULL DEFAULT 'in_stock',
  model_id    UUID           REFERENCES product_models(id) ON DELETE SET NULL,
  created_at  TIMESTAMPTZ    NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ    NOT NULL DEFAULT now()
);
```

| Column | Type | Description |
|---|---|---|
| `sku` | VARCHAR | Unique stock-keeping unit code |
| `price` | NUMERIC | Selling price to customer |
| `cost` | NUMERIC | Purchase/production cost (for margin reports) |
| `tone` | SMALLINT | Color tone scale 0–5 (used for visual sorting) |
| `status` | product_status | `in_stock`, `low_stock`, `out_of_stock` — derived or manually set |
| `model_id` | UUID | Optional link to a product model |

**Sample data:**

| sku | name | category_id | size | price | cost | status |
|---|---|---|---|---|---|---|
| R99-BLS-001-S-W | Floral Blouse S White | 1 | S | 25.00 | 10.00 | in_stock |
| R99-BLS-001-M-W | Floral Blouse M White | 1 | M | 25.00 | 10.00 | in_stock |
| R99-LNS-002-M-B | Classic Linen Shirt M Blue | 2 | M | 30.00 | 12.00 | low_stock |

---

## Stock Management

Stock is separated into two tables:
- `stock_levels` — current quantity snapshot (fast reads)
- `stock_movements` — append-only ledger of every change (full history)

Both are always updated together in the same transaction.

---

### `stock_levels`

Current quantity for each product or variant. One row per product OR per variant — never both.

```sql
CREATE TABLE stock_levels (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID        UNIQUE REFERENCES products(id)       ON DELETE CASCADE,
  variant_id UUID        UNIQUE REFERENCES model_variants(id) ON DELETE CASCADE,
  quantity   INTEGER     NOT NULL DEFAULT 0 CHECK (quantity >= 0),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT chk_stock_one_owner CHECK (
    (product_id IS NOT NULL AND variant_id IS NULL) OR
    (product_id IS NULL     AND variant_id IS NOT NULL)
  )
);
```

| Column | Type | Description |
|---|---|---|
| `product_id` | UUID | FK to products — set if tracking by product |
| `variant_id` | UUID | FK to model_variants — set if tracking by variant |
| `quantity` | INTEGER | Current stock count, always >= 0 |
| `updated_at` | TIMESTAMPTZ | Auto-updated by trigger on every change |

**Sample data:**

| product_id | variant_id | quantity |
|---|---|---|
| uuid-p1 (Floral Blouse S White) | NULL | 45 |
| uuid-p2 (Floral Blouse M White) | NULL | 12 |
| NULL | uuid-v3 (Floral Blouse S Pink) | 0 |

---

### `stock_movements`

Append-only ledger. Every stock change — sale, restock, adjustment — is recorded here. **Never update or delete rows.**

```sql
CREATE TABLE stock_movements (
  id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id   UUID         REFERENCES products(id)       ON DELETE SET NULL,
  variant_id   UUID         REFERENCES model_variants(id) ON DELETE SET NULL,
  delta        INTEGER      NOT NULL,
  reason       stock_reason NOT NULL,
  reference_id VARCHAR(255),
  note         TEXT,
  created_by   UUID         REFERENCES users(id) ON DELETE SET NULL,
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),

  CONSTRAINT chk_movement_one_owner CHECK (
    (product_id IS NOT NULL AND variant_id IS NULL) OR
    (product_id IS NULL     AND variant_id IS NOT NULL)
  )
);
```

| Column | Type | Description |
|---|---|---|
| `delta` | INTEGER | Positive = stock in, Negative = stock out |
| `reason` | stock_reason | Why the stock changed |
| `reference_id` | VARCHAR | ID of the order or document that caused this change |
| `note` | TEXT | Optional admin note |
| `created_by` | UUID | Which user triggered this movement |

**Sample data:**

| product_id | delta | reason | reference_id | note |
|---|---|---|---|---|
| uuid-p1 | +100 | initial | NULL | First stock entry |
| uuid-p1 | +50 | purchase | PO-2025-001 | Restock from supplier |
| uuid-p1 | -2 | sale | R99-104722 | Customer order |
| uuid-p1 | -3 | damage | NULL | Damaged in warehouse |
| uuid-p2 | +20 | adjustment | NULL | Inventory count correction |

> **How to compute current stock from movements only:**
> ```sql
> SELECT SUM(delta) FROM stock_movements WHERE product_id = 'uuid-p1';
> -- Result: 145
> ```
> `stock_levels` is kept in sync as a snapshot for fast reads so you don't need to SUM every time.

---

## E-Commerce Orders

### `orders`

Orders placed by customers on the online store.

```sql
CREATE TABLE orders (
  id            VARCHAR(20)   PRIMARY KEY,
  customer_id   UUID          REFERENCES customers(id) ON DELETE SET NULL,
  customer_name VARCHAR(255)  NOT NULL,
  city          VARCHAR(255),
  status        order_status  NOT NULL DEFAULT 'Processing',
  ship          VARCHAR(100),
  total         NUMERIC(10,2) NOT NULL CHECK (total >= 0),
  date          TIMESTAMPTZ   NOT NULL DEFAULT now(),
  created_at    TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ   NOT NULL DEFAULT now()
);
```

| Column | Type | Description |
|---|---|---|
| `id` | VARCHAR | Human-readable ID in `R99-XXXXXX` format |
| `customer_name` | VARCHAR | Denormalized — preserved even if customer is deleted |
| `ship` | VARCHAR | Shipping carrier: J&T, DHL, Ninja Van, etc. |
| `total` | NUMERIC | Total price paid |

**Sample data:**

| id | customer_name | city | status | ship | total |
|---|---|---|---|---|---|
| R99-104722 | Sophea Chan | Phnom Penh | Delivered | J&T | 50.00 |
| R99-104723 | Bunna Keo | Siem Reap | Processing | Ninja Van | 30.00 |
| R99-104724 | Maly Nhem | Phnom Penh | Shipped | DHL | 25.00 |

---

### `order_items`

Line items within each order. Prices are frozen at time of purchase.

```sql
CREATE TABLE order_items (
  id           UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id     VARCHAR(20)   NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id   UUID          REFERENCES products(id) ON DELETE SET NULL,
  product_name VARCHAR(255)  NOT NULL,
  size         VARCHAR(20),
  color        VARCHAR(50),
  tone         SMALLINT,
  qty          INTEGER       NOT NULL CHECK (qty > 0),
  price        NUMERIC(10,2) NOT NULL CHECK (price >= 0),
  created_at   TIMESTAMPTZ   NOT NULL DEFAULT now()
);
```

| Column | Type | Description |
|---|---|---|
| `product_name` | VARCHAR | Denormalized — preserved if product is deleted |
| `price` | NUMERIC | Price at time of purchase, never changes |

**Sample data:**

| order_id | product_name | size | color | qty | price |
|---|---|---|---|---|---|
| R99-104722 | Floral Blouse | S | White | 2 | 25.00 |
| R99-104723 | Classic Linen Shirt | M | Blue | 1 | 30.00 |

---

## Marketing

### `discounts`

Coupon codes for promotions.

```sql
CREATE TABLE discounts (
  id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  code        VARCHAR(50)   UNIQUE NOT NULL,
  type        discount_type NOT NULL,
  value       NUMERIC(10,2) NOT NULL CHECK (value > 0),
  expiry_date DATE,
  usage_limit INTEGER       CHECK (usage_limit > 0),
  usage_count INTEGER       NOT NULL DEFAULT 0,
  active      BOOLEAN       NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ   NOT NULL DEFAULT now()
);
```

| Column | Type | Description |
|---|---|---|
| `type` | discount_type | `percentage` (10% off), `fixed` ($5 off), `shipping` (free shipping) |
| `value` | NUMERIC | Amount — for percentage type, value is 10 means 10% |
| `usage_limit` | INTEGER | Max times the code can be used. NULL = unlimited |
| `usage_count` | INTEGER | Incremented each time the code is applied |

**Sample data:**

| code | type | value | expiry_date | usage_limit | usage_count | active |
|---|---|---|---|---|---|---|
| SALE10 | percentage | 10.00 | 2026-12-31 | NULL | 43 | true |
| SHIP5 | shipping | 5.00 | NULL | 100 | 12 | true |
| FLAT5 | fixed | 5.00 | 2026-08-31 | 50 | 50 | false |

---

## Delivery Management

### `drivers`

Delivery driver roster. Commission is calculated per delivered `shop_order`.

```sql
CREATE TABLE drivers (
  id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  name            VARCHAR(255)  NOT NULL,
  phone           VARCHAR(50),
  commission_rate NUMERIC(5,2)  NOT NULL DEFAULT 0.50 CHECK (commission_rate >= 0),
  status          driver_status NOT NULL DEFAULT 'active',
  created_at      TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ   NOT NULL DEFAULT now()
);
```

| Column | Type | Description |
|---|---|---|
| `commission_rate` | NUMERIC | Commission per delivery in USD (e.g. 0.50 = $0.50/order) |

**Sample data:**

| id | name | phone | commission_rate | status |
|---|---|---|---|---|
| uuid-d1 | Virak Sok | 012 345 678 | 0.50 | active |
| uuid-d2 | Piseth Ly | 078 123 456 | 0.50 | active |

---

### `shop_orders`

Delivery orders imported from Google Sheet or created manually. Separate lifecycle from e-commerce orders.

```sql
CREATE TABLE shop_orders (
  id               UUID              PRIMARY KEY DEFAULT gen_random_uuid(),
  shop             VARCHAR(50)       NOT NULL,
  customer_name    VARCHAR(255)      NOT NULL,
  phone            VARCHAR(50)       NOT NULL,
  location         TEXT              NOT NULL,
  total_price      NUMERIC(10,2)     NOT NULL CHECK (total_price >= 0),
  deliver_service  VARCHAR(100),
  chat_respondent  VARCHAR(255),
  outlet           VARCHAR(255),
  link             VARCHAR(1000),
  date             TIMESTAMPTZ       NOT NULL DEFAULT now(),
  status           shop_order_status NOT NULL DEFAULT 'pending',
  note             TEXT,
  driver_id        UUID              REFERENCES drivers(id) ON DELETE SET NULL,
  delivery_fee     NUMERIC(10,2)     NOT NULL DEFAULT 0,
  created_by       VARCHAR(255),
  import_status    VARCHAR(50),
  source_url       VARCHAR(1000),
  imported_at      TIMESTAMPTZ,
  created_at       TIMESTAMPTZ       NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ       NOT NULL DEFAULT now()
);
```

| Column | Type | Description |
|---|---|---|
| `shop` | VARCHAR | Which shop: `R99` or `R99-II` |
| `chat_respondent` | VARCHAR | Staff member who handled the customer chat |
| `outlet` | VARCHAR | Physical outlet if applicable |
| `link` | VARCHAR | Link to original Facebook/chat conversation |
| `import_status` | VARCHAR | `ALRADY_PAID` or `PADDING` — from Google Sheet |
| `source_url` | VARCHAR | The Google Sheet URL this row came from |
| `imported_at` | TIMESTAMPTZ | NULL if created manually in the admin |

**Sample data:**

| shop | customer_name | phone | location | total_price | status | import_status |
|---|---|---|---|---|---|---|
| R99 | Dara Pich | 012 111 222 | Toul Kork, Phnom Penh | 25.00 | delivered | PADDING |
| R99-II | Srey Leak | 096 333 444 | Siem Reap City | 30.00 | pending | PADDING |
| R99 | Chantha Ros | 078 555 666 | Sen Sok, Phnom Penh | 0.00 | delivered | ALRADY_PAID |

---

### `shop_order_items`

Products within each delivery order. Outcome tracks whether the item was actually delivered.

```sql
CREATE TABLE shop_order_items (
  id            UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_order_id UUID          NOT NULL REFERENCES shop_orders(id) ON DELETE CASCADE,
  product_name  VARCHAR(255)  NOT NULL,
  qty           INTEGER       NOT NULL CHECK (qty > 0),
  price         NUMERIC(10,2) NOT NULL CHECK (price >= 0),
  outcome       item_outcome  NOT NULL DEFAULT 'delivered',
  created_at    TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ   NOT NULL DEFAULT now()
);
```

| Column | Type | Description |
|---|---|---|
| `outcome` | item_outcome | `delivered`, `returned`, or `exchanged` — affects revenue reporting |

---

### `driver_settlements`

Records cash payments made to drivers to settle their earned commission.

```sql
CREATE TABLE driver_settlements (
  id         UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id  UUID          NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  amount     NUMERIC(10,2) NOT NULL CHECK (amount > 0),
  note       TEXT,
  settled_at DATE          NOT NULL DEFAULT CURRENT_DATE,
  created_by UUID          REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ   NOT NULL DEFAULT now()
);
```

**Example:** Virak Sok delivered 20 orders at $0.50 each = $10.00 owed. Admin pays him $10.

| driver_id | amount | note | settled_at |
|---|---|---|---|
| uuid-d1 (Virak) | 10.00 | Week of 2026-07-28 settlement | 2026-08-02 |

---

### `delivery_products`

Inventory used specifically for delivery orders. Separate from the main product catalogue.

```sql
CREATE TABLE delivery_products (
  id         UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  name       VARCHAR(255)  NOT NULL,
  size       VARCHAR(20),
  price      NUMERIC(10,2) NOT NULL CHECK (price >= 0),
  stock      INTEGER       NOT NULL DEFAULT 0 CHECK (stock >= 0),
  created_at TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ   NOT NULL DEFAULT now()
);
```

---

## Audit

### `activity_logs`

Append-only audit trail of every significant action in the system. Never update or delete rows.

```sql
CREATE TABLE activity_logs (
  id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID          REFERENCES users(id) ON DELETE SET NULL,
  type        activity_type NOT NULL,
  action      TEXT          NOT NULL,
  entity_type VARCHAR(100),
  entity_id   VARCHAR(255),
  metadata    JSONB,
  created_at  TIMESTAMPTZ   NOT NULL DEFAULT now()
);
```

| Column | Type | Description |
|---|---|---|
| `user_id` | UUID | Who performed the action. NULL = system action |
| `type` | activity_type | Section: `orders`, `products`, `stock`, etc. |
| `action` | TEXT | What happened: `"created order R99-104724"` |
| `entity_type` | VARCHAR | Table name of the affected record |
| `entity_id` | VARCHAR | ID of the affected record |
| `metadata` | JSONB | Before/after values or extra context |

**Sample data:**

| user_id | type | action | entity_type | entity_id | metadata |
|---|---|---|---|---|---|
| uuid-1 | orders | Created order R99-104724 | orders | R99-104724 | `{"total": 25.00, "customer": "Maly Nhem"}` |
| uuid-2 | stock | Adjusted stock for Floral Blouse S White | products | uuid-p1 | `{"before": 45, "after": 42, "delta": -3}` |
| uuid-1 | users | Created user dara@r99.com | users | uuid-3 | `{"role": "staff"}` |

---

## Triggers

Auto-update `updated_at` on every row change.

```sql
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- Apply to all tables that have updated_at
CREATE TRIGGER trg_users_updated_at             BEFORE UPDATE ON users             FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_customers_updated_at         BEFORE UPDATE ON customers         FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_product_models_updated_at    BEFORE UPDATE ON product_models    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_model_variants_updated_at    BEFORE UPDATE ON model_variants    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_products_updated_at          BEFORE UPDATE ON products          FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_stock_levels_updated_at      BEFORE UPDATE ON stock_levels      FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_orders_updated_at            BEFORE UPDATE ON orders            FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_discounts_updated_at         BEFORE UPDATE ON discounts         FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_drivers_updated_at           BEFORE UPDATE ON drivers           FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_shop_orders_updated_at       BEFORE UPDATE ON shop_orders       FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_shop_order_items_updated_at  BEFORE UPDATE ON shop_order_items  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_delivery_products_updated_at BEFORE UPDATE ON delivery_products FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

---

## Indexes

```sql
-- Auth
CREATE INDEX idx_users_email                ON users(email);
CREATE INDEX idx_sessions_token             ON sessions(token);
CREATE INDEX idx_sessions_user_id           ON sessions(user_id);
CREATE INDEX idx_sessions_expires_at        ON sessions(expires_at);

-- Catalogue
CREATE INDEX idx_products_sku               ON products(sku);
CREATE INDEX idx_products_category_id       ON products(category_id);
CREATE INDEX idx_products_status            ON products(status);
CREATE INDEX idx_products_model_id          ON products(model_id);
CREATE INDEX idx_model_variants_model_id    ON model_variants(model_id);
CREATE INDEX idx_variant_images_variant_id  ON model_variant_images(variant_id);

-- Stock
CREATE INDEX idx_stock_levels_product_id    ON stock_levels(product_id);
CREATE INDEX idx_stock_levels_variant_id    ON stock_levels(variant_id);
CREATE INDEX idx_stock_movements_product_id ON stock_movements(product_id);
CREATE INDEX idx_stock_movements_variant_id ON stock_movements(variant_id);
CREATE INDEX idx_stock_movements_reason     ON stock_movements(reason);
CREATE INDEX idx_stock_movements_created_at ON stock_movements(created_at DESC);
CREATE INDEX idx_stock_movements_reference  ON stock_movements(reference_id);

-- E-Commerce Orders
CREATE INDEX idx_orders_customer_id         ON orders(customer_id);
CREATE INDEX idx_orders_status              ON orders(status);
CREATE INDEX idx_orders_date                ON orders(date DESC);
CREATE INDEX idx_order_items_order_id       ON order_items(order_id);
CREATE INDEX idx_order_items_product_id     ON order_items(product_id);

-- Delivery
CREATE INDEX idx_shop_orders_status         ON shop_orders(status);
CREATE INDEX idx_shop_orders_driver_id      ON shop_orders(driver_id);
CREATE INDEX idx_shop_orders_date           ON shop_orders(date DESC);
CREATE INDEX idx_shop_orders_chat_resp      ON shop_orders(chat_respondent);
CREATE INDEX idx_shop_orders_import_status  ON shop_orders(import_status);
CREATE INDEX idx_shop_order_items_order_id  ON shop_order_items(shop_order_id);
CREATE INDEX idx_driver_settlements_driver  ON driver_settlements(driver_id);
CREATE INDEX idx_driver_settlements_date    ON driver_settlements(settled_at DESC);

-- Audit
CREATE INDEX idx_activity_logs_user_id      ON activity_logs(user_id);
CREATE INDEX idx_activity_logs_type         ON activity_logs(type);
CREATE INDEX idx_activity_logs_entity       ON activity_logs(entity_type, entity_id);
CREATE INDEX idx_activity_logs_created_at   ON activity_logs(created_at DESC);
```

---

## Key Design Decisions

| Decision | Reason |
|---|---|
| Stock separated into `stock_levels` + `stock_movements` | `stock_levels` gives fast current reads; `stock_movements` gives full audit history. Never lose a stock change. |
| `customer_name` and `product_name` denormalized in orders | Preserves the exact name at time of order even if the customer or product is later edited or deleted. |
| `activity_logs` append-only | Audit trails must never be modified. Use `ON DELETE SET NULL` on `user_id` so logs survive user deletion. |
| `user_permissions` with `granted` boolean | Lets you grant a permission to one user without changing their role, or block a permission without demoting them. |
| `import_status` stored as VARCHAR not ENUM | Values like `ALRADY_PAID` come from external Google Sheet — keeping as VARCHAR avoids migration pain if values change. |
