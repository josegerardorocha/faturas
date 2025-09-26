<?php
header('Content-Type: application/json');

$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

if ($username === 'john' && $password === '123') {
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false]);
}
?>
