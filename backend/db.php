<?php
if (!defined('SmoothFact')) {
    die('Direct access not allowed');
}

require __DIR__ . '/vendor/autoload.php';

use MongoDB\Client;
use MongoDB\Driver\ServerApi;

//$uri = "mongodb+srv://bolsa_user:EPT8Xf5r1ZVulH46@bolsa.1ne8e9l.mongodb.net/?retryWrites=true&w=majority&appName=Bolsa";
$uri = "mongodb://localhost:27017/faturas";
$apiVersion = new ServerApi(ServerApi::V1);

try {
    $client = new Client($uri, [], ['serverApi' => $apiVersion]);
    // You can pick your default DB here if you want
    $db = $client->selectDatabase('faturas');
} catch (Exception $e) {
    die("MongoDB connection error: " . $e->getMessage());
}
