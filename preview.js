const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3000;
const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.pdf': 'application/pdf',
  '.apk': 'application/vnd.android.package-archive',
};

// ================= IN-MEMORY API STATE (Shared across Web & Mobile) =================
let taskList = [
  {
    id: 1,
    title: "Pembuatan REST API Backend PHP & MySQL",
    subject: "Pemrograman Web Lanjut",
    targetClass: "XI RPL",
    due: "2026-11-17T23:59",
    dueFormatted: "17 Nov, 23:59 WIB",
    status: "published",
    submittedCount: 2,
    totalStudents: 30,
    desc: "Buat endpoint API JSON autentikasi JWT dan CRUD database relasional MySQL."
  },
  {
    id: 2,
    title: "Pemodelan Struktur Gedung 3D Autodesk Revit",
    subject: "Konstruksi Gedung",
    targetClass: "XI DPIB",
    due: "2026-11-19T16:00",
    dueFormatted: "19 Nov, 16:00 WIB",
    status: "published",
    submittedCount: 1,
    totalStudents: 16,
    desc: "Rancang model BIM struktur kolom, balok beton bertulang, dan visualisasi render 3D."
  },
  {
    id: 3,
    title: "Rigging Tulang & Animasi Karakter 3D Blender",
    subject: "Animasi 3D",
    targetClass: "XI Animasi",
    due: "2026-11-21T23:59",
    dueFormatted: "21 Nov, 23:59 WIB",
    status: "published",
    submittedCount: 1,
    totalStudents: 15,
    desc: "Lakukan bone armature rigging dan buat animasi ekspresi wajah karakter 3D."
  },
  {
    id: 4,
    title: "Pemeriksaan & Penyetelan Celah Katup",
    subject: "Teknik Kendaraan Ringan",
    targetClass: "XI TKR A",
    due: "2026-11-22T15:00",
    dueFormatted: "22 Nov, 15:00 WIB",
    status: "published",
    submittedCount: 1,
    totalStudents: 32,
    desc: "Laporan praktikum tune-up mesin bensin 4 silinder dan pengukuran celah katup hisap/buang."
  },
  {
    id: 5,
    title: "Overhaul Transmisi Manual 5 Percepatan",
    subject: "Chassis & Pemindah Tenaga",
    targetClass: "XI TKR B",
    due: "2026-11-23T14:00",
    dueFormatted: "23 Nov, 14:00 WIB",
    status: "published",
    submittedCount: 0,
    totalStudents: 37,
    desc: "Bongkar transmisi manual 5 percepatan, periksa synchromesh, dan ukur keausan plat kopling."
  },
  {
    id: 6,
    title: "Diagnosis Kerusakan Sensor EFI & Scanner OBD",
    subject: "Sistem Injeksi Lanjut",
    targetClass: "XI TSM A",
    due: "2026-11-25T15:00",
    dueFormatted: "25 Nov, 15:00 WIB",
    status: "published",
    submittedCount: 0,
    totalStudents: 40,
    desc: "Scan diagnostik scanner OBD motor matic dan pengujian modul sensor rem ABS."
  },
  {
    id: 7,
    title: "Akuntansi Pembiayaan Murabahah & Ijarah",
    subject: "Layanan Perbankan Syariah",
    targetClass: "XI PBS",
    due: "2026-11-27T16:00",
    dueFormatted: "27 Nov, 16:00 WIB",
    status: "published",
    submittedCount: 0,
    totalStudents: 18,
    desc: "Perhitungan angsuran margin keuntungan jual beli murabahah dan sewa menyewa ijarah."
  }
];

