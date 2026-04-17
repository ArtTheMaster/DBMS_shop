# DBMS_shop
# DBMS_shop - Art Workshop E-Commerce (PHP + MySQL)

A responsive DBMS project website for selling **art commissions, illustrations, drawings, and art materials** using:
- HTML/CSS/JavaScript
- PHP (PDO)
- MySQL via phpMyAdmin/XAMPP

## Features
- User registration, login, logout
- Product browsing + category filter
- Cart and checkout flow
- Login-required order placement
- Transaction logs (`orders` + `order_items`)
- Payment logs (`payments`)
- Refund request logs (`refunds`)
- Dark mode toggle
- Responsive design

## DBMS Requirements Included
- Basic SQL (tables + inserts + joins)
- Stored Function: `fn_line_subtotal(qty, price)`
- Triggers:
  - `trg_before_order_item_insert`
  - `trg_after_payment_insert`
- Stored Procedures:
  - `sp_PlaceOrder(user_id, product_id, quantity)`
  - `sp_ProcessPayment(order_id, payment_method)`
  - `sp_ProcessRefund(payment_id, reason)`

## Database Schema
Main tables:
- `users`
- `products`
- `orders`
- `order_items`
- `payments`
- `refunds`
- `audit_logs`

All schema + seed data + stored routines are in:
- `database.sql`

## Detailed ERD
```mermaid
erDiagram
    USERS ||--o{ ORDERS : places
    PRODUCTS ||--o{ ORDER_ITEMS : appears_in
    ORDERS ||--|{ ORDER_ITEMS : contains
    ORDERS ||--o{ PAYMENTS : paid_by
    PAYMENTS ||--o{ REFUNDS : may_have
<<<<<<< ours
<<<<<<< ours
<<<<<<< ours
=======
    PAYMENTS ||--o{ AUDIT_LOGS : creates
    ORDERS ||--o{ AUDIT_LOGS : links_to
    USERS ||--o{ AUDIT_LOGS : actor
>>>>>>> theirs
=======
    PAYMENTS ||--o{ AUDIT_LOGS : creates
    ORDERS ||--o{ AUDIT_LOGS : links_to
    USERS ||--o{ AUDIT_LOGS : actor
>>>>>>> theirs
=======
    PAYMENTS ||--o{ AUDIT_LOGS : creates
    ORDERS ||--o{ AUDIT_LOGS : links_to
    USERS ||--o{ AUDIT_LOGS : actor
>>>>>>> theirs

    USERS {
        INT user_id PK
        VARCHAR full_name
        VARCHAR email UNIQUE
        VARCHAR password_hash
        TEXT address
        TIMESTAMP created_at
    }

    PRODUCTS {
        INT product_id PK
        VARCHAR product_name
        ENUM category
        DECIMAL price
        INT stock
        VARCHAR image_path
        TEXT description
        TINYINT is_active
        TIMESTAMP created_at
    }

    ORDERS {
        INT order_id PK
        INT user_id FK
        DECIMAL total_amount
        TEXT shipping_address
        ENUM order_status
        TIMESTAMP created_at
    }

    ORDER_ITEMS {
        INT order_item_id PK
        INT order_id FK
        INT product_id FK
        INT quantity
        DECIMAL unit_price
        DECIMAL subtotal
        TIMESTAMP created_at
    }

    PAYMENTS {
        INT payment_id PK
        INT order_id FK
        ENUM payment_method
        DECIMAL payment_amount
        ENUM payment_status
        TIMESTAMP paid_at
    }

    REFUNDS {
        INT refund_id PK
        INT payment_id FK
        VARCHAR reason
        DECIMAL refund_amount
        ENUM status
        TIMESTAMP requested_at
        TIMESTAMP processed_at
    }
<<<<<<< ours
<<<<<<< ours
<<<<<<< ours
=======
=======
>>>>>>> theirs
=======
>>>>>>> theirs

    AUDIT_LOGS {
        INT audit_id PK
        INT payment_id FK
        INT order_id FK
        INT user_id FK
        VARCHAR action_type
        TEXT details
        TIMESTAMP created_at
    }
<<<<<<< ours
<<<<<<< ours
>>>>>>> theirs
=======
>>>>>>> theirs
=======
>>>>>>> theirs
```

## Clear DB Architecture Explanation
The architecture is designed around a transactional e-commerce flow:

1. **Identity Layer (`users`)**
   - Stores customer identity and login credentials.
   - At registration, account data is persisted immediately; shipping address is collected/updated during checkout.

