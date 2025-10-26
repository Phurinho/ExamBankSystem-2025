const express = require('express');
const cors = require('cors');
const db = require('./db');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const instructorRoutes = require('./routes/instructor');
const studentRoutes = require('./routes/student');

const app = express();
const PORT = process.env.PORT || 3000;

// ทดสอบ Database Connection
db.query('SELECT 1')
  .then(() => {
    console.log('เชื่อมต่อ Database สำเร็จ');
  })
  .catch(err => {
    console.error('เชื่อมต่อ Database ไม่สำเร็จ:', err.message);
  });

// Middleware - เรียงลำดับสำคัญ
app.use(cors({
  origin: '*',  // อนุญาตทุก origin (สำหรับ development)
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json({ limit: '10mb' }));  // เพิ่ม limit
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Log ทุก request
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/instructor', instructorRoutes);
app.use('/api/student', studentRoutes);

// Route หลัก
app.get('/', (req, res) => {
  return res.json({ 
    message: 'Exam Bank API',
    version: '1.0.0',
    status: 'running',
    endpoints: {
      auth: '/api/auth',
      instructor: '/api/instructor',
      student: '/api/student'
    }
  });
});

// 404 Handler
app.use((req, res) => {
  return res.status(404).json({ error: 'ไม่พบ endpoint นี้' });
});

// Error Handler
app.use((err, req, res, next) => {
  console.error('Server Error:', err.stack);
  return res.status(500).json({ 
    error: 'เกิดข้อผิดพลาดภายในเซิร์ฟเวอร์',
    message: err.message
  });
});

// เริ่ม server
app.listen(PORT, () => {
  console.log(`\nServer กำลังทำงานที่ http://localhost:${PORT}`);
  console.log(`📚 Endpoints:`);
  console.log(`   GET  /`);
  console.log(`   POST /api/auth/register`);
  console.log(`   POST /api/auth/login\n`);
});