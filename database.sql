CREATE DATABASE IF NOT EXISTS artshop_dbms;
USE artshop_dbms;

<<<<<<< ours
=======
DROP TABLE IF EXISTS refunds;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;

>>>>>>> theirs
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

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method ENUM('Cash on Delivery', 'GCash', 'PayPal', 'PayMaya') NOT NULL,
    payment_amount DECIMAL(10,2) NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE refunds (
    refund_id INT AUTO_INCREMENT PRIMARY KEY,
    payment_id INT NOT NULL,
    reason VARCHAR(255) NOT NULL,
    refund_amount DECIMAL(10,2) NOT NULL,
    status ENUM('Requested', 'Approved', 'Rejected', 'Completed') DEFAULT 'Requested',
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP NULL,
    FOREIGN KEY (payment_id) REFERENCES payments(payment_id)
);

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

DROP FUNCTION IF EXISTS fn_line_subtotal;
DELIMITER $$
CREATE FUNCTION fn_line_subtotal(p_qty INT, p_price DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_qty * p_price;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_PlaceOrder;
DELIMITER $$
CREATE PROCEDURE sp_PlaceOrder(
    IN p_user_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    DECLARE v_order_id INT;
    DECLARE v_address TEXT;

    START TRANSACTION;

    SELECT price, stock INTO v_price, v_stock
    FROM products
    WHERE product_id = p_product_id
    FOR UPDATE;

    IF v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient stock for selected product.';
    END IF;

    SELECT address INTO v_address
    FROM users
    WHERE user_id = p_user_id;

    INSERT INTO orders (user_id, total_amount, shipping_address, order_status)
    VALUES (p_user_id, fn_line_subtotal(p_quantity, v_price), v_address, 'Pending');

    SET v_order_id = LAST_INSERT_ID();

    INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal)
    VALUES (v_order_id, p_product_id, p_quantity, v_price, fn_line_subtotal(p_quantity, v_price));

    UPDATE products
    SET stock = stock - p_quantity
    WHERE product_id = p_product_id;

    COMMIT;

    SELECT v_order_id AS order_id;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_ProcessPayment;
DELIMITER $$
CREATE PROCEDURE sp_ProcessPayment(
    IN p_order_id INT,
    IN p_payment_method VARCHAR(50)
)
BEGIN
    DECLARE v_total DECIMAL(10,2);

    SELECT total_amount INTO v_total
    FROM orders
    WHERE order_id = p_order_id;

    INSERT INTO payments (order_id, payment_method, payment_amount, payment_status)
    VALUES (p_order_id, p_payment_method, v_total, 'Completed');

    UPDATE orders
    SET order_status = 'Paid'
    WHERE order_id = p_order_id;

    SELECT LAST_INSERT_ID() AS payment_id;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_ProcessRefund;
DELIMITER $$
CREATE PROCEDURE sp_ProcessRefund(
    IN p_payment_id INT,
    IN p_reason VARCHAR(255)
)
BEGIN
    DECLARE v_amount DECIMAL(10,2);

    SELECT payment_amount INTO v_amount
    FROM payments
    WHERE payment_id = p_payment_id;

    INSERT INTO refunds (payment_id, reason, refund_amount, status)
    VALUES (p_payment_id, p_reason, v_amount, 'Requested');

    UPDATE payments
    SET payment_status = 'Refunded'
    WHERE payment_id = p_payment_id;
END $$
DELIMITER ;
