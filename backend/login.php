<?php
require __DIR__ . '/db.php'; // shared DB connection

session_start();
header('Content-Type: application/json');

// Read POST data
$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

if (empty($username) || empty($password)) {
    echo json_encode(["success" => false, "message" => "Username and password required"]);
    exit;
}

try {
    $collection = $db->selectCollection('users');

    // Find user by username
    $user = $collection->findOne(['username' => $username]);

    if (!$user) {
        echo json_encode(["success" => false, "message" => "Invalid username or password"]);
        exit;
    }

    // Verify password
    if (password_verify($password, $user['password'])) {
        // Create session
        $_SESSION['username'] = $username;

        echo json_encode([
            "success" => true,
            "message" => "Login successful",
            "username" => $username
        ]);
    } else {
        echo json_encode(["success" => false, "message" => "Invalid username or password"]);
    }

} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
}
