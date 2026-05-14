<?php
require_once 'config.php';
requireAdmin();

// Toggle Product Status
if (isset($_POST['toggle_product'])) {
    $stmt = $pdo->prepare("UPDATE products SET is_active = NOT is_active WHERE product_id = ?");
    $stmt->execute([$_POST['product_id']]);
}

// Restock
if (isset($_POST['restock'])) {
    $stmt = $pdo->prepare("UPDATE products SET stock = stock + ? WHERE product_id = ?");
    $stmt->execute([(int)$_POST['qty'], $_POST['product_id']]);
}

$users = $pdo->query("SELECT * FROM users WHERE role != 'Admin'")->fetchAll();
$products = $pdo->query("SELECT * FROM products")->fetchAll();
$transactions = $pdo->query("SELECT o.*, u.full_name FROM orders o JOIN users u ON o.user_id = u.user_id ORDER BY o.created_at DESC")->fetchAll();
$totalSales = $pdo->query("SELECT SUM(total_amount) as total FROM orders WHERE order_status != 'Cancelled'")->fetch()['total'];

require 'includes/header.php';
?>
<h2>Admin Dashboard</h2>
<div class="panel"><h3>Total Sales: <?= peso((float)$totalSales) ?></h3></div>

<h3>Products & Inventory</h3>
<table>
  <tr><th>Name</th><th>Stock</th><th>Status</th><th>Actions</th></tr>
  <?php foreach ($products as $p): ?>
  <tr>
    <td><?= htmlspecialchars($p['product_name']) ?></td>
    <td><?= $p['stock'] ?></td>
    <td><?= $p['is_active'] ? 'Active' : 'Disabled' ?></td>
    <td>
      <form method="POST" style="display:inline;"><input type="hidden" name="product_id" value="<?= $p['product_id'] ?>"><button name="toggle_product" class="btn secondary">Toggle</button></form>
      <form method="POST" style="display:inline;"><input type="hidden" name="product_id" value="<?= $p['product_id'] ?>"><input type="number" name="qty" style="width:50px" placeholder="+"><button name="restock">Add</button></form>
    </td>
  </tr>
  <?php endforeach; ?>
</table>

<h3>Users (Customers & Shippers)</h3>
<table>
  <tr><th>Name</th><th>Role</th><th>Service</th></tr>
  <?php foreach ($users as $u): ?>
  <tr><td><?= htmlspecialchars($u['full_name']) ?></td><td><?= $u['role'] ?></td><td><?= $u['delivery_service'] ?? 'N/A' ?></td></tr>
  <?php endforeach; ?>
</table>

<h3>All Transactions</h3>
<table>
  <tr><th>ID</th><th>Customer</th><th>Amount</th><th>Status</th></tr>
  <?php foreach ($transactions as $t): ?>
  <tr><td>#<?= $t['order_id'] ?></td><td><?= htmlspecialchars($t['full_name']) ?></td><td><?= peso((float)$t['total_amount']) ?></td><td><?= $t['order_status'] ?></td></tr>
  <?php endforeach; ?>
</table>
<?php require 'includes/footer.php'; ?>