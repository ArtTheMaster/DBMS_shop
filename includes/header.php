<?php require_once __DIR__ . '/../config.php'; ?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><?= SITE_NAME ?></title>
  <link rel="stylesheet" href="assets/css/styles.css">
</head>
<body>
  <div class="container">
    <nav class="nav">
<<<<<<< ours
      <div class="logo">í¾¨ <?= SITE_NAME ?></div>
=======
      <div class="logo"><?= SITE_NAME ?></div>
>>>>>>> theirs
      <div style="display:flex; gap:.45rem; align-items:center; flex-wrap:wrap; justify-content:end;">
        <a class="btn secondary" href="index.php">Shop</a>
        <?php if (isLoggedIn()): ?>
          <a class="btn secondary" href="history.php">Transaction Log</a>
          <span style="font-size:.9rem;"><?= htmlspecialchars($_SESSION['user']['full_name']) ?></span>
          <a class="btn" href="logout.php">Logout</a>
        <?php else: ?>
          <a class="btn secondary" href="login.php">Login</a>
          <a class="btn" href="register.php">Sign Up</a>
        <?php endif; ?>
<<<<<<< ours
        <button id="themeToggle" class="btn secondary" type="button">í¼“</button>
=======
        <button id="themeToggle" class="btn secondary" type="button">Theme</button>
>>>>>>> theirs
      </div>
    </nav>
