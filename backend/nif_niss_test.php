<?php
require "nif.php";
require "niss.php";

// Validate
var_dump(NIF::validate("298001950")); // true
var_dump(NIF::validate("559707576")); // true
var_dump(NIF::validate("559707578")); // false

// Generate
echo NIF::generate(); // e.g., 563482315
echo "\n\n";



// Validate
var_dump(NISS::validate("12283149648")); // true
var_dump(NISS::validate("12283349648")); // false

// Generate
echo NISS::generate("12"); // e.g., 12098374625
echo "\n\n";