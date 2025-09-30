<?php
session_start();

if (!isset($_SESSION['username'])) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Access denied']);
    exit;
}

require __DIR__ . '/vendor/autoload.php';

use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;

$spreadsheet = new Spreadsheet();
$sheet = $spreadsheet->getActiveSheet();

// Table headers
$sheet->setCellValue('A1', 'Date');
$sheet->setCellValue('B1', 'Type');
$sheet->setCellValue('C1', 'Amount');

// Static data (later replace with DB or JSON)
$data = [
    ['2025-09-01', 'Deposit', 500],
    ['2025-09-05', 'Withdraw', 200],
    ['2025-09-10', 'Deposit', 100],
    ['2025-09-15', 'Withdraw', 50],
];

// Fill data
$row = 2;
foreach ($data as $movement) {
    $sheet->setCellValue("A$row", $movement[0]);
    $sheet->setCellValue("B$row", $movement[1]);
    $sheet->setCellValue("C$row", $movement[2]);
    $row++;
}

// Style header row
$headerStyle = [
    'font' => ['bold' => true],
    'borders' => [
        'bottom' => ['borderStyle' => \PhpOffice\PhpSpreadsheet\Style\Border::BORDER_THIN],
    ],
];
$sheet->getStyle('A1:C1')->applyFromArray($headerStyle);

// Autosize columns
foreach (range('A', 'C') as $col) {
    $sheet->getColumnDimension($col)->setAutoSize(true);
}

// Output to browser
header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
header('Content-Disposition: attachment;filename="bank_movements.xlsx"');
header('Cache-Control: max-age=0');

$writer = new Xlsx($spreadsheet);
$writer->save('php://output');
exit;
