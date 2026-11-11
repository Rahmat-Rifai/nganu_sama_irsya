import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
void main() {
  runApp(const PngumpulApp());
}

/// ============================================================================
/// SISTEM DESAIN & WARNA PNGUMPUL (AFRICAN VIOLET PALETTE)
/// ============================================================================
class AppColors {
  static const Color canvas = Color(0xFF0C0A10);
  static const Color surface = Color(0xFF14101B);
  static const Color surfaceElevated = Color(0xFF1B1625);
  static const Color surfaceHover = Color(0xFF221B2F);
  static const Color border = Color(0xFF261F33);
  static const Color borderHover = Color(0xFF3D3251);
  static const Color text = Color(0xFFF6F3F9);
  static const Color muted = Color(0xFF9F95AD);
  static const Color subtle = Color(0xFF6B6378);

  // Palet Pilihan Pengguna
  static const Color violet = Color(0xFFB284BE); // African Violet (Primary)
  static const Color violetHover = Color(0xFFA16FAB);
  static const Color pastel = Color(0xFFBBA3D9); // Light Pastel Purple
  static const Color pale = Color(0xFFEDDAF2); // Pale Purple

  static const Color success = Color(0xFF81C995);
  static const Color warning = Color(0xFFF4C66A);
  static const Color danger = Color(0xFFFF8A80);
}

/// Model Tugas
class TaskItem {
  final int id;
  final String title;
  final String subject;
  final String targetClass;
  final String dueFormatted;
  final String desc;
  int submittedCount;
  final int totalStudents;

  TaskItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.targetClass,
    required this.dueFormatted,
    required this.desc,
    this.submittedCount = 0,
    this.totalStudents = 32,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] ?? 1,
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      targetClass: json['targetClass'] ?? 'XI RPL',
      dueFormatted: json['dueFormatted'] ?? 'Sesuai jadwal',
      desc: json['desc'] ?? '',
      submittedCount: json['submittedCount'] ?? 0,
      totalStudents: json['totalStudents'] ?? 32,
    );
  }
}

/// Model Pengumpulan Tugas
class SubmissionItem {
  final int id;
  final int taskId;
  final String student;
  final String nisn;
  final String studentClass;
  final String taskTitle;
  final String fileName;
  final String answerText;
  final String timeFormatted;
  int? score;
  String feedback;

  SubmissionItem({
    required this.id,
    required this.taskId,
    required this.student,
    required this.nisn,
    required this.studentClass,
    required this.taskTitle,
    required this.fileName,
    required this.answerText,
    required this.timeFormatted,
    this.score,
    this.feedback = '',
  });

  factory SubmissionItem.fromJson(Map<String, dynamic> json) {
    return SubmissionItem(
      id: json['id'] ?? 1,
      taskId: json['taskId'] ?? 1,
      student: json['student'] ?? '',
      nisn: json['nisn'] ?? '',
      studentClass: json['class'] ?? 'XI RPL',
      taskTitle: json['taskTitle'] ?? '',
      fileName: json['fileName'] ?? '',
      answerText: json['answerText'] ?? '',
      timeFormatted: json['timeFormatted'] ?? '',
      score: json['score'],
      feedback: json['feedback'] ?? '',
    );
  }
}

/// ============================================================================
/// SERVICE JARINGAN: KONEKSI APLIKASI KE SERVER WEB (HTTP API)
/// ============================================================================
class ApiService {
  // Web (hosting): pakai origin halaman yang sedang dibuka, jadi API selalu
  // satu origin dengan aplikasi. Android/HP fisik: tetap localhost:3000
  // (via USB adb reverse) seperti semula.
  static String get baseUrl =>
      kIsWeb ? Uri.base.origin : 'http://localhost:3000';

