<?php
require_once 'config.php';
requireLogin();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['request_refund'])) {
    $paymentId = (int)($_POST['payment_id'] ?? 0);
    $reason = trim($_POST['reason'] ?? '');

    if ($paymentId > 0 && $reason !== '') {
        try {
            $refund = $pdo->prepare('CALL sp_ProcessRefund(?, ?)');
            $refund->execute([$paymentId, $reason]);
            $refund->closeCursor();
            $_SESSION['flash_success'] = 'Refund request submitted.';
            header('Location: history.php');
            exit;
        } catch (PDOException $e) {
            $_SESSION['flash_error'] = 'Unable to submit refund request: ' . $e->getMessage();
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
$paymentByOrder = [];
if ($orderIds) {
    $ids = implode(',', array_map('intval', $orderIds));
    $itemRows = $pdo->query("SELECT oi.*, p.product_name FROM order_items oi JOIN products p ON p.product_id = oi.product_id WHERE oi.order_id IN ($ids) ORDER BY oi.order_id DESC")->fetchAll();
    foreach ($itemRows as $row) {
        $itemsByOrder[$row['order_id']][] = $row;
    }

    $paymentRows = $pdo->query("SELECT * FROM payments WHERE order_id IN ($ids)")->fetchAll();
    foreach ($paymentRows as $payment) {
        $paymentByOrder[$payment['order_id']] = $payment;
    }
}

$refundStmt = $pdo->prepare('SELECT r.*, p.order_id FROM refunds r JOIN payments p ON p.payment_id = r.payment_id JOIN orders o ON o.order_id = p.order_id WHERE o.user_id = ? ORDER BY r.requested_at DESC');
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
      <th>Payment Method</th>
      <th>Order Status</th>
      <th>Payment Status</th>
      <th>Total</th>
      <th>Items (Transaction Log)</th>
      <th>Refund</th>
    </tr>
  </thead>
  <tbody>
    <?php foreach ($orders as $order): ?>
      <?php $payment = $paymentByOrder[$order['order_id']] ?? null; ?>
      <tr>
        <td>#<?= (int)$order['order_id'] ?></td>
        <td><?= htmlspecialchars($order['created_at']) ?></td>
        <td><?= htmlspecialchars($payment['payment_method'] ?? 'N/A') ?></td>
        <td><?= htmlspecialchars($order['order_status']) ?></td>
        <td><?= htmlspecialchars($payment['payment_status'] ?? 'N/A') ?></td>
        <td><?= peso((float)$order['total_amount']) ?></td>
        <td>
          <?php foreach ($itemsByOrder[$order['order_id']] ?? [] as $item): ?>
            <div><?= htmlspecialchars($item['product_name']) ?> x <?= (int)$item['quantity'] ?> (<?= peso((float)$item['subtotal']) ?>)</div>
          <?php endforeach; ?>
        </td>
        <td>
          <?php if ($payment): ?>
            <form method="POST">
              <input type="hidden" name="payment_id" value="<?= (int)$payment['payment_id'] ?>">
              <input name="reason" placeholder="Reason" required>
              <button name="request_refund" class="btn secondary">Request</button>
            </form>
          <?php else: ?>
            N/A
          <?php endif; ?>
        </td>
      </tr>
    <?php endforeach; ?>
  </tbody>
</table>
</div>

<h3 style="margin-top:1rem;">Refund Logs</h3>
<div class="table-wrap">
<table>
  <thead><tr><th>Refund ID</th><th>Order</th><th>Payment ID</th><th>Amount</th><th>Reason</th><th>Status</th><th>Date</th></tr></thead>
  <tbody>
    <?php foreach ($refunds as $refund): ?>
      <tr>
        <td>#<?= (int)$refund['refund_id'] ?></td>
        <td>#<?= (int)$refund['order_id'] ?></td>
        <td>#<?= (int)$refund['payment_id'] ?></td>
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
