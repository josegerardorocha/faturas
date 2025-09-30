<?php
// test_connection.php

// 1. Require the connection file.
// This executes db.php, establishing the $client and $db objects.
require 'db.php'; 

// Check if the script execution was halted by the 'die()' call in db.php
// If the connection failed, 'db.php' would have already exited.

try {
    // 2. The $db object (selected in db.php) should now be available.
    
    // Ping the deployment to confirm connection
    $client->admin->command(['ping' => 1]);

    // 3. Select the specific collection
    $collection = $db->selectCollection('fatura');

    // 4. Find one document (to confirm data access)
    $document = $collection->findOne([]);

    // 5. Output success message and the retrieved data
    echo "MongoDB connection successful.\n";
    echo "Database: 'faturas', Collection: 'fatura'.\n";

    if ($document) {
        echo "Found a document:\n";
        // Convert the MongoDB object to an array for easy printing
        $data = $document->getArrayCopy(); 
        
        echo "  Name: " . ($data['name'] ?? 'N/A') . "\n";
        echo "  Address: " . ($data['address'] ?? 'N/A') . "\n";
    } else {
        echo "Collection 'fatura' is accessible but empty.\n";
    }

} catch (Exception $e) {
    // This catches exceptions that might occur *after* db.php has executed
    // (e.g., issues during the findOne() operation)
    echo "Database operation error: " . $e->getMessage() . "\n";
}
?>