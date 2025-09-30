<?php
session_start();

if (!isset($_SESSION['username'])) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Access denied']);
    exit;
}

// bank_movement.php
header("Content-Type: text/html; charset=UTF-8");
?>
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    h2 { color: #04AA6D; }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    table, th, td { border: 1px solid black; }
    th, td { padding: 8px; text-align: left; }
    .deposit { color: green; }
    .withdraw { color: red; }
    .actions { margin-top: 20px; }
    .btn {
        padding: 8px 12px;
        background: #04AA6D;
        color: white;
        border: none;
        cursor: pointer;
        border-radius: 4px;
        text-decoration: none;
    }
    .btn:hover { background: #037a52; }
  </style>
</head>
<body>
  <h2>Bank Movements</h2>
  <table>
    <tr><th>Date</th><th>Type</th><th>Amount</th></tr>
    <tr><td>2025-09-01</td><td class="deposit">Deposit</td><td>$500</td></tr>
    <tr><td>2025-09-05</td><td class="withdraw">Withdraw</td><td>$200</td></tr>
    <tr><td>2025-09-10</td><td class="deposit">Deposit</td><td>$100</td></tr>
    <tr><td>2025-09-15</td><td class="withdraw">Withdraw</td><td>$50</td></tr>
  </table>

  <div class="actions">
    <a class="btn" href="bank_movement_excel.php" target="_blank">⬇ Download Excel</a>
  </div>
</body>
</html>
