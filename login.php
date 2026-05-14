<?php
require_once 'config.php';
if (isLoggedIn()) { header('Location: index.php'); exit; }

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';
    $stmt = $pdo->prepare('SELECT * FROM users WHERE email = ?');
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if ($user && password_verify($password, $user['password_hash'])) {
        $_SESSION['user'] = [
            'user_id' => $user['user_id'],
            'full_name' => $user['full_name'],
            'email' => $user['email'],
            'role' => $user['role'],
            'address' => $user['address'],
        ];
        if ($user['role'] === 'Admin') header('Location: admin.php');
        elseif ($user['role'] === 'Shipper') header('Location: shipper.php');
        else header('Location: index.php');
        exit;
    }
    $_SESSION['flash_error'] = 'Invalid credentials.';
}
require 'includes/header.php';
?>
<h2>Login</h2>
<?php if ($msg = flash('flash_error')): ?><div class="alert error"><?= htmlspecialchars($msg) ?></div><?php endif; ?>
<form method="POST" class="form">
  <input name="email" type="email" placeholder="Email" required>
  <input name="password" type="password" placeholder="Password" required>
  <button type="submit">Login</button>
</form>
<?php require 'includes/footer.php'; ?>