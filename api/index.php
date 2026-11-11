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
                'subjects' => ['Pemrograman Web', 'Dasar Kejuruan'],
                'classes' => ['X RPL', 'X DPIB', 'X Animasi', 'X TKR', 'X TSM', 'X PBS'],
            ]
        ]);
    } else {
        jsonResponse(200, [
            'success' => true,
            'user' => [
                'name' => 'Ahmad Rizky Pratama',
                'nisn' => $identifier ?: '0081293812',
                'class' => 'X RPL',
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
                'targetClass' => 'X RPL',
                'due' => '2026-11-15T23:59',
                'dueFormatted' => '15 Nov, 23:59 WIB',
                'status' => 'published',
                'submittedCount' => 2,
                'totalStudents' => 32,
                'desc' => 'Struktur antarmuka responsif tanpa AI boilerplate beracuan desain TugasKu.'
            ],
            [
                'id' => 2,
                'title' => 'Desain Denah Rumah 2 Lantai AutoCAD',
                'subject' => 'Desain Pemodelan Bangunan',
                'targetClass' => 'X DPIB',
                'due' => '2026-11-18T17:00',
                'dueFormatted' => '18 Nov, 17:00 WIB',
                'status' => 'published',
                'submittedCount' => 1,
                'totalStudents' => 30,
                'desc' => 'Rancang denah dan potongan rumah 2 lantai proyeksi ortogonal skala 1:100.'
            ],
            [
                'id' => 3,
                'title' => 'Pembuatan Karakter 2D & Walk Cycle',
                'subject' => 'Animasi 2D & 3D',
                'targetClass' => 'X Animasi',
                'due' => '2026-11-20T23:59',
                'dueFormatted' => '20 Nov, 23:59 WIB',
                'status' => 'published',
                'submittedCount' => 0,
                'totalStudents' => 28,
                'desc' => 'Buat storyboard 12 panel beserta animasi gerak jalan karakter utama.'
            ],
            [
                'id' => 4,
                'title' => 'Pemeriksaan & Penyetelan Celah Katup',
                'subject' => 'Teknik Kendaraan Ringan',
                'targetClass' => 'X TKR',
                'due' => '2026-11-22T15:00',
                'dueFormatted' => '22 Nov, 15:00 WIB',
                'status' => 'published',
                'submittedCount' => 0,
                'totalStudents' => 34,
                'desc' => 'Laporan praktikum tune-up mesin bensin 4 silinder dan pengukuran katup.'
            ],
            [
                'id' => 5,
                'title' => 'Perawatan Sistem Injeksi Sepeda Motor',
                'subject' => 'Teknik Sepeda Motor',
                'targetClass' => 'X TSM',
                'due' => '2026-11-24T16:00',
                'dueFormatted' => '24 Nov, 16:00 WIB',
                'status' => 'published',
                'submittedCount' => 0,
                'totalStudents' => 32,
                'desc' => 'Pemeriksaan kode MIL sensor injeksi PGM-FI dan sistem pengisian motor.'
            ],
            [
                'id' => 6,
                'title' => 'Pencatatan Transaksi Tabungan Mudharabah',
                'subject' => 'Perbankan Syariah',
                'targetClass' => 'X PBS',
                'due' => '2026-11-26T17:00',
                'dueFormatted' => '26 Nov, 17:00 WIB',
                'status' => 'published',
                'submittedCount' => 0,
                'totalStudents' => 30,
                'desc' => 'Simulasikan jurnal tabungan mudharabah dan kalkulasi bagi hasil nasabah.'
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
            'targetClass' => $input['targetClass'] ?? 'X RPL',
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
                'class' => 'X RPL',
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
                'class' => 'X RPL',
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
            'class' => $input['class'] ?? 'X RPL',
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
        ['id' => 1, 'name' => 'X RPL', 'subject' => 'Rekayasa Perangkat Lunak', 'homeroom' => 'Drs. Budi Santoso', 'count' => 32],
        ['id' => 2, 'name' => 'X DPIB', 'subject' => 'Desain Pemodelan & Info Bangunan', 'homeroom' => 'Ir. Ahmad Hidayat', 'count' => 30],
        ['id' => 3, 'name' => 'X Animasi', 'subject' => 'Animasi 2D & 3D Komputer', 'homeroom' => 'Maya Indah, S.Sn.', 'count' => 28],
        ['id' => 4, 'name' => 'X TKR', 'subject' => 'Teknik Kendaraan Ringan Otomotif', 'homeroom' => 'Bambang Sutrisno, S.T.', 'count' => 34],
        ['id' => 5, 'name' => 'X TSM', 'subject' => 'Teknik Sepeda Motor', 'homeroom' => 'Rudi Hartono, S.Pd.', 'count' => 32],
        ['id' => 6, 'name' => 'X PBS', 'subject' => 'Perbankan Syariah & Keuangan Mikro', 'homeroom' => 'Siti Nurjanah, S.E.', 'count' => 30],
        ['id' => 7, 'name' => 'XI RPL', 'subject' => 'Pemrograman Web & PBO Lanjut', 'homeroom' => 'Hendra Kurnia, M.Kom.', 'count' => 34],
        ['id' => 8, 'name' => 'XI DPIB', 'subject' => 'Aplikasi Revit & Konstruksi Gedung', 'homeroom' => 'Dewi Anggraini, S.T.', 'count' => 32],
        ['id' => 9, 'name' => 'XI Animasi', 'subject' => 'Animasi 3D Blender & Visual FX', 'homeroom' => 'Faris Pratama, M.Sn.', 'count' => 30],
        ['id' => 10, 'name' => 'XI TKR', 'subject' => 'Sistem Kelistrikan & Chassis Otomotif', 'homeroom' => 'Agus Santoso, S.T.', 'count' => 36],
        ['id' => 11, 'name' => 'XI TSM', 'subject' => 'Sistem Injeksi & Kelistrikan Motor Lanjut', 'homeroom' => 'Eko Prasetyo, S.Pd.', 'count' => 34],
        ['id' => 12, 'name' => 'XI PBS', 'subject' => 'Layanan Lembaga Keuangan Mikro Syariah', 'homeroom' => 'Hj. Ratna Sari, M.E.', 'count' => 32]
    ]);
}

if ($path === '/api/students') {
    if ($method === 'GET') {
        jsonResponse(200, [
            ['id' => 1, 'name' => 'Ahmad Rizky Pratama', 'nisn' => '0081293812', 'username' => '0081293812', 'email' => 'ahmad.rizky@siswa.sch.id', 'password' => 'password123', 'class' => 'X RPL', 'phone' => '081234567891', 'status' => 'active', 'registeredAt' => '2024-07-15', 'scoreTugas1' => 85, 'scoreTugas2' => null],
            ['id' => 2, 'name' => 'Siti Nurhaliza', 'nisn' => '0081293815', 'username' => '0081293815', 'email' => 'siti.nurhaliza@siswa.sch.id', 'password' => 'password123', 'class' => 'X RPL', 'phone' => '081234567892', 'status' => 'active', 'registeredAt' => '2024-07-15', 'scoreTugas1' => 88, 'scoreTugas2' => null],
            ['id' => 3, 'name' => 'Fajar Nugraha', 'nisn' => '0081293821', 'username' => '0081293821', 'email' => 'fajar.nugraha@siswa.sch.id', 'password' => 'password123', 'class' => 'X DPIB', 'phone' => '081234567893', 'status' => 'active', 'registeredAt' => '2024-07-15', 'scoreTugas1' => 90, 'scoreTugas2' => null],
            ['id' => 4, 'name' => 'Cindy Claudia', 'nisn' => '0081293833', 'username' => '0081293833', 'email' => 'cindy.claudia@siswa.sch.id', 'password' => 'password123', 'class' => 'X Animasi', 'phone' => '081234567894', 'status' => 'active', 'registeredAt' => '2024-07-16', 'scoreTugas1' => null, 'scoreTugas2' => null],
            ['id' => 5, 'name' => 'Wahyu Setiawan', 'nisn' => '0081293844', 'username' => '0081293844', 'email' => 'wahyu.setiawan@siswa.sch.id', 'password' => 'password123', 'class' => 'X TKR', 'phone' => '081234567895', 'status' => 'active', 'registeredAt' => '2024-07-16', 'scoreTugas1' => null, 'scoreTugas2' => null],
            ['id' => 6, 'name' => 'Bagas Saputra', 'nisn' => '0081293855', 'username' => '0081293855', 'email' => 'bagas.saputra@siswa.sch.id', 'password' => 'password123', 'class' => 'X TSM', 'phone' => '081234567896', 'status' => 'active', 'registeredAt' => '2024-07-17', 'scoreTugas1' => null, 'scoreTugas2' => null],
            ['id' => 7, 'name' => 'Aisyah Rahmawati', 'nisn' => '0081293866', 'username' => '0081293866', 'email' => 'aisyah.rahma@siswa.sch.id', 'password' => 'password123', 'class' => 'X PBS', 'phone' => '081234567897', 'status' => 'active', 'registeredAt' => '2024-07-18', 'scoreTugas1' => null, 'scoreTugas2' => null],
            ['id' => 8, 'name' => 'M. Rayhan Alfarizi', 'nisn' => '0071293901', 'username' => '0071293901', 'email' => 'rayhan.al@siswa.sch.id', 'password' => 'password123', 'class' => 'XI RPL', 'phone' => '081234567898', 'status' => 'active', 'registeredAt' => '2023-07-15', 'scoreTugas1' => 95, 'scoreTugas2' => null],
            ['id' => 9, 'name' => 'Dinda Putri Maharani', 'nisn' => '0071293902', 'username' => '0071293902', 'email' => 'dinda.putri@siswa.sch.id', 'password' => 'password123', 'class' => 'XI DPIB', 'phone' => '081234567899', 'status' => 'active', 'registeredAt' => '2023-07-15', 'scoreTugas1' => null, 'scoreTugas2' => null],
            ['id' => 10, 'name' => 'Kevin Julio Pratama', 'nisn' => '0071293903', 'username' => '0071293903', 'email' => 'kevin.julio@siswa.sch.id', 'password' => 'password123', 'class' => 'XI Animasi', 'phone' => '081234567900', 'status' => 'active', 'registeredAt' => '2023-07-16', 'scoreTugas1' => null, 'scoreTugas2' => null],
            ['id' => 11, 'name' => 'Dimas Anggara', 'nisn' => '0071293904', 'username' => '0071293904', 'email' => 'dimas.ang@siswa.sch.id', 'password' => 'password123', 'class' => 'XI TKR', 'phone' => '081234567901', 'status' => 'active', 'registeredAt' => '2023-07-16', 'scoreTugas1' => null, 'scoreTugas2' => null],
            ['id' => 12, 'name' => 'Gilang Ramadhan', 'nisn' => '0071293905', 'username' => '0071293905', 'email' => 'gilang.ram@siswa.sch.id', 'password' => 'password123', 'class' => 'XI TSM', 'phone' => '081234567902', 'status' => 'active', 'registeredAt' => '2023-07-17', 'scoreTugas1' => null, 'scoreTugas2' => null],
            ['id' => 13, 'name' => 'Nabila Zahra', 'nisn' => '0071293906', 'username' => '0071293906', 'email' => 'nabila.zahra@siswa.sch.id', 'password' => 'password123', 'class' => 'XI PBS', 'phone' => '081234567903', 'status' => 'active', 'registeredAt' => '2023-07-18', 'scoreTugas1' => null, 'scoreTugas2' => null]
        ]);
    }
    if ($method === 'POST') {
        $newStudent = [
            'id' => time(),
            'name' => trim($input['name'] ?? 'Siswa Baru'),
            'nisn' => trim($input['nisn'] ?? (string)time()),
            'username' => trim($input['username'] ?? $input['nisn'] ?? (string)time()),
            'email' => trim($input['email'] ?? ($input['nisn'] ?? 'siswa') . '@siswa.sch.id'),
            'password' => trim($input['password'] ?? 'siswa123'),
            'class' => trim($input['class'] ?? 'X RPL'),
            'phone' => trim($input['phone'] ?? ''),
            'status' => trim($input['status'] ?? 'active'),
            'registeredAt' => date('Y-m-d'),
            'scoreTugas1' => null,
            'scoreTugas2' => null
        ];
        jsonResponse(201, ['success' => true, 'student' => $newStudent]);
    }
    if ($method === 'DELETE') {
        jsonResponse(200, ['success' => true]);
    }
}

jsonResponse(404, ['error' => 'Endpoint tidak ditemukan: ' . $path]);
