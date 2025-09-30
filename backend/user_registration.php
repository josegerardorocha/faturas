<?php

define('SmoothFact', true);
require __DIR__ . '/db.php'; // Reuse the shared connection

header('Content-Type: application/json');

// Read POST data
$username = 'john';//$_POST['username'] ?? '';
$password = '123';//$_POST['password'] ?? '';

if (empty($username) || empty($password)) {
    echo json_encode(["success" => false, "message" => "Username and password required"]);
    exit;
}

try {
    $collection = $db->selectCollection('users');

    // Check if username already exists
    $existingUser = $collection->findOne(['username' => $username]);
    if ($existingUser) {
        echo json_encode(["success" => false, "message" => "Username already taken"]);
        exit;
    }

    // Hash password
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

    // Insert user
    $result = $collection->insertOne([
        'username' => $username,
        'password' => $hashedPassword,
        'created_at' => new MongoDB\BSON\UTCDateTime()
    ]);

    if ($result->getInsertedCount() > 0) {
        echo json_encode(["success" => true, "message" => "User registered successfully"]);
    } else {
        echo json_encode(["success" => false, "message" => "Failed to register user"]);
    }

} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Database error: " . $e->getMessage()]);
}
