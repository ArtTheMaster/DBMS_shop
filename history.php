<?php
require_once 'config.php';
requireLogin();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['request_refund'])) {
    $orderId = (int)($_POST['order_id'] ?? 0);
    $reason = trim($_POST['reason'] ?? '');

    if ($orderId > 0 && $reason !== '') {
        $stmt = $pdo->prepare('SELECT total_amount FROM orders WHERE order_id = ? AND user_id = ?');
        $stmt->execute([$orderId, $_SESSION['user']['user_id']]);
        $order = $stmt->fetch();

        if ($order) {
            $insert = $pdo->prepare('INSERT INTO refunds (order_id, reason, refund_amount) VALUES (?, ?, ?)');
            $insert->execute([$orderId, $reason, $order['total_amount']]);
            $_SESSION['flash_success'] = 'Refund request submitted.';
            header('Location: history.php');
            exit;
        }
    }

    $_SESSION['flash_error'] = 'Unable to submit refund request.';
    header('Location: history.php');
    exit;
}

$ordersStmt = $pdo->prepare('SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC');
$ordersStmt->execute([$_SESSION['user']['user_id']]);
$orders = $ordersStmt->fetchAll();

$orderIds = array_column($orders, 'order_id');
$itemsByOrder = [];
if ($orderIds) {
    $ids = implode(',', array_map('intval', $orderIds));
    $itemRows = $pdo->query("SELECT oi.*, p.product_name FROM order_items oi JOIN products p ON p.product_id = oi.product_id WHERE oi.order_id IN ($ids) ORDER BY oi.order_id DESC")->fetchAll();
    foreach ($itemRows as $row) {
        $itemsByOrder[$row['order_id']][] = $row;
    }
}

$refundStmt = $pdo->prepare('SELECT r.*, o.user_id FROM refunds r JOIN orders o ON o.order_id = r.order_id WHERE o.user_id = ? ORDER BY r.requested_at DESC');
$refundStmt->execute([$_SESSION['user']['user_id']]);
$refunds = $refundStmt->fetchAll();

require 'includes/header.php';
?>

<h2>Transaction / Order History</h2>
<?php if ($msg = flash('flash_success')): ?><div class="alert success"><?= htmlspecialchars($msg) ?></div><?php endif; ?>
<?php if ($msg = flash('flash_error')): ?><div class="alert error"><?= htmlspecialchars($msg) ?></div><?php endif; ?>

<div class="table-wrap">
<table>
  <thead>
    <tr>
      <th>Order ID</th>
      <th>Date</th>
      <th>Payment</th>
      <th>Status</th>
      <th>Total</th>
      <th>Items (Transaction Log)</th>
      <th>Refund</th>
    </tr>
  </thead>
  <tbody>
    <?php foreach ($orders as $order): ?>
      <tr>
        <td>#<?= (int)$order['order_id'] ?></td>
        <td><?= htmlspecialchars($order['created_at']) ?></td>
        <td><?= htmlspecialchars($order['payment_mode']) ?></td>
        <td><?= htmlspecialchars($order['order_status']) ?></td>
        <td><?= peso((float)$order['total_amount']) ?></td>
        <td>
          <?php foreach ($itemsByOrder[$order['order_id']] ?? [] as $item): ?>
            <div><?= htmlspecialchars($item['product_name']) ?> x <?= (int)$item['quantity'] ?> (<?= peso((float)$item['subtotal']) ?>)</div>
          <?php endforeach; ?>
        </td>
        <td>
          <form method="POST">
            <input type="hidden" name="order_id" value="<?= (int)$order['order_id'] ?>">
            <input name="reason" placeholder="Reason" required>
            <button name="request_refund" class="btn secondary">Request</button>
          </form>
        </td>
      </tr>
    <?php endforeach; ?>
  </tbody>
</table>
</div>

<h3 style="margin-top:1rem;">Refund Logs</h3>
<div class="table-wrap">
<table>
  <thead><tr><th>Refund ID</th><th>Order</th><th>Amount</th><th>Reason</th><th>Status</th><th>Date</th></tr></thead>
  <tbody>
    <?php foreach ($refunds as $refund): ?>
      <tr>
        <td>#<?= (int)$refund['refund_id'] ?></td>
        <td>#<?= (int)$refund['order_id'] ?></td>
        <td><?= peso((float)$refund['refund_amount']) ?></td>
        <td><?= htmlspecialchars($refund['reason']) ?></td>
        <td><?= htmlspecialchars($refund['status']) ?></td>
        <td><?= htmlspecialchars($refund['requested_at']) ?></td>
      </tr>
    <?php endforeach; ?>
  </tbody>
</table>
</div>

<?php require 'includes/footer.php'; ?>
