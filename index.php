<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['add_to_cart'])) {
        $productId = (int)($_POST['product_id'] ?? 0);
        if ($productId > 0) {
            $_SESSION['cart'][$productId] = ($_SESSION['cart'][$productId] ?? 0) + 1;
            $_SESSION['flash_success'] = 'Item added to cart.';
        }
    }

    if (isset($_POST['update_qty'])) {
        $productId = (int)($_POST['product_id'] ?? 0);
        $qty = max(0, (int)($_POST['qty'] ?? 0));
        if ($productId > 0) {
            if ($qty === 0) {
                unset($_SESSION['cart'][$productId]);
            } else {
                $_SESSION['cart'][$productId] = $qty;
            }
            $_SESSION['flash_success'] = 'Cart updated.';
        }
    }

    if (isset($_POST['clear_cart'])) {
        $_SESSION['cart'] = [];
        $_SESSION['flash_success'] = 'Cart cleared.';
    }

    header('Location: index.php');
    exit;
}

$products = $pdo->query('SELECT * FROM products WHERE is_active = 1 ORDER BY created_at DESC')->fetchAll();
$cartItems = [];
$grandTotal = 0;
if (!empty($_SESSION['cart'])) {
    $ids = implode(',', array_map('intval', array_keys($_SESSION['cart'])));
    $rows = $pdo->query("SELECT * FROM products WHERE product_id IN ($ids)")->fetchAll();
    foreach ($rows as $row) {
        $qty = $_SESSION['cart'][$row['product_id']];
        $subtotal = $qty * (float)$row['price'];
        $grandTotal += $subtotal;
        $cartItems[] = ['product' => $row, 'qty' => $qty, 'subtotal' => $subtotal];
    }
}

require 'includes/header.php';
?>

<section class="hero">
  <div class="hero-card">
    <h1>Art Workshop Store • Commissions + Materials</h1>
    <p>Explore unique illustrations, custom commissions, drawings, and art tools. Login to place orders and generate your DBMS transaction logs.</p>
    <p><strong>Price rules:</strong> Drawings / Illustrations / Commissions: <strong>₱50-₱100</strong> • Art Materials: <strong>₱150-₱300</strong>.</p>
  </div>
  <div class="panel">
    <h3>DBMS Features Included</h3>
    <ul>
      <li>Basic SQL tables for users, orders, order_items, products, refunds</li>
      <li>Stored Procedure for checkout transaction processing</li>
      <li>Stored Function for subtotal calculations</li>
      <li>Login-required checkout and transaction history</li>
    </ul>
  </div>
</section>

<?php if ($msg = flash('flash_error')): ?><div class="alert error"><?= htmlspecialchars($msg) ?></div><?php endif; ?>
<?php if ($msg = flash('flash_success')): ?><div class="alert success"><?= htmlspecialchars($msg) ?></div><?php endif; ?>

<div class="shop-layout" style="display:grid; grid-template-columns: 2fr 1fr; gap:1rem; align-items:start;">
  <section>
    <div class="filters">
      <?php foreach (['All','Commission','Illustration','Drawing','Art Material'] as $category): ?>
      <button class="filter-chip <?= $category === 'All' ? 'active' : '' ?>" data-filter="<?= $category ?>"><?= $category ?></button>
      <?php endforeach; ?>
    </div>

    <div class="product-grid">
      <?php foreach ($products as $product): ?>
        <article class="product" data-category="<?= htmlspecialchars($product['category']) ?>">
          <?php if (!empty($product['image_path']) && file_exists($product['image_path'])): ?>
            <img src="<?= htmlspecialchars($product['image_path']) ?>" alt="<?= htmlspecialchars($product['product_name']) ?>">
          <?php else: ?>
            <div class="img-placeholder"><?= htmlspecialchars($product['category']) ?></div>
          <?php endif; ?>
          <div class="content">
            <h3><?= htmlspecialchars($product['product_name']) ?></h3>
            <p><?= htmlspecialchars($product['description']) ?></p>
            <div class="price-stock">
              <strong><?= peso((float)$product['price']) ?></strong>
              <small>Stock: <?= (int)$product['stock'] ?></small>
            </div>
            <form method="POST">
              <input type="hidden" name="product_id" value="<?= (int)$product['product_id'] ?>">
              <button type="submit" name="add_to_cart">Add to Cart</button>
            </form>
          </div>
        </article>
      <?php endforeach; ?>
    </div>
  </section>

  <aside class="cart">
    <h3>Your Cart</h3>
    <?php if (!$cartItems): ?>
      <p style="color:var(--muted)">No items yet.</p>
    <?php else: ?>
      <?php foreach ($cartItems as $item): ?>
        <div class="cart-row">
          <div>
            <strong><?= htmlspecialchars($item['product']['product_name']) ?></strong><br>
            <small><?= peso($item['subtotal']) ?></small>
          </div>
          <form method="POST" style="display:flex; gap:.4rem; align-items:center;">
            <input type="hidden" name="product_id" value="<?= (int)$item['product']['product_id'] ?>">
            <input name="qty" type="number" min="0" max="99" value="<?= (int)$item['qty'] ?>" style="width:65px;">
            <button name="update_qty" class="btn secondary">Update</button>
          </form>
        </div>
      <?php endforeach; ?>
      <hr style="border-color:var(--border)">
      <p><strong>Total: <?= peso($grandTotal) ?></strong></p>
      <form method="POST" style="margin-bottom:.6rem;"><button name="clear_cart" class="btn secondary">Clear Cart</button></form>
      <a class="btn" style="display:inline-block; text-decoration:none;" href="checkout.php">Proceed to Checkout</a>
    <?php endif; ?>
  </aside>
</div>

<?php require 'includes/footer.php'; ?>
