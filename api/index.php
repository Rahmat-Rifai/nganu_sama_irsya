<?php
/**
 * Pngumpul REST API Router
 * Mendukung PHP 7.4+ / PHP 8.x (Laragon, XAMPP, Apache, Nginx)
 */

declare(strict_types=1);

// Enable CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

header('Content-Type: application/json; charset=utf-8');

// Load database connection
$pdo = null;
$configFile = __DIR__ . '/config/database.php';
if (file_exists($configFile)) {
    try {
        $pdo = require $configFile;
    } catch (\Throwable $e) {
        // Fallback gracefully if database server is not running
        $pdo = null;
    }
}

$method = $_SERVER['REQUEST_METHOD'];
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
// Normalize uri path relative to /api
$path = preg_replace('#^.*?/api#', '/api', $uri);

$input = json_decode((string)file_get_contents('php://input'), true) ?? [];

// Helper response
function jsonResponse(int $code, array $data): void {
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}

// 1. Auth Login
if ($path === '/api/auth/login' && $method === 'POST') {
    $identifier = trim($input['identifier'] ?? '');
    $password = trim($input['password'] ?? '');

    if (stripos($identifier, 'budi') !== false) {
        jsonResponse(200, [
            'success' => true,
            'user' => [
                'name' => 'Drs. Budi Santoso',
                'nip' => '197505122002121001',
                'email' => 'budi@sekolah.sch.id',
                'role' => 'teacher',
                'subjects' => ['Pemrograman Web', 'Basis Data'],
                'classes' => ['X RPL 1', 'X RPL 2', 'XI RPL 1'],
            ]
        ]);
    } else {
        jsonResponse(200, [
            'success' => true,
            'user' => [
                'name' => 'Ahmad Rizky Pratama',
                'nisn' => $identifier ?: '0081293812',
                'class' => 'X RPL 1',
                'role' => 'student'
            ]
        ]);
    }
}

// 2. Tasks API
if ($path === '/api/tasks') {
    if ($method === 'GET') {
        $filterClass = $_GET['class'] ?? 'all';
        $tasks = [
            [
                'id' => 1,
                'title' => 'Layout Responsive CSS Grid & Flexbox',
                'subject' => 'Pemrograman Web',
                'targetClass' => 'X RPL 1',
                'due' => '2026-11-15T23:59',
                'dueFormatted' => '15 Nov, 23:59 WIB',
                'status' => 'published',
                'submittedCount' => 2,
                'totalStudents' => 32,
                'desc' => 'Struktur antarmuka responsif tanpa AI boilerplate beracuan desain Pngumpul.'
            ],
            [
                'id' => 2,
                'title' => 'Desain Skema ERD MySQL dan Normalisasi',
                'subject' => 'Basis Data',
                'targetClass' => 'X RPL 2',
                'due' => '2026-11-18T17:00',
                'dueFormatted' => '18 Nov, 17:00 WIB',
                'status' => 'published',
                'submittedCount' => 0,
                'totalStudents' => 30,
                'desc' => 'Rancang ERD sistem database relasional minimal 8 tabel relasi lengkap.'
            ]
        ];

        if ($filterClass !== 'all') {
            $tasks = array_values(array_filter($tasks, fn($t) => $t['targetClass'] === $filterClass));
        }

        jsonResponse(200, $tasks);
    }

    if ($method === 'POST') {
        $newTask = [
            'id' => (int)(microtime(true) * 1000),
            'title' => $input['title'] ?? 'Tugas Baru',
            'subject' => $input['subject'] ?? 'Pemrograman Web',
            'targetClass' => $input['targetClass'] ?? 'X RPL 1',
            'due' => $input['due'] ?? date('Y-m-d\TH:i'),
            'dueFormatted' => !empty($input['due']) ? str_replace('T', ', ', $input['due']) . ' WIB' : 'Sesuai jadwal',
            'status' => 'published',
            'submittedCount' => 0,
            'totalStudents' => 32,
            'desc' => $input['desc'] ?? ''
        ];
        jsonResponse(201, ['success' => true, 'task' => $newTask]);
    }
}

