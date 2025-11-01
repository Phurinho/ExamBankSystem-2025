const express = require('express');
const router = express.Router();
const db = require('../db');
require('dotenv').config();

// POST /api/auth/register - ลงทะเบียน
router.post('/register', async (req, res) => {
  console.log('Register request received:', req.body);
  
  try {
    const { username, email, password, department, role, studentId } = req.body;

    // ตรวจสอบข้อมูล
    if (!username || !email || !password || !department || !role) {
      console.log('Missing required fields');
      return res.status(400).json({ error: 'กรุณากรอกข้อมูลให้ครบถ้วน' });
    }

    // ถ้าเป็น student ต้องมี studentId
    if (role === 'student' && !studentId) {
      console.log('Student ID missing');
      return res.status(400).json({ error: 'student ต้องกรอก Student ID' });
    }

    console.log('Checking existing user...');
    
    // เช็คว่า username หรือ email ซ้ำหรือไม่
    const [existing] = await db.query(
      'SELECT * FROM Users WHERE Username = ? OR Email = ?',
      [username, email]
    );

    if (existing.length > 0) {
      console.log('User already exists');
      return res.status(400).json({ error: 'Username หรือ Email นี้มีคนใช้แล้ว' });
    }

    console.log('Inserting to database...');
    
    // บันทึกลง database (ไม่เข้ารหัสรหัสผ่าน)
    const [result] = await db.query(
      'INSERT INTO Users (Username, Email, Password, Department, Role, StudentID) VALUES (?, ?, ?, ?, ?, ?)',
      [username, email, password, department, role, studentId || null]
    );

    console.log('User created successfully:', result.insertId);

    return res.status(201).json({ 
      message: 'ลงทะเบียนสำเร็จ',
      userId: result.insertId 
    });

  } catch (error) {
    console.error('Error in register:', error);
    return res.status(500).json({ 
      error: 'เกิดข้อผิดพลาดในการลงทะเบียน',
      details: error.message
    });
  }
});

// POST /api/auth/login - เข้าสู่ระบบ
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: 'กรุณากรอก username และ password' });
    }

    // หา user จาก username หรือ email
    const [users] = await db.query(
      'SELECT * FROM Users WHERE Username = ? OR Email = ?',
      [username, username]
    );

    if (users.length === 0) {
      return res.status(401).json({ error: 'username หรือ password ไม่ถูกต้อง' });
    }

    const user = users[0];

    // เช็ครหัสผ่านแบบ plain text
    if (password !== user.Password) {
      return res.status(401).json({ error: 'username หรือ password ไม่ถูกต้อง' });
    }

    // ส่งข้อมูล user กลับไปเลย ไม่มี token
    return res.json({
      message: 'เข้าสู่ระบบสำเร็จ',
      user: {
        userId: user.UserID,
        username: user.Username,
        email: user.Email,
        role: user.Role,
        department: user.Department,
        studentId: user.StudentID
      }
    });

  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ' });
  }
});

module.exports = router;