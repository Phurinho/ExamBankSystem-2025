const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../db');
require('dotenv').config();

// POST /api/auth/register - ลงทะเบียน
// POST /api/auth/register - ลงทะเบียน
router.post('/register', async (req, res) => {
  console.log('Register request received:', req.body);  // เพิ่ม log
  
  try {
    const { username, email, password, department, role, studentId } = req.body;

    // ตรวจสอบข้อมูล
    if (!username || !email || !password || !department || !role) {
      console.log('Missing required fields');  // เพิ่ม log
      return res.status(400).json({ error: 'กรุณากรอกข้อมูลให้ครบถ้วน' });
    }

    // ถ้าเป็น student ต้องมี studentId
    if (role === 'student' && !studentId) {
      console.log('Student ID missing');  // เพิ่ม log
      return res.status(400).json({ error: 'student ต้องกรอก Student ID' });
    }

    console.log('Checking existing user...');  // เพิ่ม log
    
    // เช็คว่า username หรือ email ซ้ำหรือไม่
    const [existing] = await db.query(
      'SELECT * FROM Users WHERE Username = ? OR Email = ?',
      [username, email]
    );

    if (existing.length > 0) {
      console.log('User already exists');  // เพิ่ม log
      return res.status(400).json({ error: 'Username หรือ Email นี้มีคนใช้แล้ว' });
    }

    console.log('Hashing password...');  // เพิ่ม log
    
    // เข้ารหัสรหัสผ่าน
    const hashedPassword = await bcrypt.hash(password, 10);

    console.log('Inserting to database...');  // เพิ่ม log
    
    // บันทึกลง database
    const [result] = await db.query(
      'INSERT INTO Users (Username, Email, Password, Department, Role, StudentID) VALUES (?, ?, ?, ?, ?, ?)',
      [username, email, hashedPassword, department, role, studentId || null]
    );

    console.log('User created successfully:', result.insertId);  // เพิ่ม log

    return res.status(201).json({ 
      message: 'ลงทะเบียนสำเร็จ',
      userId: result.insertId 
    });

  } catch (error) {
    console.error('Error in register:', error);  // เพิ่ม log แบบละเอียด
    return res.status(500).json({ 
      error: 'เกิดข้อผิดพลาดในการลงทะเบียน',
      details: error.message  // เพิ่ม error details (เฉพาะ development)
    });
  }
});

// POST /api/auth/login - เข้าสู่ระบบ
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: 'กรุณากรอก username และ password' });  // เพิ่ม return
    }

    // หา user จาก username หรือ email
    const [users] = await db.query(
      'SELECT * FROM Users WHERE Username = ? OR Email = ?',
      [username, username]
    );

    if (users.length === 0) {
      return res.status(401).json({ error: 'username หรือ password ไม่ถูกต้อง' });  // เพิ่ม return
    }

    const user = users[0];

    // เช็ครหัสผ่าน
    const validPassword = await bcrypt.compare(password, user.Password);
    if (!validPassword) {
      return res.status(401).json({ error: 'username หรือ password ไม่ถูกต้อง' });  // เพิ่ม return
    }

    // สร้าง JWT Token
    const token = jwt.sign(
      { 
        userId: user.UserID, 
        username: user.Username,
        role: user.Role 
      },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    return res.json({  // เพิ่ม return
      message: 'เข้าสู่ระบบสำเร็จ',
      token: token,
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
    return res.status(500).json({ error: 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ' });  // เพิ่ม return
  }
});

module.exports = router;