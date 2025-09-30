<?php
class NIF
{
    /**
     * Validate a Portuguese NIF.
     *
     * @param string $nif
     * @return bool
     */
    public static function validate(string $nif): bool
    {
        // Must be 9 digits
        if (!preg_match('/^\d{9}$/', $nif)) {
            return false;
        }

        $digits = str_split($nif);
        $sum = 0;

        // Weighted sum for first 8 digits
        for ($i = 0; $i < 8; $i++) {
            $sum += (9 - $i) * intval($digits[$i]);
        }

        $remainder = $sum % 11;
        $checkDigit = ($remainder == 0 || $remainder == 1) ? 0 : 11 - $remainder;

        return intval($digits[8]) === $checkDigit;
    }

    /**
     * Generate a valid NIF starting with 563XXXXXX
     *
     * @return string
     */
    public static function generate($prefix = "563"): string
    {
         // Generate next 5 random digits
        $middle = "";
        for ($i = 0; $i < 5; $i++) {
            $middle .= strval(random_int(0, 9));
        }

        // Build first 8 digits
        $first8 = $prefix . $middle;

        // Compute check digit
        $digits = str_split($first8);
        $sum = 0;
        for ($i = 0; $i < 8; $i++) {
            $sum += (9 - $i) * intval($digits[$i]);
        }

        $remainder = $sum % 11;
        $checkDigit = ($remainder == 0 || $remainder == 1) ? 0 : 11 - $remainder;

        return $first8 . $checkDigit;
    }
}
