<?php
require_once 'config.php';
requireShipper();

$shipper_id = $_SESSION['user']['user_id'];

if (isset($_POST['ship_order'])) {
    $stmt = $pdo->prepare("UPDATE orders SET order_status = 'Shipped', shipper_id = ? WHERE order_id = ?");
    $stmt->execute([$shipper_id, $_POST['order_id']]);
}

if (isset($_POST['deliver_order'])) {
    $stmt = $pdo->prepare("UPDATE orders SET order_status = 'Delivered' WHERE order_id = ?");
    $stmt->execute([$_POST['order_id']]);
}

$pendingOrders = $pdo->query("SELECT o.*, u.full_name FROM orders o JOIN users u ON o.user_id = u.user_id WHERE o.order_status = 'Paid'")->fetchAll();
$myDeliveries = $pdo->prepare("SELECT o.*, u.full_name FROM orders o JOIN users u ON o.user_id = u.user_id WHERE o.shipper_id = ? AND o.order_status = 'Shipped'");
$myDeliveries->execute([$shipper_id]);
$deliveries = $myDeliveries->fetchAll();

require 'includes/header.php';
?>
<h2>Shipper Dashboard</h2>

<h3>Available Orders (To be Shipped)</h3>
<table>
  <tr><th>Order</th><th>Customer</th><th>Address</th><th>Action</th></tr>
  <?php foreach ($pendingOrders as $o): ?>
  <tr>
    <td>#<?= $o['order_id'] ?></td>
    <td><?= htmlspecialchars($o['full_name']) ?></td>
    <td><?= htmlspecialchars($o['shipping_address']) ?></td>
    <td><form method="POST"><input type="hidden" name="order_id" value="<?= $o['order_id'] ?>"><button name="ship_order">Ship This</button></form></td>
  </tr>
  <?php endforeach; ?>
</table>

<h3>My Active Deliveries</h3>
<table>
  <tr><th>Order</th><th>Address</th><th>Action</th></tr>
  <?php foreach ($deliveries as $d): ?>
  <tr>
    <td>#<?= $d['order_id'] ?></td>
    <td><?= htmlspecialchars($d['shipping_address']) ?></td>
    <td><form method="POST"><input type="hidden" name="order_id" value="<?= $d['order_id'] ?>"><button name="deliver_order" style="background:#28a745">Mark as Delivered</button></form></td>
  </tr>
  <?php endforeach; ?>
</table>
<?php require 'includes/footer.php'; ?>