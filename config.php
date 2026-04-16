<?php
session_start();

define('DB_HOST', '127.0.0.1');
define('DB_NAME', 'artshop_dbms');
define('DB_USER', 'root');
define('DB_PASS', '');

<<<<<<< ours
define('SITE_NAME', 'Art Shop');
=======
define('SITE_NAME', 'Atelier Art Shop');
>>>>>>> theirs

date_default_timezone_set('Asia/Manila');

try {
    $pdo = new PDO(
        'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4',
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]
    );
} catch (PDOException $e) {
    die('Database connection failed: ' . $e->getMessage());
}

function isLoggedIn(): bool
{
    return isset($_SESSION['user']);
}

function requireLogin(): void
{
    if (!isLoggedIn()) {
        $_SESSION['flash_error'] = 'Please login first before checkout.';
        header('Location: login.php');
        exit;
    }
}

function flash(string $key): ?string
{
    if (!isset($_SESSION[$key])) {
        return null;
    }

    $message = $_SESSION[$key];
    unset($_SESSION[$key]);
    return $message;
}

function peso(float $amount): string
{
    return '₱' . number_format($amount, 2);
}

if (!isset($_SESSION['cart'])) {
    $_SESSION['cart'] = [];
}
