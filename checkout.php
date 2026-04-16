<?php
require_once 'config.php';
requireLogin();

if (empty($_SESSION['cart'])) {
    $_SESSION['flash_error'] = 'Your cart is empty.';
    header('Location: index.php');
    exit;
}

$ids = implode(',', array_map('intval', array_keys($_SESSION['cart'])));
$products = $pdo->query("SELECT product_id, product_name, price, stock FROM products WHERE product_id IN ($ids)")->fetchAll();

$cartForProcedure = [];
$summary = [];
$total = 0;
foreach ($products as $product) {
    $qty = (int)$_SESSION['cart'][$product['product_id']];
    $subtotal = $qty * (float)$product['price'];
    $total += $subtotal;
    $cartForProcedure[] = [
        'product_id' => (int)$product['product_id'],
        'quantity' => $qty,
    ];
    $summary[] = [
        'name' => $product['product_name'],
        'qty' => $qty,
        'subtotal' => $subtotal,
    ];
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $paymentMode = $_POST['payment_mode'] ?? '';
    $address = trim($_POST['shipping_address'] ?? '');
    $validModes = ['Cash on Delivery', 'GCash', 'PayPal', 'PayMaya'];

    if (!in_array($paymentMode, $validModes, true) || !$address) {
        $_SESSION['flash_error'] = 'Please select payment mode and shipping address.';
    } else {
        try {
            $stmt = $pdo->prepare('CALL sp_place_order(?, ?, ?, ?)');
            $stmt->execute([
                $_SESSION['user']['user_id'],
                $paymentMode,
                $address,
                json_encode($cartForProcedure),
            ]);
            $stmt->closeCursor();
            $_SESSION['cart'] = [];
            $_SESSION['flash_success'] = 'Order successfully placed!';
            header('Location: history.php');
            exit;
        } catch (PDOException $e) {
            $_SESSION['flash_error'] = 'Checkout failed: ' . $e->getMessage();
        }
    }
}

require 'includes/header.php';
?>

<h2>Checkout</h2>
<?php if ($msg = flash('flash_error')): ?><div class="alert error"><?= htmlspecialchars($msg) ?></div><?php endif; ?>

<div class="panel" style="margin-bottom:1rem;">
  <?php foreach ($summary as $row): ?>
    <p><?= htmlspecialchars($row['name']) ?> • Qty <?= $row['qty'] ?> • <strong><?= peso($row['subtotal']) ?></strong></p>
  <?php endforeach; ?>
  <h3>Total: <?= peso($total) ?></h3>
</div>

<form method="POST" class="form">
  <select name="payment_mode" required>
    <option value="">Select Payment Mode</option>
    <option>Cash on Delivery</option>
    <option>GCash</option>
    <option>PayPal</option>
    <option>PayMaya</option>
  </select>
  <textarea name="shipping_address" required><?= htmlspecialchars($_SESSION['user']['address']) ?></textarea>
  <button type="submit">Place Order</button>
</form>

<?php require 'includes/footer.php'; ?>