// 3. Submissions API
if ($path === '/api/submissions') {
    if ($method === 'GET') {
        $nisn = $_GET['nisn'] ?? null;
        $subs = [
            [
                'id' => 1,
                'taskId' => 1,
                'student' => 'Ahmad Rizky Pratama',
                'nisn' => '0081293812',
                'class' => 'X RPL 1',
                'taskTitle' => 'Tugas 01: CSS Responsive',
                'fileName' => 'Laporan_Tugas01.pdf',
                'fileUrl' => '/uploads/submissions/Laporan_Tugas01.pdf',
                'answerText' => 'Selamat siang Pak, berikut laporan tugas pengerjaan modul login dan dashboard responsive.',
                'timeFormatted' => '10 Nov, 14:20',
                'score' => null,
                'feedback' => ''
            ],
            [
                'id' => 2,
                'taskId' => 1,
                'student' => 'Siti Nurhaliza',
                'nisn' => '0081293815',
                'class' => 'X RPL 1',
                'taskTitle' => 'Tugas 01: CSS Responsive',
                'fileName' => 'source_code_siti.zip',
                'fileUrl' => '/uploads/submissions/source_code_siti.zip',
                'answerText' => 'Tugas responsif selesai diuji di resolusi mobile dan desktop.',
                'timeFormatted' => '10 Nov, 15:45',
                'score' => null,
                'feedback' => ''
            ]
        ];

        if ($nisn) {
            $subs = array_values(array_filter($subs, fn($s) => $s['nisn'] === $nisn));
        }

        jsonResponse(200, $subs);
    }

    if ($method === 'POST') {
        $rawFileName = $input['fileName'] ?? 'berkas_tugas.pdf';
        $safeName = preg_replace('/[^a-zA-Z0-9._-]/', '_', $rawFileName);
        $diskFileName = time() . '_' . $safeName;
        $uploadsDir = dirname(__DIR__) . '/uploads/submissions';
        
        if (!is_dir($uploadsDir)) {
            mkdir($uploadsDir, 0777, true);
        }

        $diskPath = $uploadsDir . '/' . $diskFileName;
        if (!empty($input['fileBase64'])) {
            file_put_contents($diskPath, base64_decode($input['fileBase64']));
        } else {
            $header = "[Pngumpul Submission File]\nSiswa: " . ($input['student'] ?? '') . "\nTugas: " . ($input['taskTitle'] ?? '') . "\n\nCatatan:\n" . ($input['answerText'] ?? '-');
            file_put_contents($diskPath, $header);
        }

        $newSub = [
            'id' => (int)(microtime(true) * 1000),
            'taskId' => (int)($input['taskId'] ?? 1),
            'student' => $input['student'] ?? 'Ahmad Rizky Pratama',
            'nisn' => $input['nisn'] ?? '0081293812',
            'class' => $input['class'] ?? 'X RPL 1',
            'taskTitle' => $input['taskTitle'] ?? 'Tugas 01',
            'fileName' => $rawFileName,
            'fileUrl' => '/uploads/submissions/' . $diskFileName,
            'answerText' => $input['answerText'] ?? '',
            'timeFormatted' => 'Hari ini, ' . date('H:i'),
            'score' => null,
            'feedback' => ''
        ];

        jsonResponse(201, ['success' => true, 'submission' => $newSub]);
    }
}

// 4. Grading API
if (preg_match('#^/api/submissions/(\d+)/grade$#', $path, $matches) && $method === 'POST') {
    jsonResponse(200, [
        'success' => true,
        'id' => (int)$matches[1],
        'score' => (int)($input['score'] ?? 0),
        'feedback' => $input['feedback'] ?? ''
    ]);
}

// 5. Classes & Students
if ($path === '/api/classes' && $method === 'GET') {
    jsonResponse(200, [
        ['id' => 1, 'name' => 'X RPL 1', 'subject' => 'Pemrograman Web & Basis Data', 'homeroom' => 'Drs. Budi Santoso', 'count' => 32],
        ['id' => 2, 'name' => 'X RPL 2', 'subject' => 'Basis Data', 'homeroom' => 'Sri Wahyuni, S.Pd.', 'count' => 30],
        ['id' => 3, 'name' => 'XI RPL 1', 'subject' => 'Pemrograman Web Lanjut', 'homeroom' => 'Hendra Kurnia, M.Kom.', 'count' => 34]
    ]);
}

if ($path === '/api/students' && $method === 'GET') {
    jsonResponse(200, [
        ['id' => 1, 'name' => 'Ahmad Rizky Pratama', 'nisn' => '0081293812', 'class' => 'X RPL 1', 'scoreTugas1' => 85],
        ['id' => 2, 'name' => 'Siti Nurhaliza', 'nisn' => '0081293815', 'class' => 'X RPL 1', 'scoreTugas1' => 88],
        ['id' => 3, 'name' => 'Rizky Maulana', 'nisn' => '0081293801', 'class' => 'X RPL 1', 'scoreTugas1' => 92],
        ['id' => 4, 'name' => 'Dewi Lestari', 'nisn' => '0081293802', 'class' => 'X RPL 1', 'scoreTugas1' => 85],
        ['id' => 5, 'name' => 'Bambang Pamungkas', 'nisn' => '0081293820', 'class' => 'X RPL 2', 'scoreTugas1' => null]
    ]);
}

jsonResponse(404, ['error' => 'Endpoint tidak ditemukan: ' . $path]);