  /// Mengambil daftar tugas dari Server Web
  static Future<List<TaskItem>> fetchTasks(String targetClass) async {
    try {
      final uri = Uri.parse('$baseUrl/api/tasks?class=$targetClass');
      final response =
          await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => TaskItem.fromJson(e)).toList();
      }
    } catch (_) {
      // Fallback data lokal jika server belum terjangkau
    }

    return [
      TaskItem(
        id: 1,
        title: "Layout Responsive CSS Grid & Flexbox",
        subject: "Pemrograman Web",
        targetClass: "XI RPL",
        dueFormatted: "15 Nov, 23:59 WIB",
        desc: "Struktur antarmuka responsif tanpa AI boilerplate beracuan desain Pngumpul.",
        submittedCount: 2,
        totalStudents: 32,
      ),
      TaskItem(
        id: 2,
        title: "Desain Skema ERD MySQL dan Normalisasi",
        subject: "Basis Data",
        targetClass: "XI RPL",
        dueFormatted: "18 Nov, 17:00 WIB",
        desc: "Rancang ERD sistem database relasional minimal 8 tabel relasi lengkap.",
        submittedCount: 0,
        totalStudents: 30,
      )
    ];
  }

  /// Mengirimkan jawaban tugas siswa ke Server Web
  static Future<bool> submitAssignment({
    required int taskId,
    required String student,
    required String nisn,
    required String taskClass,
    required String taskTitle,
    required String fileName,
    required String answerText,
    Uint8List? fileBytes,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/submissions');
      final Map<String, dynamic> payload = {
        'taskId': taskId,
        'student': student,
        'nisn': nisn,
        'class': taskClass,
        'taskTitle': taskTitle,
        'fileName': fileName,
        'answerText': answerText,
      };
      if (fileBytes != null && fileBytes.isNotEmpty) {
        payload['fileBase64'] = base64Encode(fileBytes);
      }
      final response = await http
          .post(uri,
              headers: {'content-type': 'application/json; charset=utf-8'},
              body: jsonEncode(payload))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return true; // Fallback sukses lokal
    }
  }

  /// Mengambil status pengumpulan siswa dari Server Web
  static Future<List<SubmissionItem>> fetchStudentSubmissions(String nisn) async {
    try {
      final uri = Uri.parse('$baseUrl/api/submissions?nisn=$nisn');
      final response =
          await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        return list.map((e) => SubmissionItem.fromJson(e)).toList();
      }
    } catch (_) {}

    return [
      SubmissionItem(
        id: 1,
        taskId: 1,
        student: "Ahmad Rizky Pratama",
        nisn: nisn,
        studentClass: "XI RPL",
        taskTitle: "Tugas 01: CSS Responsive",
        fileName: "Laporan_Tugas01.pdf",
        answerText: "Laporan pengerjaan modul login dan dashboard responsif.",
        timeFormatted: "10 Nov, 14:20",
        score: null,
      )
    ];
  }
}

/// ============================================================================
/// ROOT WIDGET
/// ============================================================================
class PngumpulApp extends StatelessWidget {
  const PngumpulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pngumpul',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.canvas,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.violet,
          surface: AppColors.surface,
        ),
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const LoginScreen(),
    );
  }
}

