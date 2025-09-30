<?php
session_start();

if (!isset($_SESSION['username'])) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Access denied']);
    exit;
}

require "nif.php";
header('Content-Type: application/json');
echo json_encode(['value' => NIF::generate("563")]);

