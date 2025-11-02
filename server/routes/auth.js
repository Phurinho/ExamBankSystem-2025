const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../db');
require('dotenv').config();

/**
 * 🧩 REGISTER (POST /api/auth/register)
 */
router.post('/register', async (req, res) => {
  try {
    const { username, email, password, department, role, studentId } = req.body;

    // ✅ ตรวจสอบข้อมูลที่จำเป็น
    if (!username || !email || !password || !department || !role) {
      return res.status(400).json({ error: 'กรุณากรอกข้อมูลให้ครบถ้วน' });
    }

    if (role === 'student' && !studentId) {
      return res.status(400).json({ error: 'student ต้องกรอก Student ID' });
    }

    // ✅ ตรวจซ้ำ username / email
    const [existing] = await db.query(
      'SELECT * FROM users WHERE Username = ? OR Email = ?',
      [username, email]
    );

    if (existing.length > 0) {
      return res.status(400).json({ error: 'Username หรือ Email นี้มีคนใช้แล้ว' });
    }

    // ✅ เข้ารหัสรหัสผ่าน
    const hashedPassword = await bcrypt.hash(password, 10);

    // ✅ บันทึกลงฐานข้อมูล
    const [result] = await db.query(
      `INSERT INTO users 
      (Username, Email, Password, Department, Role, StudentID)
      VALUES (?, ?, ?, ?, ?, ?)`,
      [username, email, hashedPassword, department, role, studentId || null]
    );

    console.log('🟢 Registered user ID:', result.insertId);

    return res.status(201).json({
      message: 'ลงทะเบียนสำเร็จ',
      userId: result.insertId,
    });
  } catch (error) {
    console.error('❌ Register error:', error);
    return res.status(500).json({
      error: 'เกิดข้อผิดพลาดในการลงทะเบียน',
      details: error.message,
    });
  }
});

/**
 * 🔑 LOGIN (POST /api/auth/login)
 */
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    // ✅ ตรวจสอบ input
    if (!username || !password) {
      return res
        .status(400)
        .json({ error: 'กรุณากรอก username และ password' });
    }

    // ✅ หา user จาก username หรือ email
    const [rows] = await db.query(
      'SELECT * FROM users WHERE Username = ? OR Email = ?',
      [username, username]
    );

    if (rows.length === 0) {
      return res.status(401).json({ error: 'username หรือ password ไม่ถูกต้อง' });
    }

    const user = rows[0];

    // ✅ ตรวจสอบ password
    const isPasswordValid = await bcrypt.compare(password, user.Password);
    if (!isPasswordValid) {
      return res.status(401).json({ error: 'username หรือ password ไม่ถูกต้อง' });
    }

    // ✅ สร้าง JWT Token
    const payload = {
      userId: user.UserID,
      username: user.Username,
      role: user.Role,
    };

    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '24h' });

    console.log('🟢 Login success for user:', user.Username);

    // ✅ ส่ง response กลับ
    return res.status(200).json({
      message: 'เข้าสู่ระบบสำเร็จ',
      token,
      user: {
        userId: user.UserID,
        username: user.Username,
        email: user.Email,
        role: user.Role,
        department: user.Department,
        studentId: user.StudentID,
      },
    });
  } catch (error) {
    console.error('❌ Login error:', error);
    return res.status(500).json({
      error: 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ',
      details: error.message,
    });
  }
});

module.exports = router;
