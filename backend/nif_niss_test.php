<?php
require "nif.php";
require "niss.php";

// Validate
// var_dump(NIF::validate("298001950")); // true
// var_dump(NIF::validate("559707576")); // true
// var_dump(NIF::validate("559707578")); // false

// Generate
echo NIF::generate("249"); echo "\n"; // e.g., 563482315
echo NIF::generate("249"); echo "\n";
echo NIF::generate("249"); echo "\n";
echo NIF::generate("249"); echo "\n";
echo NIF::generate("249"); echo "\n";
echo NIF::generate("249"); echo "\n";
echo NIF::generate("249"); echo "\n";
echo NIF::generate("249"); echo "\n";
echo "\n\n";



// Validate
// var_dump(NISS::validate("12283149648")); // true
// var_dump(NISS::validate("12283349648")); // false

// Generate
echo NISS::generate("12"); echo  "\n"; // e.g., 12098374625
echo NISS::generate("12"); echo  "\n";
echo NISS::generate("12"); echo  "\n";
echo NISS::generate("12"); echo  "\n";
echo NISS::generate("12"); echo  "\n";
echo NISS::generate("12"); echo  "\n";
echo NISS::generate("12"); echo  "\n";
echo NISS::generate("12"); echo  "\n";
echo "\n\n";