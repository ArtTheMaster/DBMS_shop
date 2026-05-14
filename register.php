<?php
require_once 'config.php';
if (isLoggedIn()) { header('Location: index.php'); exit; }

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $fullName = trim($_POST['full_name'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';
    $role = $_POST['role'] ?? 'Customer';
    $service = trim($_POST['delivery_service'] ?? '');

    if (!$fullName || !$email || strlen($password) < 6) {
        $_SESSION['flash_error'] = 'All fields are required. Password min 6 chars.';
    } else {
        $stmt = $pdo->prepare('SELECT user_id FROM users WHERE email = ?');
        $stmt->execute([$email]);
        if ($stmt->fetch()) {
            $_SESSION['flash_error'] = 'Email already registered.';
        } else {
            $stmt = $pdo->prepare('INSERT INTO users (full_name, email, password_hash, role, delivery_service, address) VALUES (?, ?, ?, ?, ?, ?)');
            $stmt->execute([$fullName, $email, password_hash($password, PASSWORD_DEFAULT), $role, ($role === 'Shipper' ? $service : null), '']);
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
  <input name="full_name" placeholder="Full Name" required>
  <input name="email" type="email" placeholder="Email" required>
  <input name="password" type="password" placeholder="Password (min 6 chars)" required>
  <select name="role" id="roleSelect" required onchange="toggleService()">
      <option value="Customer">Customer</option>
      <option value="Shipper">Shipper / Deliverer</option>
  </select>
  <div id="serviceBox" style="display:none;">
      <select name="delivery_service">
          <option value="">Select Service</option>
          <option>JNT</option>
          <option>Lalamove</option>
          <option>NinjaCab</option>
          <option>Gmove</option>
          <option>Delivery ni Art</option>
      </select>
  </div>
  <button type="submit">Sign Up</button>
</form>
<script>
function toggleService() {
    document.getElementById('serviceBox').style.display = (document.getElementById('roleSelect').value === 'Shipper') ? 'block' : 'none';
}
</script>
<?php require 'includes/footer.php'; ?>