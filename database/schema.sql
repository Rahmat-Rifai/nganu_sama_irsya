-- ============================================================
-- DATABASE SCHEMA: TUGASKU (Sistem Pengumpulan Tugas Sekolah)
-- Target: MySQL / MariaDB (Kompatibel dengan Laragon & XAMPP)
-- Sesuai Dokumen PRD Versi 1.2 Bagian 9 & 10
-- ============================================================

CREATE DATABASE IF NOT EXISTS `tugasku`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `tugasku`;

SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------
-- 1. Tabel users (Akun Pengguna: Siswa & Guru)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(150) NOT NULL,
  `username` VARCHAR(100) NOT NULL UNIQUE,
  `email` VARCHAR(150) UNIQUE DEFAULT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `role` ENUM('student', 'teacher') NOT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `photo_path` VARCHAR(255) DEFAULT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_users_role` (`role`),
  INDEX `idx_users_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 2. Tabel classes (Kelas Akademik)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `classes`;
CREATE TABLE `classes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(50) NOT NULL,
  `academic_year` VARCHAR(20) NOT NULL DEFAULT '2024/2025',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 3. Tabel subjects (Mata Pelajaran)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `subjects`;
CREATE TABLE `subjects` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `code` VARCHAR(20) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 4. Tabel students (Profil Siswa)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `students`;
CREATE TABLE `students` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL UNIQUE,
  `student_number` VARCHAR(50) NOT NULL UNIQUE COMMENT 'NIS / NISN',
  `class_id` INT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_students_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_students_class` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE RESTRICT,
  INDEX `idx_students_class` (`class_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 5. Tabel teachers (Profil Guru)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `teachers`;
CREATE TABLE `teachers` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL UNIQUE,
  `nip` VARCHAR(50) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_teachers_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 6. Tabel teacher_subject_classes (Relasi Guru, Mapel, & Kelas)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `teacher_subject_classes`;
CREATE TABLE `teacher_subject_classes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `teacher_id` INT NOT NULL,
  `subject_id` INT NOT NULL,
  `class_id` INT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_tsc_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tsc_subject` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tsc_class` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  UNIQUE KEY `uk_teacher_subject_class` (`teacher_id`, `subject_id`, `class_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 7. Tabel assignments (Tugas yang Dibuat Guru)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `assignments`;
CREATE TABLE `assignments` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `teacher_id` INT NOT NULL,
  `subject_id` INT NOT NULL,
  `class_id` INT NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `description` TEXT NOT NULL,
  `due_at` DATETIME NOT NULL,
  `status` ENUM('draft', 'published', 'archived') NOT NULL DEFAULT 'draft',
  `allow_resubmission` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_assignments_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_assignments_subject` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_assignments_class` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE RESTRICT,
  INDEX `idx_assignments_class_due` (`class_id`, `due_at`),
  INDEX `idx_assignments_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 8. Tabel assignment_attachments (Lampiran Panduan Guru)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `assignment_attachments`;
CREATE TABLE `assignment_attachments` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `assignment_id` INT NOT NULL,
  `original_name` VARCHAR(255) NOT NULL,
  `stored_name` VARCHAR(255) NOT NULL,
  `mime_type` VARCHAR(100) NOT NULL,
  `size_bytes` BIGINT NOT NULL,
  `storage_path` VARCHAR(255) NOT NULL,
  `uploaded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_attachments_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 9. Tabel submissions (Pengumpulan Tugas Siswa)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `submissions`;
CREATE TABLE `submissions` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `assignment_id` INT NOT NULL,
  `student_id` INT NOT NULL,
  `answer_text` TEXT DEFAULT NULL,
  `submitted_at` DATETIME NOT NULL,
  `status` ENUM('submitted', 'late', 'graded', 'revision_requested') NOT NULL DEFAULT 'submitted',
  `version_number` INT NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_submissions_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_submissions_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  INDEX `idx_submissions_assignment_student` (`assignment_id`, `student_id`),
  INDEX `idx_submissions_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 10. Tabel submission_files (Berkas yang Dikirim Siswa)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `submission_files`;
CREATE TABLE `submission_files` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `submission_id` INT NOT NULL,
  `original_name` VARCHAR(255) NOT NULL,
  `stored_name` VARCHAR(255) NOT NULL,
  `mime_type` VARCHAR(100) NOT NULL,
  `size_bytes` BIGINT NOT NULL,
  `storage_path` VARCHAR(255) NOT NULL,
  `uploaded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_files_submission` FOREIGN KEY (`submission_id`) REFERENCES `submissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 11. Tabel grades (Nilai & Umpan Balik Guru)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `grades`;
CREATE TABLE `grades` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `submission_id` INT NOT NULL UNIQUE,
  `teacher_id` INT NOT NULL,
  `score` DECIMAL(5,2) NOT NULL,
  `feedback` TEXT DEFAULT NULL,
  `published_at` DATETIME DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_grades_submission` FOREIGN KEY (`submission_id`) REFERENCES `submissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_grades_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 12. Tabel activity_logs (Audit Trail Aktivitas Sistem)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `activity_logs`;
CREATE TABLE `activity_logs` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT DEFAULT NULL,
  `action` VARCHAR(100) NOT NULL,
  `entity_type` VARCHAR(50) NOT NULL,
  `entity_id` INT NOT NULL,
  `metadata` JSON DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  INDEX `idx_logs_entity` (`entity_type`, `entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;


-- ============================================================
-- SEED DATA AWAL (MVP)
-- Password untuk semua akun adalah: password123
-- ============================================================

-- Data Kelas
INSERT INTO `classes` (`id`, `name`, `academic_year`) VALUES
(1, 'X RPL 1', '2024/2025'),
(2, 'X RPL 2', '2024/2025'),
(3, 'XI RPL 1', '2024/2025');

-- Data Mata Pelajaran
INSERT INTO `subjects` (`id`, `name`, `code`) VALUES
(1, 'Pemrograman Web', 'PW-01'),
(2, 'Basis Data', 'BD-01'),
(3, 'Pemrograman Berorientasi Objek', 'PBO-01');

-- Data Users: 1 Guru + 3 Siswa
-- Hash bcrypt untuk 'password123': $2y$10$DIyEozKcedMND7zLJsA/qub7AfB9hnpIBwKahe.lMCBhJkFIoXDoG
INSERT INTO `users` (`id`, `name`, `username`, `email`, `password_hash`, `role`, `phone`, `is_active`) VALUES
(1, 'Drs. Budi Santoso', 'budi_guru', 'budi@sekolah.sch.id', '$2y$10$DIyEozKcedMND7zLJsA/qub7AfB9hnpIBwKahe.lMCBhJkFIoXDoG', 'teacher', '+6281211112222', 1),
(2, 'Ahmad Rizky Pratama', '0081293812', 'ahmad@sekolah.sch.id', '$2y$10$DIyEozKcedMND7zLJsA/qub7AfB9hnpIBwKahe.lMCBhJkFIoXDoG', 'student', '+6281234567890', 1),
(3, 'Siti Nurhaliza', '0081293815', 'siti@sekolah.sch.id', '$2y$10$DIyEozKcedMND7zLJsA/qub7AfB9hnpIBwKahe.lMCBhJkFIoXDoG', 'student', '+6281234567891', 1),
(4, 'Bambang Pamungkas', '0081293820', 'bambang@sekolah.sch.id', '$2y$10$DIyEozKcedMND7zLJsA/qub7AfB9hnpIBwKahe.lMCBhJkFIoXDoG', 'student', '+6281234567892', 1);

-- Data Profil Guru
INSERT INTO `teachers` (`id`, `user_id`, `nip`) VALUES
(1, 1, '197505122002121001');

-- Data Profil Siswa
INSERT INTO `students` (`id`, `user_id`, `student_number`, `class_id`) VALUES
(1, 2, '0081293812', 1),
(2, 3, '0081293815', 1),
(3, 4, '0081293820', 2);

-- Relasi Guru dengan Kelas & Mata Pelajaran yang Diajar
INSERT INTO `teacher_subject_classes` (`id`, `teacher_id`, `subject_id`, `class_id`) VALUES
(1, 1, 1, 1), -- Guru Budi mengajar Pemrograman Web di X RPL 1
(2, 1, 2, 2), -- Guru Budi mengajar Basis Data di X RPL 2
(3, 1, 1, 3); -- Guru Budi mengajar Pemrograman Web di XI RPL 1

-- Contoh Tugas yang Diterbitkan Guru
INSERT INTO `assignments` (`id`, `teacher_id`, `subject_id`, `class_id`, `title`, `description`, `due_at`, `status`, `allow_resubmission`) VALUES
(1, 1, 1, 1, 'Tugas 01: Membuat Halaman Login & Dashboard Responsive', 'Buatlah rancangan HTML & CSS modul autentikasi guru dan siswa serta dashboard pengelolaan tugas terintegrasi.', '2026-11-15 23:59:00', 'published', 1),
(2, 1, 2, 2, 'Praktikum 03: Desain Skema ERD MySQL & Normalisasi', 'Rancang ERD sistem database sekolah minimal 8 tabel, terapkan index dan foreign keys secara tepat.', '2026-11-18 17:00:00', 'published', 1);

-- Contoh Kiriman Siswa Ahmad Rizky untuk Tugas 1
INSERT INTO `submissions` (`id`, `assignment_id`, `student_id`, `answer_text`, `submitted_at`, `status`, `version_number`) VALUES
(1, 1, 1, 'Selamat siang Pak, berikut saya kumpulkan link repo dan lampiran screenshot modul login serta dashboard responsive menggunakan Tailwind CSS.', '2026-11-14 14:20:00', 'graded', 1);

-- Contoh Berkas Kiriman Siswa Ahmad
INSERT INTO `submission_files` (`id`, `submission_id`, `original_name`, `stored_name`, `mime_type`, `size_bytes`, `storage_path`) VALUES
(1, 1, 'Laporan_Tugas01_Ahmad.pdf', 'sub_001_141126_laporan.pdf', 'application/pdf', 2516582, 'uploads/submissions/sub_001_141126_laporan.pdf');

-- Nilai & Komentar Guru untuk Siswa Ahmad
INSERT INTO `grades` (`id`, `submission_id`, `teacher_id`, `score`, `feedback`, `published_at`) VALUES
(1, 1, 1, 95.00, 'Kerja bagus! Desain clean dan struktur kode sudah rapi.', '2026-11-14 16:30:00');
