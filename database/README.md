# Panduan Database TugasKu (MySQL / Laragon)

Database ini dirancang khusus untuk memenuhi arsitektur **TugasKu** (PRD Versi 1.2), menghubungkan platform **Web Panel Guru** dan **Aplikasi Android Siswa** ke dalam satu database terpusat.

---

## 1. Konfigurasi Koneksi Bawaan (Laragon & XAMPP)

File konfigurasi koneksi PDO PHP berada di:  
👉 **`api/config/database.php`**

| Parameter | Nilai Default Laragon | Keterangan |
| :--- | :--- | :--- |
| **Host** | `127.0.0.1` atau `localhost` | Server MySQL |
| **Port** | `3306` | Port default MySQL |
| **Database** | `tugasku` | Nama database |
| **Username** | `root` | User default |
| **Password** | *(kosong)* | Password default Laragon |
| **Charset** | `utf8mb4` | Support teks & emoji |

---

## 2. Cara Import Skema ke Laragon

Jika membuka Laragon:
1. Klik tombol **Start All** pada Laragon (Apache & MySQL).
2. Klik tombol **Database** di Laragon (membuka HeidiSQL) atau buka browser di `http://localhost/phpmyadmin`.
3. Buka file **`database/schema.sql`**, lalu jalankan (Execute / Run SQL).
4. Database `tugasku` beserta **12 tabel relasional** dan data uji coba (seed data) akan langsung siap digunakan.

---

## 3. Akun Pengujian (Seed Data MVP)

Semua akun pengujian memiliki password: **`password123`** (tersimpan dalam bentuk hash bcrypt aman).

### Akun Guru:
- **Nama:** Drs. Budi Santoso
- **Email / Username:** `budi@sekolah.sch.id` / `budi_guru`
- **NIP:** `197505122002121001`
- **Mata Pelajaran yang Diajar:** Pemrograman Web & Basis Data (Kelas X RPL 1, X RPL 2, XI RPL 1)

### Akun Siswa (Aplikasi Android):
1. **Ahmad Rizky Pratama**
   - **Username / NISN:** `0081293812`
   - **Email:** `ahmad@sekolah.sch.id`
   - **Kelas:** X RPL 1
2. **Siti Nurhaliza**
   - **Username / NISN:** `0081293815`
   - **Email:** `siti@sekolah.sch.id`
   - **Kelas:** X RPL 1
3. **Bambang Pamungkas**
   - **Username / NISN:** `0081293820`
   - **Email:** `bambang@sekolah.sch.id`
   - **Kelas:** X RPL 2

---

## 4. Daftar 12 Tabel Relasional

1. **`users`**: Akun autentikasi siswa dan guru.
2. **`classes`**: Data kelas (X RPL 1, X RPL 2, dsb).
3. **`subjects`**: Data mata pelajaran.
4. **`students`**: Profil detail siswa terhubung ke `users` dan `classes`.
5. **`teachers`**: Profil detail guru terhubung ke `users`.
6. **`teacher_subject_classes`**: Pemetaan hak akses guru untuk kelas & mapel tertentu.
7. **`assignments`**: Master tugas sekolah (draf, diterbitkan, tenggat waktu).
8. **`assignment_attachments`**: Berkas lampiran materi/panduan tugas dari guru.
9. **`submissions`**: Riwayat pengumpulan jawaban teks & status tugas siswa.
10. **`submission_files`**: Berkas jawaban yang diunggah siswa (PDF, DOCX, ZIP, gambar).
11. **`grades`**: Nilai numerik (0–100) dan umpan balik/komentar guru.
12. **`activity_logs`**: Log audit aktivitas pembuatan tugas, pengumpulan, dan penilaian.
