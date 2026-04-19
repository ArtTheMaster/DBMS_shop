CREATE DATABASE IF NOT EXISTS artshop_dbms;
USE artshop_dbms;

DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS refunds;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

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
) ENGINE=InnoDB;

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    shipping_address TEXT NOT NULL,
    order_status ENUM('Pending', 'Paid', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_user FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_item_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_item_product FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method ENUM('Cash on Delivery', 'GCash', 'PayPal', 'PayMaya') NOT NULL,
    payment_amount DECIMAL(10,2) NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
) ENGINE=InnoDB;

CREATE TABLE refunds (
    refund_id INT AUTO_INCREMENT PRIMARY KEY,
    payment_id INT NOT NULL,
    reason VARCHAR(255) NOT NULL,
    refund_amount DECIMAL(10,2) NOT NULL,
    status ENUM('Requested', 'Approved', 'Rejected', 'Completed') DEFAULT 'Requested',
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP NULL,
    CONSTRAINT fk_refund_payment FOREIGN KEY (payment_id) REFERENCES payments(payment_id)
) ENGINE=InnoDB;

CREATE TABLE audit_logs (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    payment_id INT NULL,
    order_id INT NULL,
    user_id INT NULL,
    action_type VARCHAR(60) NOT NULL,
    details TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_payment FOREIGN KEY (payment_id) REFERENCES payments(payment_id),
    CONSTRAINT fk_audit_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB;

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
    FROM products WHERE product_id = p_product_id FOR UPDATE;

    IF v_stock IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product does not exist.';
    ELSEIF v_stock < p_quantity THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock.';
    END IF;


    SELECT address INTO v_address FROM users WHERE user_id = p_user_id;
    
    IF v_address IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found.';
    END IF;


    INSERT INTO orders (user_id, total_amount, shipping_address, order_status)
    VALUES (p_user_id, fn_line_subtotal(p_quantity, v_price), v_address, 'Pending');

    SET v_order_id = LAST_INSERT_ID();


    INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal)
    VALUES (v_order_id, p_product_id, p_quantity, v_price, fn_line_subtotal(p_quantity, v_price));


    UPDATE products SET stock = stock - p_quantity WHERE product_id = p_product_id;

    COMMIT;
    SELECT v_order_id AS order_id;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_ProcessPayment;
DELIMITER $$
CREATE PROCEDURE sp_ProcessPayment(
    IN p_order_id INT,
    IN p_payment_method ENUM('Cash on Delivery', 'GCash', 'PayPal', 'PayMaya')
)
BEGIN
    DECLARE v_total DECIMAL(10,2);

    SELECT total_amount INTO v_total FROM orders WHERE order_id = p_order_id;

    START TRANSACTION;
    
    INSERT INTO payments (order_id, payment_method, payment_amount, payment_status)
    VALUES (p_order_id, p_payment_method, v_total, 'Completed');

    UPDATE orders SET order_status = 'Paid' WHERE order_id = p_order_id;

    COMMIT;
    SELECT LAST_INSERT_ID() AS payment_id;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS trg_before_order_item_insert;
DELIMITER $$
CREATE TRIGGER trg_before_order_item_insert
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    IF NEW.quantity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantity must be > 0';
    END IF;
    SET NEW.subtotal = fn_line_subtotal(NEW.quantity, NEW.unit_price);
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS trg_after_payment_insert;
DELIMITER $$
CREATE TRIGGER trg_after_payment_insert
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
    DECLARE v_user_id INT;
    SELECT user_id INTO v_user_id FROM orders WHERE order_id = NEW.order_id;

    INSERT INTO audit_logs (payment_id, order_id, user_id, action_type, details)
    VALUES (NEW.payment_id, NEW.order_id, v_user_id, 'PAYMENT_COMPLETED', 
            CONCAT('Method: ', NEW.payment_method, ' | Amt: ', NEW.payment_amount));
END $$
DELIMITER ;