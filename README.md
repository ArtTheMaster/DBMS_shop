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

All schema + seed data + stored routines are in:
- `database.sql`

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

## Where to place your artwork images
Put files in `assets/images/` and update `image_path` values in `products`.

Current seeded names are:
- `assets/images/art-1.png`
- `assets/images/art-2.png`
- `assets/images/art-3.png`
- `assets/images/art-4.png`
- `assets/images/art-5.png`

If images are not present, the system shows category placeholders automatically.