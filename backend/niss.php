<?php
session_start();

if (!isset($_SESSION['username'])) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Access denied']);
    exit;
}

class NISS
{
    /**
     * Validate a Portuguese NISS.
     *
     * @param string $niss
     * @return bool
     */
    public static function validate(string $niss): bool
    {
        // Must be 11 digits
        if (!preg_match('/^\d{11}$/', $niss)) {
            return false;
        }

        $digits = str_split($niss);
        $sum = 0;

        // Weights from 29 down to 20 for first 10 digits
        for ($i = 0; $i < 10; $i++) {
            $sum += (29 - $i) * intval($digits[$i]);
        }

        $remainder = $sum % 10;
        $checkDigit = ($remainder == 0) ? 0 : 10 - $remainder;

        return intval($digits[10]) === $checkDigit;
    }

    /**
     * Generate a valid NISS with a given prefix (default 12XXXXXXXX).
     *
     * @param string $prefix
     * @return string
     */
    public static function generate(string $prefix = "12"): string
    {
        if (!preg_match('/^\d{2}$/', $prefix)) {
            throw new InvalidArgumentException("Prefix must be 2 digits.");
        }

        // Generate next 8 random digits
        $middle = "";
        for ($i = 0; $i < 8; $i++) {
            $middle .= strval(random_int(0, 9));
        }

        // First 10 digits
        $first10 = $prefix . $middle;

        // Compute check digit
        $digits = str_split($first10);
        $sum = 0;
        for ($i = 0; $i < 10; $i++) {
            $sum += (29 - $i) * intval($digits[$i]);
        }

        $remainder = $sum % 10;
        $checkDigit = ($remainder == 0) ? 0 : 10 - $remainder;

        return $first10 . $checkDigit;
    }
}