let classList = [
  { id: 1, name: "XI RPL", subject: "Pemrograman Web & PBO Lanjut", homeroom: "Budi Santoso, M.Pd.", count: 30 },
  { id: 2, name: "XI DPIB", subject: "Aplikasi Revit & Konstruksi Gedung", homeroom: "Martilah, ST", count: 16 },
  { id: 3, name: "XI Animasi", subject: "Animasi 2D & 3D Komputer", homeroom: "Aris Setia Nugraha, S.Pd", count: 15 },
  { id: 4, name: "XI TKR A", subject: "Teknik Kendaraan Ringan Otomotif", homeroom: "Agus Cahyoko Wardani, S.Pd.", count: 32 },
  { id: 5, name: "XI TKR B", subject: "Chassis & Pemindah Tenaga", homeroom: "Wisnu Aji Kurniawan, S.Pd.", count: 37 },
  { id: 6, name: "XI TKR C", subject: "Kelistrikan Kendaraan Ringan", homeroom: "Ihsan Yahdiazka, S.Pd.", count: 36 },
  { id: 7, name: "XI TSM A", subject: "Teknik Sepeda Motor", homeroom: "Wais AlQorni, M.Pd.", count: 40 },
  { id: 8, name: "XI TSM B", subject: "Sistem Injeksi & EFI Sepeda Motor", homeroom: "Norma Hary Nugroho, S.Pd.", count: 33 },
  { id: 9, name: "XI TSM C", subject: "Chassis & Rangka Sepeda Motor", homeroom: "Andi Marsanta, S.Pd.", count: 30 },
  { id: 10, name: "XI PBS", subject: "Layanan Lembaga Keuangan Syariah", homeroom: "Satiman Maskuri, SEI", count: 18 }
];

let studentList = [];
try {
  const rawJson = fs.readFileSync(path.join(__dirname, 'students_xi.json'), 'utf8');
  studentList = JSON.parse(rawJson);
} catch (err) {
  console.error('Gagal memuat students_xi.json:', err.message);
}

let submissionList = [
  {
    id: 1,
    taskId: 1,
    student: "Alfendista Ismail",
    nisn: "007129001",
    class: "XI RPL",
    taskTitle: "Pembuatan REST API Backend PHP & MySQL",
    fileName: "Laporan_API_Backend.pdf",
    fileUrl: "/uploads/submissions/Laporan_Tugas01.pdf",
    answerText: "Selamat siang Pak Budi, berikut laporan tugas implementasi REST API endpoint dan skema database MySQL.",
    timeFormatted: "10 Nov, 14:20",
    score: 85,
    feedback: "Struktur routing dan response JSON sudah sesuai spesifikasi."
  },
  {
    id: 2,
    taskId: 1,
    student: "Aliffio Nugraha",
    nisn: "007129002",
    class: "XI RPL",
    taskTitle: "Pembuatan REST API Backend PHP & MySQL",
    fileName: "source_code_api.zip",
    fileUrl: "/uploads/submissions/source_code_siti.zip",
    answerText: "Source code modul login dan CRUD siswa sudah diuji di Postman.",
    timeFormatted: "10 Nov, 15:45",
    score: null,
    feedback: ""
  },
  {
    id: 3,
    taskId: 2,
    student: "Adrian Yusuf Pratama",
    nisn: "007129031",
    class: "XI DPIB",
    taskTitle: "Pemodelan Struktur Gedung 3D Autodesk Revit",
    fileName: "Model_Revit_Gedung.pdf",
    fileUrl: "/uploads/submissions/Laporan_Tugas01.pdf",
    answerText: "Model 3D struktur kolom dan denah potongan gedung 2 lantai skala 1:100.",
    timeFormatted: "11 Nov, 09:30",
    score: 90,
    feedback: "Detail dimensi struktur sangat presisi."
  },
  {
    id: 4,
    taskId: 3,
    student: "Fizi Novendhika Praditya",
    nisn: "007129047",
    class: "XI Animasi",
    taskTitle: "Rigging Tulang & Animasi Karakter 3D Blender",
    fileName: "Animasi_Rigging_Fizi.zip",
    fileUrl: "/uploads/submissions/source_code_siti.zip",
    answerText: "File blend dan video render animasi walk cycle 30 fps.",
    timeFormatted: "11 Nov, 10:15",
    score: null,
    feedback: ""
  }
];

function sendJson(res, statusCode, data) {
  res.statusCode = statusCode;
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.end(JSON.stringify(data));
}

function parseBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch (e) {
        resolve({});
      }
    });
    req.on('error', reject);
  });
}

