<?php

// Para apagar...

require 'vendor/autoload.php';

use MongoDB\Client;
use MongoDB\Driver\ServerApi;

// Connection string (same as you used for ping)
$uri = "mongodb+srv://bolsa_user:EPT8Xf5r1ZVulH46@bolsa.1ne8e9l.mongodb.net/?retryWrites=true&w=majority&appName=Bolsa"; 
$apiVersion = new ServerApi(ServerApi::V1);
$client = new Client($uri, [], ['serverApi' => $apiVersion]);

try {
    // Select the database and collection
    $collection = $client->selectDatabase('faturas')->selectCollection('fatura');

    // Fetch all documents
    $cursor = $collection->find([]);

    echo "<h2>Faturas Collection</h2>";
    echo "<table border='1' cellpadding='5'>";
    echo "<tr><th>Name</th><th>Address</th></tr>";

    foreach ($cursor as $doc) {
        $name = $doc['name'] ?? '';
        $address = $doc['address'] ?? '';
        echo "<tr><td>" . htmlspecialchars($name) . "</td><td>" . nl2br(htmlspecialchars($address)) . "</td></tr>";
    }

    echo "</table>";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
