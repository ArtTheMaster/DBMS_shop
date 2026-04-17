CREATE DATABASE IF NOT EXISTS artshop_dbms;
USE artshop_dbms;

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
('Hungry? Pin/Sticker Design', 'Illustration', 90.00, 8, 'assets/images/Hungry aint you.png', 'Holiday themed nom nom nom nom custom character commission.'),
('Take Your time hehehhe', 'Illustration', 75.00, 12, 'assets/images/Take your time heheh Digital.png', '(Insert Bunny pointing to time meme).'),
('What.. Pin/Sticker Design', 'Drawing', 55.00, 15, 'assets/images/What....png', 'guy in the reindeer suit nonchalant lololol.'),
('some Lighting god idk Pin/Sticker Design', 'Illustration', 60.00, 9, 'assets/images/Be Carefull !!.png', 'Construct of Lightning on its Vacation.'),
('MAXX NITROOOO', 'Commission', 180.00, 12, 'assets/images/MAXX NITROO.png', 'Yeah im MAXXING It, Im MAXXING It, Im MAXXING It.'),
('Taski Maiden Pin/Sticker Design', 'Illustration', 60.00, 12, 'assets/images/Taski Maiden.jpg', 'T̵͓͈͎̙͐͑͗̀̈͘͠ȧ̸̡̪̼̥͖̗̬̓̓́͊̉̚̚͜s̷̥͈̙̼̯̩̬̅̚k̵̟̥̄į̷͖̺͆̈́͛̍̚͜ͅ ̸̨̠̖͔̼̀̀̔̋̑̀̊M̵̢̛͎̓̒̎͗͠ͅa̵̗̠̙̼͓͐͌͑̾̓̿i̴̘͖̯̹̳̇͛͛d̴̜̱̂͌̑̎̆͝e̸̢̛͍͙̬̞̘͈̜̎̀̿͂̈́̕n̵͍̈́͑.'),
('Cindra Body Pillow Design', 'Commission', 300.00, 12, 'assets/images/Cindra Dracai of Retribution Digital.png', '( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°)( ͡° ͜ʖ ͡°).'),
('Bolt n Chocos Pin/Sticker Design', 'Illustration', 60.00, 12, 'assets/images/Bolt n Chocos.png', 'A hot Cocoa and a cat on your head, What else do you need?.'),
('MODELO', 'Commission', 180.00, 12, 'assets/images/Modelo Digital.jpg', 'FAAAAAAHHHH.'),
('FEALTY Token', 'Commission', 180.00, 12, 'assets/images/Fealty.jpg', 'Fealty card token card design for the hit trading card game Flesh and blood.'),
('Black Clover Sketch', 'Drawing', 60.00, 12, 'assets/images/Black Clover Manga.png', 'Sketch of Asta from the anime Black Clover.'),
('FFXV Sketch', 'Drawing', 60.00, 12, 'assets/images/FFXV Sketch.jpeg', 'Final Fantasy XV sketch.'),
('Garou Saitama Mode Sketch', 'Drawing', 60.00, 12, 'assets/images/Garou Saitama Mode Manga.jpeg', 'A sketch of Garou in his Saitama mode.'),
('Gojo vs Sukuna Sketch', 'Drawing', 60.00, 12, 'assets/images/Gojo vs Sukuna Manga.jpeg', 'The strongest sorcerer in history vs the strongest sorcerer of today.'),
('Jiraiya Sketch', 'Drawing', 60.00, 12, 'assets/images/Jiraiya Manga.jpeg', 'A sketch of Jiraiya from the Naruto series.'),
('Owl Sketch', 'Drawing', 60.00, 12, 'assets/images/Owl Sketch.jpeg', 'Hoot Hoot.'),
('Reze Sketch', 'Drawing', 60.00, 12, 'assets/images/Reze Chainsaw ManSketch.jpeg', 'Bang.'),
('Snek Lady Sketch', 'Drawing', 60.00, 12, 'assets/images/Snek Lady Sketch.jpeg', '"i shouldnt put it in there, but...".'),
('Tanjiro Kamado Sketch', 'Drawing', 60.00, 12, 'assets/images/Tanjiro Kamado Sketch.jpeg', 'A sketch of Tanjiro Kamado from Demon Slayer.'),
('Smoker', 'Illustration', 60.00, 12, 'assets/images/Madame Red Smoke Digital.jpg', '"want a puff love?".'),
('White Pen', 'Art Material', 55.00, 30, 'assets/images/White_Pen.jpeg', 'pen that is... white.'),
('Gravity Pen', 'Art Material', 180.00, 40, 'assets/images/Gravity_Pen.jpeg', 'Pen you can use anywhere, on water, wet paper,space or oily skin.'),
('Pencil', 'Art Material', 5.00, 35, 'assets/images/Pencil.jpeg', 'Just your everyday pencil.'),
('Mechanical Pencil', 'Art Material', 100.00, 25, 'assets/images/Mechanical_Pencil.jpeg', 'Mechanized Pencil, with 3 0.5mm leads fills for free !!.'),
('Rolling Pen', 'Art Material', 67.00, 35, 'assets/images/Rolling_Pen.jpeg', 'for your writing needs.'),
('Sketch Pencil Set', 'Art Material', 155.00, 35, 'assets/images/Sketch Pencil Set.jpeg', 'Set of pencils for drawing or sketching.'),
('Fineliner set', 'Art Material', 234.00, 35, 'assets/images/Fineliner_set.jpeg', 'Set of fineliners for detailed drawing.');


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
