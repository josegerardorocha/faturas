<?php
header('Content-Type: application/json');

// Default values (for now, hardcoded)
$defaultName = "ACME Corporation";
$defaultAddress = "123 Main Street\nSpringfield, USA";

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Return default data
    echo json_encode([
        'success' => true,
        'name' => $defaultName,
        'address' => $defaultAddress
    ]);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $companyName = $_POST['name'] ?? '';
    $companyAddress = $_POST['address'] ?? '';

    // For now, just echo what we received
    echo json_encode([
        'success' => true,
        'message' => 'Data received successfully',
        'received' => [
            'name' => $companyName,
            'address' => $companyAddress
        ]
    ]);
    exit;
}

// Fallback
echo json_encode(['success' => false, 'message' => 'Invalid request']);
?>
