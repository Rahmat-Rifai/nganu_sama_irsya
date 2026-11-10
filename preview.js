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
};

// ================= IN-MEMORY API STATE (Shared across Web & Mobile) =================
let taskList = [
  {
    id: 1,
    title: "Layout Responsive CSS Grid & Flexbox",
    subject: "Pemrograman Web",
    targetClass: "X RPL 1",
    due: "2026-11-15T23:59",
    dueFormatted: "15 Nov, 23:59 WIB",
    status: "published",
    submittedCount: 2,
    totalStudents: 32,
    desc: "Struktur antarmuka responsif tanpa AI boilerplate beracuan desain Pngumpul."
  },
  {
    id: 2,
    title: "Desain Skema ERD MySQL dan Normalisasi",
    subject: "Basis Data",
    targetClass: "X RPL 2",
    due: "2026-11-18T17:00",
    dueFormatted: "18 Nov, 17:00 WIB",
    status: "published",
    submittedCount: 0,
    totalStudents: 30,
    desc: "Rancang ERD sistem database relasional minimal 8 tabel relasi lengkap."
  }
];

let classList = [
  { id: 1, name: "X RPL 1", subject: "Pemrograman Web & Basis Data", homeroom: "Drs. Budi Santoso", count: 32 },
  { id: 2, name: "X RPL 2", subject: "Basis Data", homeroom: "Sri Wahyuni, S.Pd.", count: 30 },
  { id: 3, name: "XI RPL 1", subject: "Pemrograman Web Lanjut", homeroom: "Hendra Kurnia, M.Kom.", count: 34 }
];

let studentList = [
  { id: 1, name: "Ahmad Rizky Pratama", nisn: "0081293812", class: "X RPL 1", scoreTugas1: 85 },
  { id: 2, name: "Siti Nurhaliza", nisn: "0081293815", class: "X RPL 1", scoreTugas1: 88 },
  { id: 3, name: "Rizky Maulana", nisn: "0081293801", class: "X RPL 1", scoreTugas1: 92 },
  { id: 4, name: "Dewi Lestari", nisn: "0081293802", class: "X RPL 1", scoreTugas1: 85 },
  { id: 5, name: "Bambang Pamungkas", nisn: "0081293820", class: "X RPL 2", scoreTugas1: null }
];

let submissionList = [
  {
    id: 1,
    taskId: 1,
    student: "Ahmad Rizky Pratama",
    nisn: "0081293812",
    class: "X RPL 1",
    taskTitle: "Tugas 01: CSS Responsive",
    fileName: "Laporan_Tugas01.pdf",
    fileUrl: "/uploads/submissions/Laporan_Tugas01.pdf",
    answerText: "Selamat siang Pak, berikut laporan tugas pengerjaan modul login dan dashboard responsive.",
    timeFormatted: "10 Nov, 14:20",
    score: null,
    feedback: ""
  },
  {
    id: 2,
    taskId: 1,
    student: "Siti Nurhaliza",
    nisn: "0081293815",
    class: "X RPL 1",
    taskTitle: "Tugas 01: CSS Responsive",
    fileName: "source_code_siti.zip",
    fileUrl: "/uploads/submissions/source_code_siti.zip",
    answerText: "Tugas responsif selesai diuji di resolusi mobile dan desktop.",
    timeFormatted: "10 Nov, 15:45",
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
            subjects: ['Pemrograman Web', 'Basis Data'],
            classes: ['X RPL 1', 'X RPL 2', 'XI RPL 1']
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
          targetClass: body.targetClass || 'X RPL 1',
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
          class: body.class || 'X RPL 1',
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
    if (pathname === '/api/students' && req.method === 'GET') return sendJson(res, 200, studentList);

    return sendJson(res, 404, { error: 'Endpoint tidak ditemukan' });
  }

  // ================= STATIC FILES =================
  let reqPath = decodeURI(pathname);
  if (reqPath === '/' || reqPath === '') reqPath = '/index.html';
  
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