/// ============================================================================
/// 1. SCREEN: MASUK AKUN (SISWA & GURU)
/// ============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController(text: '0081293812');
  final _passwordController = TextEditingController(text: 'password123');
  bool _isStudent = true;
  bool _isLoading = false;

  void _fillStudent() {
    setState(() {
      _isStudent = true;
      _idController.text = '0081293812';
      _passwordController.text = 'password123';
    });
  }

  void _fillTeacher() {
    setState(() {
      _isStudent = false;
      _idController.text = 'budi@sekolah.sch.id';
      _passwordController.text = 'password123';
    });
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (_isStudent) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const StudentDashboardScreen(
            studentName: 'Ahmad Rizky Pratama',
            nisn: '0081293812',
            className: 'XI RPL',
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const TeacherMobileScreen(
            teacherName: 'Drs. Budi Santoso',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Mark & Brand
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomPaint(
                          size: const Size(28, 28),
                          painter: PngumpulLogoPainter(),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Pngumpul',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Login Container Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Masuk Akun',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Akses pengumpulan tugas dan evaluasi.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Role Selector Toggle
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppColors.canvas,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isStudent = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _isStudent ? AppColors.surfaceElevated : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: _isStudent ? Border.all(color: AppColors.border) : null,
                                    ),
                                    child: Text(
                                      'Siswa',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _isStudent ? AppColors.pale : AppColors.muted,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isStudent = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: !_isStudent ? AppColors.surfaceElevated : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: !_isStudent ? Border.all(color: AppColors.border) : null,
                                    ),
                                    child: Text(
                                      'Guru',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: !_isStudent ? AppColors.pale : AppColors.muted,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Input ID / Email
                        Text(
                          _isStudent ? 'NISN SISWA' : 'EMAIL GURU / NIP',
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'JetBrains Mono',
                            color: AppColors.muted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _idController,
                          style: const TextStyle(fontSize: 13, color: AppColors.text),
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: AppColors.canvas,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.violet),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Password
                        const Text(
                          'KATA SANDI',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'JetBrains Mono',
                            color: AppColors.muted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(fontSize: 13, color: AppColors.text),
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: AppColors.canvas,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.violet),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.violet,
                              foregroundColor: AppColors.canvas,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.canvas),
                                  )
                                : const Text(
                                    'Masuk ke Sistem',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Quick demo buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _fillStudent,
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: const Text('Akun Siswa', style: TextStyle(fontSize: 11, color: AppColors.pastel)),
                            ),
                            TextButton(
                              onPressed: _fillTeacher,
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: const Text('Akun Guru', style: TextStyle(fontSize: 11, color: AppColors.pastel)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Terhubung ke Server: ${ApiService.baseUrl}',
                      style: const TextStyle(fontSize: 10, fontFamily: 'JetBrains Mono', color: AppColors.subtle),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// 2. SCREEN: DASHBOARD SISWA (TERHUBUNG KE SERVER WEB)
/// ============================================================================
class StudentDashboardScreen extends StatefulWidget {
  final String studentName;
  final String nisn;
  final String className;

  const StudentDashboardScreen({
    super.key,
    required this.studentName,
    required this.nisn,
    required this.className,
  });

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  List<TaskItem> _tasks = [];
  List<SubmissionItem> _mySubmissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final tasks = await ApiService.fetchTasks(widget.className);
    final subs = await ApiService.fetchStudentSubmissions(widget.nisn);
    setState(() {
      _tasks = tasks;
      _mySubmissions = subs;
      _isLoading = false;
    });
  }

  void _openTaskDetail(TaskItem task) async {
    final existingSub = _mySubmissions.firstWhere(
      (s) => s.taskId == task.id,
      orElse: () => SubmissionItem(
        id: 0,
        taskId: 0,
        student: '',
        nisn: '',
        studentClass: '',
        taskTitle: '',
        fileName: '',
        answerText: '',
        timeFormatted: '',
      ),
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(
          task: task,
          studentName: widget.studentName,
          nisn: widget.nisn,
          className: widget.className,
          existingSubmission: existingSub.id != 0 ? existingSub : null,
        ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            CustomPaint(
              size: const Size(20, 20),
              painter: PngumpulLogoPainter(),
            ),
            const SizedBox(width: 8),
            const Text(
              'Pngumpul',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.text),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 18, color: AppColors.pastel),
            onPressed: _loadData,
            tooltip: 'Segarkan Tugas dari Server',
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 18, color: AppColors.muted),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.violet,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Identity Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.studentName.substring(0, 2).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.pastel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.studentName,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'NISN: ${widget.nisn} • ${widget.className}',
                            style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono', color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TUGAS KELAS ANDA',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'JetBrains Mono',
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${_tasks.length} Tugas',
                    style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono', color: AppColors.subtle),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Task List
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.violet),
                  ),
                )
              else if (_tasks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('Tidak ada tugas untuk kelas Anda.', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _tasks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    final isSubmitted = _mySubmissions.any((s) => s.taskId == task.id);
                    final sub = isSubmitted ? _mySubmissions.firstWhere((s) => s.taskId == task.id) : null;

                    return GestureDetector(
                      onTap: () => _openTaskDetail(task),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  task.subject,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'JetBrains Mono',
                                    color: AppColors.pastel,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: sub?.score != null
                                        ? AppColors.success.withOpacity(0.15)
                                        : (isSubmitted ? AppColors.pastel.withOpacity(0.15) : AppColors.warning.withOpacity(0.15)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    sub?.score != null
                                        ? 'Nilai: ${sub!.score}'
                                        : (isSubmitted ? 'Terkumpul' : 'Belum Kumpul'),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontFamily: 'JetBrains Mono',
                                      fontWeight: FontWeight.w700,
                                      color: sub?.score != null
                                          ? AppColors.success
                                          : (isSubmitted ? AppColors.pale : AppColors.warning),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              task.title,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tenggat: ${task.dueFormatted}',
                                  style: const TextStyle(fontSize: 10, fontFamily: 'JetBrains Mono', color: AppColors.muted),
                                ),
                                const Icon(Icons.chevron_right, size: 16, color: AppColors.pastel),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// 3. SCREEN: DETAIL & PENGUMPULAN TUGAS (UPLOAD KE SERVER WEB)
/// ============================================================================
class TaskDetailScreen extends StatefulWidget {
  final TaskItem task;
  final String studentName;
  final String nisn;
  final String className;
  final SubmissionItem? existingSubmission;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.studentName,
    required this.nisn,
    required this.className,
    this.existingSubmission,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _answerController = TextEditingController();
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;
  String _fileCategory = 'BERKAS';
  String _fileSize = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingSubmission != null) {
      _answerController.text = widget.existingSubmission!.answerText;
      _selectedFileName = widget.existingSubmission!.fileName;
      _detectFileType(_selectedFileName!);
      _fileSize = 'Berkas Terkumpul';
    }
  }

  void _detectFileType(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.webp') || lower.endsWith('.svg')) {
      _fileCategory = 'GAMBAR';
    } else if (lower.endsWith('.zip') || lower.endsWith('.rar') || lower.endsWith('.7z') || lower.endsWith('.tar')) {
      _fileCategory = 'ARSIP';
    } else if (lower.endsWith('.pdf')) {
      _fileCategory = 'PDF';
    } else if (lower.endsWith('.html') || lower.endsWith('.css') || lower.endsWith('.js') || lower.endsWith('.dart') || lower.endsWith('.py') || lower.endsWith('.sql')) {
      _fileCategory = 'KODE';
    } else if (lower.endsWith('.docx') || lower.endsWith('.doc') || lower.endsWith('.txt')) {
      _fileCategory = 'DOKUMEN';
    } else {
      _fileCategory = 'BERKAS';
    }
  }

  IconData _getFileIcon(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.webp') || lower.endsWith('.svg')) {
      return Icons.image_outlined;
    }
    if (lower.endsWith('.zip') || lower.endsWith('.rar') || lower.endsWith('.7z') || lower.endsWith('.tar')) {
      return Icons.archive_outlined;
    }
    if (lower.endsWith('.pdf')) {
      return Icons.picture_as_pdf_outlined;
    }
    if (lower.endsWith('.html') || lower.endsWith('.css') || lower.endsWith('.js') || lower.endsWith('.dart') || lower.endsWith('.py') || lower.endsWith('.sql')) {
      return Icons.code_outlined;
    }
    return Icons.description_outlined;
  }

  /// Membuka langsung File Explorer HP Android
  Future<void> _pickFileFromExplorer() async {
    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(
        type: FileType.any,
      );

      if (files.isNotEmpty) {
        final file = files.first;
        Uint8List? bytes;
        try {
          bytes = await file.readAsBytes();
        } catch (_) {}

        final sizeInBytes = file.lengthSync() ?? (bytes?.length ?? 0);
        setState(() {
          _selectedFileName = file.name;
          _selectedFileBytes = bytes;
          if (sizeInBytes >= 1024 * 1024) {
            _fileSize = '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
          } else {
            _fileSize = '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
          }
          _detectFileType(file.name);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.surfaceElevated,
              content: Text('Berkas dipilih: ${file.name}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Batal atau gagal memilih berkas: $e')),
        );
      }
    }
  }
  /// Mengambil foto langsung dari Kamera HP
  Future<void> _capturePhotoFromCamera() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        final now = DateTime.now();
        final name = 'Foto_Tugas_${now.hour}${now.minute}${now.second}.jpg';
        setState(() {
          _selectedFileName = name;
          _selectedFileBytes = bytes;
          if (bytes.length >= 1024 * 1024) {
            _fileSize = '${(bytes.length / (1024 * 1024)).toStringAsFixed(2)} MB';
          } else {
            _fileSize = '${(bytes.length / 1024).toStringAsFixed(1)} KB';
          }
          _detectFileType(name);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.surfaceElevated,
              content: Text('Foto kamera terlampir: $name'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Batal atau gagal membuka kamera: $e')),
        );
      }
    }
  }
  void _handleSubmit() async {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tuliskan catatan jawaban tugas.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ApiService.submitAssignment(
      taskId: widget.task.id,
      student: widget.studentName,
      nisn: widget.nisn,
      taskClass: widget.className,
      taskTitle: widget.task.title,
      fileName: _selectedFileName ?? 'tugas_${widget.studentName.split(' ')[0]}.pdf',
      answerText: _answerController.text.trim(),
      fileBytes: _selectedFileBytes,
    );
    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.surfaceElevated,
          content: Text('Tugas berhasil dikirim ke Server Web Pngumpul!'),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sub = widget.existingSubmission;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(widget.task.subject, style: const TextStyle(fontSize: 14, color: AppColors.text)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Title & Due
            Text(
              widget.task.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text),
            ),
            const SizedBox(height: 6),
            Text(
              'Tenggat: ${widget.task.dueFormatted}',
              style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono', color: AppColors.warning),
            ),
            const SizedBox(height: 16),

            // Instructions Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PETUNJUK PENGERJAAN',
                    style: TextStyle(fontSize: 10, fontFamily: 'JetBrains Mono', color: AppColors.muted),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.task.desc,
                    style: const TextStyle(fontSize: 12, color: AppColors.text, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Graded Result Banner (If teacher graded on web!)
            if (sub?.score != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('NILAI EVALUASI GURU', style: TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono', color: AppColors.success)),
                        Text('${sub!.score} / 100', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.success)),
                      ],
                    ),
                    if (sub.feedback.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Catatan: "${sub.feedback}"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.text)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Submission Form
            const Text(
              'JAWABAN & BERKAS TUGAS',
              style: TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono', color: AppColors.muted),
            ),
            const SizedBox(height: 8),

            // Text answer
            TextField(
              controller: _answerController,
              maxLines: 4,
              style: const TextStyle(fontSize: 12, color: AppColors.text),
              decoration: InputDecoration(
                hintText: 'Tuliskan ringkasan jawaban Anda...',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.subtle),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.violet),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Header Label with quick action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'BERKAS TUGAS',
                  style: TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono', color: AppColors.muted),
                ),
                if (_selectedFileName != null)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _capturePhotoFromCamera,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.camera_alt_outlined, size: 16, color: AppColors.violet),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _pickFileFromExplorer,
                        child: const Text('Ganti (+)', style: TextStyle(fontSize: 11, color: AppColors.violet, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // If no file selected yet -> Show dual prominent buttons: Camera & File Explorer
            if (_selectedFileName == null) ...[
              Row(
                children: [
                  // 1. Camera Photo Button
                  Expanded(
                    child: GestureDetector(
                      onTap: _capturePhotoFromCamera,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.violet.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, size: 20, color: AppColors.violet),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Foto Tugas',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Jepret Kamera HP',
                              style: TextStyle(fontSize: 10, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 2. Native File Explorer Button
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickFileFromExplorer,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.pastel.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, size: 22, color: AppColors.pastel),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Pilih Berkas (+)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'PDF, ZIP, File HP',
                              style: TextStyle(fontSize: 10, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Attached File Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getFileIcon(_selectedFileName!), size: 20, color: AppColors.pastel),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFileName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'JetBrains Mono',
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  _fileCategory,
                                  style: const TextStyle(fontSize: 9, fontFamily: 'JetBrains Mono', color: AppColors.pastel, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _fileSize.isNotEmpty ? _fileSize : 'Berkas Siap',
                                style: const TextStyle(fontSize: 10, fontFamily: 'JetBrains Mono', color: AppColors.subtle),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: AppColors.subtle),
                      onPressed: () => setState(() {
                        _selectedFileName = null;
                        _selectedFileBytes = null;
                        _fileSize = '';
                      }),
                      tooltip: 'Hapus Berkas',
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violet,
                  foregroundColor: AppColors.canvas,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.canvas))
                    : Text(
                        sub != null ? 'Perbarui Kiriman Tugas' : 'Kirim Tugas ke Server Web',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// 4. SCREEN: DASHBOARD MOBILE KHUSUS GURU
/// ============================================================================
class TeacherMobileScreen extends StatelessWidget {
  final String teacherName;

  const TeacherMobileScreen({super.key, required this.teacherName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Pngumpul Guru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 18),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                size: const Size(48, 48),
                painter: PngumpulLogoPainter(),
              ),
              const SizedBox(height: 16),
              Text(
                'Selamat Datang, $teacherName',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text),
              ),
              const SizedBox(height: 8),
              const Text(
                'Panel Web Guru saat ini aktif di port 3000.\nGunakan browser untuk akses penuh.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// 5. CUSTOM PAINTER: FLATICON DESIGN ELEMENT STAR LOGO MARK
/// ============================================================================
class PngumpulLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Base Squircle Container
    final bgPaint = Paint()..color = const Color(0xFF171220);
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.width * 0.25),
    );
    canvas.drawRRect(rrect, bgPaint);

    // 2. Alignment hairline ring
    final ringPaint = Paint()
      ..color = const Color(0xFF362D46)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, size.width * 0.33, ringPaint);

    // 3. Curvilinear 4-Point Star in African Violet
    final starPaint = Paint()..color = AppColors.violet;
    final path = Path();
    final double cx = center.dx;
    final double cy = center.dy;
    final double top = size.height * 0.17;
    final double bottom = size.height * 0.83;
    final double left = size.width * 0.17;
    final double right = size.width * 0.83;

    path.moveTo(cx, top);
    path.quadraticBezierTo(cx, cy, left, cy);
    path.quadraticBezierTo(cx, cy, cx, bottom);
    path.quadraticBezierTo(cx, cy, right, cy);
    path.quadraticBezierTo(cx, cy, cx, top);
    path.close();
    canvas.drawPath(path, starPaint);

    // 4. Inner Core Highlight in Pale Purple
    final corePaint = Paint()..color = AppColors.pale;
    canvas.drawCircle(center, size.width * 0.08, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
