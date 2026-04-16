CREATE DATABASE IF NOT EXISTS artshop_dbms;
USE artshop_dbms;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category ENUM('Commission', 'Illustration', 'Drawing', 'Art Material') NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 20,
    image_path VARCHAR(255) DEFAULT NULL,
    description TEXT,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    payment_mode ENUM('Cash on Delivery', 'GCash', 'PayPal', 'PayMaya') NOT NULL,
    shipping_address TEXT NOT NULL,
    order_status ENUM('Pending', 'Paid', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE refunds (
    refund_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    reason VARCHAR(255) NOT NULL,
    refund_amount DECIMAL(10,2) NOT NULL,
    status ENUM('Requested', 'Approved', 'Rejected', 'Completed') DEFAULT 'Requested',
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Basic SQL sample records
INSERT INTO products (product_name, category, price, stock, image_path, description) VALUES
('Santa Cookie Artist Commission', 'Commission', 90.00, 8, 'assets/images/art-1.png', 'Holiday themed custom character commission.'),
('Undertale Festive Illustration', 'Illustration', 75.00, 12, 'assets/images/art-2.png', 'Digital holiday skeleton portrait art.'),
('Reindeer Costume Sketch', 'Drawing', 55.00, 15, 'assets/images/art-3.png', 'Cute hand-drawn costume concept.'),
('Celestial Armor Study', 'Illustration', 95.00, 9, 'assets/images/art-4.png', 'Fantasy armor character concept piece.'),
('Painter Cat Daylight', 'Drawing', 60.00, 12, 'assets/images/art-5.png', 'Warm and cozy painted cat drawing.'),
('Premium Acrylic Paint Set', 'Art Material', 220.00, 30, NULL, '24-color acrylic paint set.'),
('Professional Sketchbook A4', 'Art Material', 180.00, 40, NULL, '100-page acid-free sketchbook.'),
('Brush Set (12pcs)', 'Art Material', 160.00, 35, NULL, 'Round and flat synthetic brushes.'),
('Marker Set (40 colors)', 'Art Material', 300.00, 25, NULL, 'Dual-tip alcohol markers.');

-- Stored Function: calculates line subtotal
DELIMITER $$
CREATE FUNCTION fn_line_subtotal(p_qty INT, p_price DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_qty * p_price;
END $$
DELIMITER ;

-- Stored Procedure: complete checkout and write transaction log
DELIMITER $$
CREATE PROCEDURE sp_place_order(
    IN p_user_id INT,
    IN p_payment_mode VARCHAR(50),
    IN p_shipping_address TEXT,
    IN p_cart_json JSON
)
BEGIN
    DECLARE v_order_id INT;
    DECLARE v_total DECIMAL(10,2) DEFAULT 0;
    DECLARE i INT DEFAULT 0;
    DECLARE cart_length INT;
    DECLARE v_product_id INT;
    DECLARE v_qty INT;
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;

    START TRANSACTION;

    SET cart_length = JSON_LENGTH(p_cart_json);

    WHILE i < cart_length DO
        SET v_product_id = JSON_UNQUOTE(JSON_EXTRACT(p_cart_json, CONCAT('$[', i, '].product_id')));
        SET v_qty = JSON_UNQUOTE(JSON_EXTRACT(p_cart_json, CONCAT('$[', i, '].quantity')));

        SELECT price, stock INTO v_price, v_stock
        FROM products
        WHERE product_id = v_product_id
        FOR UPDATE;

        IF v_stock < v_qty THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Insufficient stock for one or more products.';
        END IF;

        SET v_total = v_total + fn_line_subtotal(v_qty, v_price);
        SET i = i + 1;
    END WHILE;

    INSERT INTO orders (user_id, total_amount, payment_mode, shipping_address, order_status)
    VALUES (p_user_id, v_total, p_payment_mode, p_shipping_address, 'Pending');

    SET v_order_id = LAST_INSERT_ID();
    SET i = 0;

    WHILE i < cart_length DO
        SET v_product_id = JSON_UNQUOTE(JSON_EXTRACT(p_cart_json, CONCAT('$[', i, '].product_id')));
        SET v_qty = JSON_UNQUOTE(JSON_EXTRACT(p_cart_json, CONCAT('$[', i, '].quantity')));

        SELECT price INTO v_price FROM products WHERE product_id = v_product_id;

        INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal)
        VALUES (v_order_id, v_product_id, v_qty, v_price, fn_line_subtotal(v_qty, v_price));

        UPDATE products
        SET stock = stock - v_qty
        WHERE product_id = v_product_id;

        SET i = i + 1;
    END WHILE;

    COMMIT;
END $$
DELIMITER ;
