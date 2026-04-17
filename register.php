<?php
require_once 'config.php';

if (isLoggedIn()) {
    header('Location: index.php');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $fullName = trim($_POST['full_name'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';

    if (!$fullName || !$email || strlen($password) < 6) {
        $_SESSION['flash_error'] = 'Username / Full Name, email, and password are required. Password should be at least 6 characters.';
    } else {
        $stmt = $pdo->prepare('SELECT user_id FROM users WHERE email = ?');
        $stmt->execute([$email]);
        if ($stmt->fetch()) {
            $_SESSION['flash_error'] = 'Email already registered.';
        } else {
            $stmt = $pdo->prepare('INSERT INTO users (full_name, email, password_hash, address) VALUES (?, ?, ?, ?)');
            $stmt->execute([$fullName, $email, password_hash($password, PASSWORD_DEFAULT), '']);
            $_SESSION['flash_success'] = 'Account created! Login now.';
            header('Location: login.php');
            exit;
        }
    }
}

require 'includes/header.php';
?>

<h2>Create Account</h2>
<?php if ($msg = flash('flash_error')): ?><div class="alert error"><?= htmlspecialchars($msg) ?></div><?php endif; ?>
<form method="POST" class="form">
  <input name="full_name" placeholder="Username / Full Name" required>
  <input name="email" type="email" placeholder="Email" required>
  <input name="password" type="password" placeholder="Password (min 6 chars)" required>
  <button type="submit">Sign Up</button>
</form>

<?php require 'includes/footer.php'; ?>