// ================= HTTP SERVER =================
const server = http.createServer(async (req, res) => {
  // CORS Preflight
  if (req.method === 'OPTIONS') {
    res.statusCode = 204;
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    res.end();
    return;
  }

  const urlObj = new URL(req.url, `http://${req.headers.host}`);
  const pathname = urlObj.pathname;

  // ================= API ENDPOINTS =================
  if (pathname.startsWith('/api/')) {
    // 1. Auth Login
    if (pathname === '/api/auth/login' && req.method === 'POST') {
      const { identifier, password, role } = await parseBody(req);
      if (identifier && identifier.includes('budi')) {
        return sendJson(res, 200, {
          success: true,
          user: {
            name: 'Drs. Budi Santoso',
            nip: '197505122002121001',
            email: 'budi@sekolah.sch.id',
            role: 'teacher',
            subjects: ['Pemrograman Web & PBO Lanjut', 'Produktif Kejuruan'],
            classes: ['XI RPL', 'XI DPIB', 'XI Animasi', 'XI TKR A', 'XI TKR B', 'XI TKR C', 'XI TSM A', 'XI TSM B', 'XI TSM C', 'XI PBS']
          }
        });
      } else {
        const student = studentList.find(s => s.nisn === identifier || s.name.toLowerCase().includes(identifier.toLowerCase())) || studentList[0];
        return sendJson(res, 200, {
          success: true,
          user: {
            name: student.name,
            nisn: student.nisn,
            class: student.class,
            role: 'student'
          }
        });
      }
    }

    // 2. Tasks API
    if (pathname === '/api/tasks') {
      if (req.method === 'GET') {
        const targetClass = urlObj.searchParams.get('class');
        const tasks = targetClass && targetClass !== 'all' ? taskList.filter(t => t.targetClass === targetClass) : taskList;
        return sendJson(res, 200, tasks);
      }
      if (req.method === 'POST') {
        const body = await parseBody(req);
        const newTask = {
          id: Date.now(),
          title: body.title || 'Tugas Baru',
          subject: body.subject || 'Pemrograman Web',
          targetClass: body.targetClass || 'X RPL',
          due: body.due || new Date().toISOString().slice(0, 16),
          dueFormatted: body.due ? body.due.replace('T', ', ') + ' WIB' : 'Sesuai jadwal',
          status: 'published',
          submittedCount: 0,
          totalStudents: 32,
          desc: body.desc || ''
        };
        taskList.unshift(newTask);
        return sendJson(res, 201, { success: true, task: newTask });
      }
    }

    // 3. Submissions API
    if (pathname === '/api/submissions') {
      if (req.method === 'GET') {
        const studentNisn = urlObj.searchParams.get('nisn');
        const subs = studentNisn ? submissionList.filter(s => s.nisn === studentNisn) : submissionList;
        return sendJson(res, 200, subs);
      }
      if (req.method === 'POST') {
        const body = await parseBody(req);
        const rawFileName = body.fileName || 'berkas_tugas.pdf';
        const safeName = rawFileName.replace(/[^a-zA-Z0-9._-]/g, '_');
        const diskFileName = `${Date.now()}_${safeName}`;
        const diskPath = path.join(__dirname, 'uploads', 'submissions', diskFileName);
        
        // Write file to disk (either base64 decoded or text content)
        try {
          if (body.fileBase64) {
            fs.writeFileSync(diskPath, Buffer.from(body.fileBase64, 'base64'));
          } else {
            const fileHeader = `[TugasKu / Pngumpul Submission File]\nSiswa: ${body.student || 'Ahmad Rizky Pratama'}\nNISN: ${body.nisn || '0081293812'}\nTugas: ${body.taskTitle || 'Tugas 01'}\nWaktu: ${new Date().toISOString()}\n\nCatatan Jawaban Siswa:\n${body.answerText || '-'}\n`;
            fs.writeFileSync(diskPath, fileHeader, 'utf8');
          }
        } catch (e) {
          console.error('Error writing submission file:', e.message);
        }

        const newSub = {
          id: Date.now(),
          taskId: body.taskId || 1,
          student: body.student || 'Ahmad Rizky Pratama',
          nisn: body.nisn || '0081293812',
          class: body.class || 'X RPL',
          taskTitle: body.taskTitle || 'Tugas 01',
          fileName: rawFileName,
          fileUrl: `/uploads/submissions/${diskFileName}`,
          answerText: body.answerText || '',
          timeFormatted: 'Hari ini, ' + new Date().toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' }),
          score: null,
          feedback: ''
        };
        submissionList.unshift(newSub);
        
        // Increment task submittedCount
        const t = taskList.find(task => task.id === newSub.taskId);
        if (t) t.submittedCount += 1;

        return sendJson(res, 201, { success: true, submission: newSub });
      }
    }

    // 4. Grading API
    if (pathname.startsWith('/api/submissions/') && pathname.endsWith('/grade') && req.method === 'POST') {
      const parts = pathname.split('/');
      const subId = parseInt(parts[3], 10);
      const { score, feedback } = await parseBody(req);
      const sub = submissionList.find(s => s.id === subId);
      if (sub) {
        sub.score = score;
        sub.feedback = feedback || '';
        const st = studentList.find(s => s.nisn === sub.nisn);
        if (st) st.scoreTugas1 = score;
        return sendJson(res, 200, { success: true, submission: sub });
      }
      return sendJson(res, 404, { success: false, message: 'Submission not found' });
    }

    // 5. Classes & Students API
    if (pathname === '/api/classes' && req.method === 'GET') return sendJson(res, 200, classList);
    if (pathname === '/api/students') {
      if (req.method === 'GET') return sendJson(res, 200, studentList);
      if (req.method === 'POST') {
        const body = await parseBody(req);
        const newStudent = {
          id: Date.now(),
          name: body.name || 'Siswa Baru',
          nisn: body.nisn || String(Date.now()).slice(-8),
          username: body.username || body.nisn || String(Date.now()).slice(-8),
          email: body.email || `${body.nisn || 'siswa'}@siswa.sch.id`,
          password: body.password || 'siswa123',
          class: body.class || 'X RPL',
          phone: body.phone || '',
          status: body.status || 'active',
          registeredAt: new Date().toISOString().slice(0, 10),
          scoreTugas1: null,
          scoreTugas2: null
        };
        studentList.push(newStudent);
        return sendJson(res, 201, { success: true, student: newStudent });
      }
      if (req.method === 'PUT') {
        const body = await parseBody(req);
        const st = studentList.find(s => s.id === body.id || s.nisn === body.nisn);
        if (st) {
          if (body.name) st.name = body.name;
          if (body.class) st.class = body.class;
          if (body.email) st.email = body.email;
          if (body.password) st.password = body.password;
          if (body.phone !== undefined) st.phone = body.phone;
          if (body.status) st.status = body.status;
          return sendJson(res, 200, { success: true, student: st });
        }
        return sendJson(res, 404, { success: false, message: 'Siswa tidak ditemukan' });
      }
      if (req.method === 'DELETE') {
        const body = await parseBody(req);
        studentList = studentList.filter(s => s.id !== body.id && s.nisn !== body.nisn);
        return sendJson(res, 200, { success: true });
      }
    }

    return sendJson(res, 404, { error: 'Endpoint tidak ditemukan' });
  }

  // ================= STATIC FILES =================
  let reqPath = decodeURI(pathname);
  if (reqPath === '/' || reqPath === '') reqPath = '/index.html';
  if (reqPath.endsWith('/')) reqPath += 'index.html'; // hosting: /app-web/ -> /app-web/index.html
  
  const filePath = path.join(__dirname, reqPath);
  
  if (!filePath.startsWith(__dirname)) {
    res.statusCode = 403;
    res.end('Forbidden');
    return;
  }

  fs.stat(filePath, (err, stats) => {
    if (err || !stats.isFile()) {
      res.statusCode = 404;
      res.setHeader('Content-Type', 'text/html; charset=utf-8');
      res.end(`<h1>404 Not Found</h1><p>${reqPath} tidak ditemukan.</p><p><a href="/index.html">Kembali ke Beranda</a></p>`);
      return;
    }

    const ext = path.extname(filePath).toLowerCase();
    res.statusCode = 200;
    res.setHeader('Content-Type', MIME[ext] || 'application/octet-stream');
    res.setHeader('Access-Control-Allow-Origin', '*');
    fs.createReadStream(filePath).pipe(res);
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Pngumpul Web & API Server running at http://127.0.0.1:${PORT}`);
});
