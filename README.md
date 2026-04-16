# DBMS_shop – Art Workshop E‑Commerce (PHP + MySQL)

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
- Refund request logs (`refunds`)
- Dark mode toggle
- Responsive design

## DBMS Requirements Included
- ✅ Basic SQL (tables + inserts + joins)
- ✅ Stored Function: `fn_line_subtotal(qty, price)`
- ✅ Stored Procedure: `sp_place_order(user_id, payment_mode, shipping_address, cart_json)`

## Database Schema
Main tables:
- `users`
- `products`
- `orders`
- `order_items`
- `refunds`

All schema + seed data + stored function/procedure are in:
- `database.sql`

## Price Rules Implemented
- Commissions/Illustrations/Drawings: **₱50–₱100**
- Art Materials: **₱150–₱300**

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

## Where to place your artwork images
Put files in `assets/images/` and update the `image_path` values in the `products` table.

Current seeded names are:
- `assets/images/art-1.png`
- `assets/images/art-2.png`
- `assets/images/art-3.png`
- `assets/images/art-4.png`
- `assets/images/art-5.png`

If images are not present, the system shows category placeholders automatically.

## Important Notes
- Checkout uses the stored procedure (`sp_place_order`) so all writes to `orders` and `order_items` are logged as a transaction.
- Refunds are captured in the `refunds` table from the Transaction History page.
