<?php
session_start();

if (!isset($_SESSION['username'])) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Access denied']);
    exit;
}

header('Content-Type: application/json');
define('SmoothFact', true);
require_once __DIR__ . '/db.php';

$user = $_SESSION['username'];

try {
    $collection = $client->selectDatabase('faturas')->selectCollection('company');

    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        // Find company info for the logged-in user
        $company = $collection->findOne(['user' => $user]);

        if ($company) {
            echo json_encode([
                'success' => true,
                'name'    => $company['name'] ?? '',
                'address' => $company['address'] ?? '',
                'nif'     => $company['nif'] ?? '',
                'niss'    => $company['niss'] ?? ''
            ]);
        } else {
            echo json_encode([
                'success' => true,
                'name'    => '',
                'address' => '',
                'nif'     => '',
                'niss'    => ''
            ]);
        }
        exit;
    }

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $companyName    = $_POST['name'] ?? '';
        $companyAddress = $_POST['address'] ?? '';
        $companyNif     = $_POST['nif'] ?? '';
        $companyNiss    = $_POST['niss'] ?? '';

        if ($companyName === '' || $companyAddress === '') {
            echo json_encode([
                'success' => false,
                'message' => 'Missing required fields'
            ]);
            exit;
        }

        // Upsert: ensure one document per user
        $result = $collection->updateOne(
            ['user' => $user], // match by logged-in user
            ['$set' => [
                'user'       => $user,
                'name'       => $companyName,
                'address'    => $companyAddress,
                'nif'        => $companyNif,
                'niss'       => $companyNiss,
                'updated_at' => new MongoDB\BSON\UTCDateTime()
            ]],
            ['upsert' => true]
        );

        echo json_encode([
            'success'   => true,
            'message'   => 'Company data saved successfully',
            'matched'   => $result->getMatchedCount(),
            'modified'  => $result->getModifiedCount(),
            'upserted'  => $result->getUpsertedCount()
        ]);
        exit;
    }

    // Invalid method
    echo json_encode(['success' => false, 'message' => 'Invalid request']);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