2. **Catalog Layer (`products`)**
   - Holds sellable inventory and product metadata.
   - `stock` is decremented inside the order placement procedure to keep inventory consistent.

3. **Order Layer (`orders`, `order_items`)**
   - `orders` stores order header information (who ordered, where to ship, status, totals).
   - `order_items` stores line-by-line purchase details.
   - This header-detail split supports accurate reporting and many-item orders.

4. **Payment Layer (`payments`)**
   - Tracks payment method, amount, and lifecycle state.
   - Payment is recorded by `sp_ProcessPayment` after successful order placement.

5. **After-Sales Layer (`refunds`)**
   - Preserves refund requests and outcomes without deleting original payment history.
   - Keeps auditability for financial events.

6. **Database Logic Layer (Stored Routine Strategy)**
   - `fn_line_subtotal` centralizes subtotal computation.
   - `sp_PlaceOrder` handles stock lock/check, order insert, item insert, and stock deduction in one transaction.
   - `sp_ProcessPayment` and `sp_ProcessRefund` centralize payment and refund state transitions.
<<<<<<< ours
<<<<<<< ours
<<<<<<< ours
=======
   - `trg_before_order_item_insert` enforces positive quantity and computes subtotal consistently.
   - `trg_after_payment_insert` writes audit events to `audit_logs` for traceability.
>>>>>>> theirs
=======
   - `trg_before_order_item_insert` enforces positive quantity and computes subtotal consistently.
   - `trg_after_payment_insert` writes audit events to `audit_logs` for traceability.
>>>>>>> theirs
=======
   - `trg_before_order_item_insert` enforces positive quantity and computes subtotal consistently.
   - `trg_after_payment_insert` writes audit events to `audit_logs` for traceability.
>>>>>>> theirs

For a report-ready breakdown, see `docs/DB_ARCHITECTURE.md`.

## Price Rules Implemented
- Commissions/Illustrations/Drawings: **PHP 50 to PHP 100**
- Art Materials: **PHP 150 to PHP 300**

## Setup (XAMPP + phpMyAdmin + VS Code)
1. Start **Apache** and **MySQL** in XAMPP Control Panel.
2. Place project in `xampp/htdocs/DBMS_shop`.
3. Open `http://localhost/phpmyadmin`.
4. Import `database.sql`.
5. Open project in VS Code.
6. Visit `http://localhost/DBMS_shop/index.php`.

## Default DB Config
Edit `config.php` if needed:
- Host: `127.0.0.1`
- DB: `artshop_dbms`
- User: `root`
- Password: *(empty by default in XAMPP)*

## Stored Function Guide (for your report/demo)
### 1) Purpose
`fn_line_subtotal(qty, price)` computes **subtotal = qty * price**.

### 2) Example test in phpMyAdmin SQL tab
```sql
SELECT fn_line_subtotal(3, 75.00) AS subtotal;
```
Expected result: `225.00`

### 3) How it is used in this project
- Inside `sp_PlaceOrder`, subtotal is computed for each order item.
- This ensures subtotal calculation is centralized in DB logic.

## Stored Procedure Demo Queries
```sql
-- Place one order line
CALL sp_PlaceOrder(1, 2, 1);

-- Process payment for order #1
CALL sp_ProcessPayment(1, 'GCash');

-- Request refund for payment #1
CALL sp_ProcessRefund(1, 'Wrong item delivered');
```

## Trigger Guide (for rubric: Functions & Triggers)
### Trigger A: `trg_before_order_item_insert`
- **When it runs:** before a new row is inserted into `order_items`.
- **What it does:**
  1. Blocks invalid quantity (`<= 0`) using `SIGNAL`.
  2. Automatically computes `subtotal = fn_line_subtotal(quantity, unit_price)`.
- **Why it helps your score:** enforces integrity and reuses DB business logic.

### Trigger B: `trg_after_payment_insert`
- **When it runs:** after a payment row is inserted into `payments`.
- **What it does:** inserts a log row into `audit_logs` containing payment, order, and user linkage.
- **Why it helps your score:** provides auditing/traceability for financial events.

### Verify triggers in MySQL
```sql
SHOW TRIGGERS LIKE 'order_items';
SHOW TRIGGERS LIKE 'payments';
SELECT * FROM audit_logs ORDER BY audit_id DESC LIMIT 10;
```

## Where to place your artwork images
Put files in `assets/images/` and update `image_path` values in `products`.

Current seeded names are:
- `assets/images/art-1.png`
- `assets/images/art-2.png`
- `assets/images/art-3.png`
- `assets/images/art-4.png`
- `assets/images/art-5.png`

If images are not present, the system shows category placeholders automatically.
