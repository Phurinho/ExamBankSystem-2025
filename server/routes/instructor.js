const express = require('express');
const router = express.Router();
const db = require('../db');
const bcrypt = require('bcrypt');
const { authenticateToken, requireInstructor } = require('../middleware/auth');

// ใช้ middleware ทุก route
router.use(authenticateToken);
router.use(requireInstructor);

/* ===========================================================
 🧩  DASHBOARD (Instructor + Admin)
=========================================================== */
router.get('/dashboard', async (req, res) => {
  try {
    let sql = `
      SELECT 
        e.ExamID, e.ExamName,
        c.CourseCode, c.CourseName,
        t.TopicName, cat.CategoryName,
        e.Status, e.UpdatedAt,
        u.Username AS InstructorName
      FROM exams e
      JOIN courses c ON e.CourseID = c.CourseID
      JOIN topics t ON e.TopicID = t.TopicID
      LEFT JOIN categories cat ON c.CategoryID = cat.CategoryID
      JOIN users u ON e.InstructorID = u.UserID
    `;
    const params = [];

    // 🔹 ถ้าไม่ใช่ admin → ดูเฉพาะของตัวเอง
    if (req.user.role !== 'admin') {
      sql += ' WHERE e.InstructorID = ?';
      params.push(req.user.userId);
    }

    sql += ' ORDER BY e.UpdatedAt DESC';

    const [exams] = await db.query(sql, params);
    res.json({ exams });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error' });
  }
});

/* ===========================================================
 🔍 SEARCH EXAMS (Instructor + Admin)
=========================================================== */
router.get('/search', async (req, res) => {
  try {
    const keyword = req.query.q?.trim() || '';
    let sql = `
      SELECT 
        e.ExamID, e.ExamName,
        sc.CategoryName, 
        c.CourseCode, c.CourseName,
        t.TopicName, e.Status, e.UpdatedAt,
        u.Username AS InstructorName
      FROM exams e
      JOIN courses c ON e.CourseID = c.CourseID
      JOIN topics t ON e.TopicID = t.TopicID
      LEFT JOIN categories sc ON c.CategoryID = sc.CategoryID
      JOIN users u ON e.InstructorID = u.UserID
      WHERE e.Status IN ('draft', 'published')
        AND (
          e.ExamName LIKE ? OR 
          c.CourseName LIKE ? OR 
          t.TopicName LIKE ? OR 
          sc.CategoryName LIKE ? OR
          u.Username LIKE ?
        )
    `;
    const params = [
      `%${keyword}%`, `%${keyword}%`,
      `%${keyword}%`, `%${keyword}%`,
      `%${keyword}%`
    ];

    // 🔹 Instructor เห็นเฉพาะของตัวเอง
    if (req.user.role !== 'admin') {
      sql += ' AND e.InstructorID = ?';
      params.push(req.user.userId);
    }

    sql += ' ORDER BY e.UpdatedAt DESC';

    const [exams] = await db.query(sql, params);
    res.json({ exams });
  } catch (error) {
    console.error('❌ /api/instructor/search error:', error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาดขณะค้นหาข้อสอบ' });
  }
});

/* ===========================================================
 📄 GET EXAM BY ID (Instructor + Admin)
=========================================================== */
router.get('/exam/:examId', async (req, res) => {
  try {
    const { examId } = req.params;

    let sql = `
      SELECT e.*, c.CourseCode, c.CourseName, t.TopicName,
             sc.CategoryName, c.CategoryID,
             u.Username AS InstructorName
      FROM exams e
      JOIN courses c ON e.CourseID = c.CourseID
      JOIN topics t ON e.TopicID = t.TopicID
      LEFT JOIN categories sc ON c.CategoryID = sc.CategoryID
      JOIN users u ON e.InstructorID = u.UserID
      WHERE e.ExamID = ?
    `;
    const params = [examId];

    if (req.user.role !== 'admin') {
      sql += ' AND e.InstructorID = ?';
      params.push(req.user.userId);
    }

    const [exams] = await db.query(sql, params);
    if (exams.length === 0) return res.status(404).json({ error: 'ไม่พบข้อสอบนี้' });

    const [questions] = await db.query(
      `SELECT q.QuestionID, q.QuestionText, q.OrderIndex, q.Points,
              qt.TypeCode, qt.TypeName,
              dl.LevelCode, dl.LevelName
       FROM questions q
       JOIN questiontypes qt ON q.TypeID = qt.TypeID
       JOIN difficultylevels dl ON q.DifficultyID = dl.DifficultyID
       WHERE q.ExamID = ?
       ORDER BY q.OrderIndex`,
      [examId]
    );

    for (let q of questions) {
      const [choices] = await db.query(
        `SELECT ChoiceID, ChoiceNo, ChoiceText, IsCorrect
         FROM choices WHERE QuestionID = ? ORDER BY ChoiceNo`,
        [q.QuestionID]
      );
      q.choices = choices;
    }

    res.json({ exam: exams[0], questions });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาด' });
  }
});

/* ===========================================================
 🆕 CREATE EXAM (Instructor + Admin)
=========================================================== */
router.post('/exam', async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const { examName, categoryName, courseCode, courseName, topicName, questions, status } = req.body;

    // 🔹 Category
    let [categories] = await connection.query(
      'SELECT CategoryID FROM categories WHERE CategoryName = ?',
      [categoryName]
    );
    let categoryId;
    if (categories.length === 0) {
      const [catResult] = await connection.query(
        'INSERT INTO categories (CategoryName) VALUES (?)',
        [categoryName]
      );
      categoryId = catResult.insertId;
    } else {
      categoryId = categories[0].CategoryID;
    }

    // 🔹 Course
    let [courses] = await connection.query('SELECT CourseID FROM courses WHERE CourseCode = ?', [courseCode]);
    let courseId;
    if (courses.length === 0) {
      const [result] = await connection.query(
        'INSERT INTO courses (CourseCode, CourseName, CategoryID) VALUES (?, ?, ?)',
        [courseCode, courseName, categoryId]
      );
      courseId = result.insertId;
    } else {
      courseId = courses[0].CourseID;
      await connection.query('UPDATE courses SET CategoryID = ? WHERE CourseID = ?', [categoryId, courseId]);
    }

    // 🔹 Topic
    let [topics] = await connection.query(
      'SELECT TopicID FROM topics WHERE CourseID = ? AND TopicName = ?',
      [courseId, topicName]
    );
    let topicId;
    if (topics.length === 0) {
      const [result] = await connection.query(
        'INSERT INTO topics (CourseID, TopicName) VALUES (?, ?)',
        [courseId, topicName]
      );
      topicId = result.insertId;
    } else {
      topicId = topics[0].TopicID;
    }

    // 🔹 Exam
    const [examResult] = await connection.query(
      `INSERT INTO exams (ExamName, CourseID, TopicID, InstructorID, Status)
       VALUES (?, ?, ?, ?, ?)`,
      [examName, courseId, topicId, req.user.userId, status || 'draft']
    );
    const examId = examResult.insertId;

    // 🔹 Questions + Choices
    for (let i = 0; i < (questions || []).length; i++) {
      const q = questions[i];
      const [types] = await connection.query('SELECT TypeID FROM questiontypes WHERE TypeCode = ?', [q.typeCode]);
      const [diffs] = await connection.query('SELECT DifficultyID FROM difficultylevels WHERE LevelCode = ?', [q.difficulty]);

      const [qRes] = await connection.query(
        `INSERT INTO questions (ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, Points, OrderIndex)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [examId, topicId, types[0].TypeID, diffs[0].DifficultyID, req.user.userId, q.questionText, q.points || 1, i]
      );
      const qid = qRes.insertId;

      for (let j = 0; j < (q.choices || []).length; j++) {
        const choice = q.choices[j];
        await connection.query(
          `INSERT INTO choices (QuestionID, ChoiceNo, ChoiceText, IsCorrect)
           VALUES (?, ?, ?, ?)`,
          [qid, j + 1, choice.text, choice.isCorrect ? 1 : 0]
        );
      }
    }

    await connection.commit();
    res.status(201).json({ message: 'สร้างข้อสอบสำเร็จ', examId });
  } catch (error) {
    await connection.rollback();
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาดในการสร้างข้อสอบ' });
  } finally {
    connection.release();
  }
});

/* ===========================================================
 ✏️ UPDATE EXAM (Instructor + Admin)
=========================================================== */
router.put('/exam/:examId', async (req, res) => {
  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    const { examId } = req.params;
    const { examName, status, categoryName, courseName, courseCode, topicName, questions } = req.body;

    // 🔹 ตรวจสอบสิทธิ์ (admin แก้ได้หมด)
    let sql = 'SELECT * FROM exams WHERE ExamID = ?';
    const params = [examId];
    if (req.user.role !== 'admin') {
      sql += ' AND InstructorID = ?';
      params.push(req.user.userId);
    }
    const [exams] = await connection.query(sql, params);
    if (exams.length === 0) return res.status(404).json({ error: 'ไม่พบข้อสอบนี้' });

    const currentExam = exams[0];

    // 🔹 Category
    let categoryId = null;
    if (categoryName) {
      let [categories] = await connection.query(
        'SELECT CategoryID FROM categories WHERE CategoryName = ?',
        [categoryName]
      );
      if (categories.length === 0) {
        const [catResult] = await connection.query(
          'INSERT INTO categories (CategoryName) VALUES (?)',
          [categoryName]
        );
        categoryId = catResult.insertId;
      } else {
        categoryId = categories[0].CategoryID;
      }
    }

    // 🔹 Course
    let [courses] = await connection.query(
      'SELECT CourseID FROM courses WHERE CourseCode = ? OR CourseName = ?',
      [courseCode, courseName]
    );
    let courseId;
    if (courses.length === 0) {
      const [newCourse] = await connection.query(
        'INSERT INTO courses (CourseCode, CourseName, CategoryID) VALUES (?, ?, ?)',
        [courseCode || courseName.replace(/\s/g, '_').substring(0, 10), courseName, categoryId]
      );
      courseId = newCourse.insertId;
    } else {
      courseId = courses[0].CourseID;
      await connection.query('UPDATE courses SET CategoryID = ? WHERE CourseID = ?', [categoryId, courseId]);
    }

    // 🔹 Topic
    let [topics] = await connection.query(
      'SELECT TopicID FROM topics WHERE CourseID = ? AND TopicName = ?',
      [courseId, topicName]
    );
    let topicId;
    if (topics.length === 0) {
      const [newTopic] = await connection.query(
        'INSERT INTO topics (CourseID, TopicName) VALUES (?, ?)',
        [courseId, topicName]
      );
      topicId = newTopic.insertId;
    } else {
      topicId = topics[0].TopicID;
    }

    // 🔹 อัปเดต Exam
    await connection.query(
      `UPDATE exams SET ExamName=?, Status=?, CourseID=?, TopicID=? WHERE ExamID=?`,
      [examName || currentExam.ExamName, status || currentExam.Status, courseId, topicId, examId]
    );

    // 🔹 ลบคำถามเก่า
    await connection.query('DELETE FROM questions WHERE ExamID = ?', [examId]);

    // 🔹 เพิ่มคำถามใหม่
    for (let i = 0; i < (questions || []).length; i++) {
      const q = questions[i];
      const [types] = await connection.query('SELECT TypeID FROM questiontypes WHERE TypeCode = ?', [q.typeCode]);
      const [diffs] = await connection.query('SELECT DifficultyID FROM difficultylevels WHERE LevelCode = ?', [q.difficulty]);

      const [qRes] = await connection.query(
        `INSERT INTO questions (ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, Points, OrderIndex)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [examId, topicId, types[0]?.TypeID, diffs[0]?.DifficultyID, req.user.userId, q.questionText, q.points || 1, i]
      );
      const qid = qRes.insertId;

      for (let j = 0; j < (q.choices || []).length; j++) {
        const choice = q.choices[j];
        await connection.query(
          `INSERT INTO choices (QuestionID, ChoiceNo, ChoiceText, IsCorrect)
           VALUES (?, ?, ?, ?)`,
          [qid, j + 1, choice.text, choice.isCorrect ? 1 : 0]
        );
      }
    }

    await connection.commit();
    res.json({ message: 'แก้ไขข้อสอบสำเร็จ' });
  } catch (error) {
    await connection.rollback();
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาดในการแก้ไขข้อสอบ' });
  } finally {
    connection.release();
  }
});

/* ===========================================================
 🗑️ DELETE EXAM (Instructor + Admin)
=========================================================== */
router.delete('/exam/:examId', async (req, res) => {
  try {
    const { examId } = req.params;

    let sql = 'DELETE FROM exams WHERE ExamID = ?';
    const params = [examId];
    if (req.user.role !== 'admin') {
      sql += ' AND InstructorID = ?';
      params.push(req.user.userId);
    }

    const [result] = await db.query(sql, params);
    if (result.affectedRows === 0)
      return res.status(404).json({ error: 'ไม่พบข้อสอบนี้' });

    res.json({ message: 'ลบข้อสอบสำเร็จ' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาด' });
  }
});

/* ===========================================================
 👤 PROFILE (Instructor + Admin)
=========================================================== */
router.get('/profile', async (req, res) => {
  try {
    const [users] = await db.query(
      'SELECT UserID, Username, Email, Department, Role FROM users WHERE UserID = ?',
      [req.user.userId]
    );
    if (users.length === 0) return res.status(404).json({ error: 'ไม่พบผู้ใช้' });
    res.json({ user: users[0] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาด' });
  }
});

router.put('/profile', async (req, res) => {
  try {
    const { username, email, password, department } = req.body;

    let updates = [];
    let params = [];
    if (username) { updates.push('Username = ?'); params.push(username); }
    if (email) { updates.push('Email = ?'); params.push(email); }
    if (password) {
      const hashedPassword = await bcrypt.hash(password, 10);
      updates.push('Password = ?'); params.push(hashedPassword);
    }
    if (department) { updates.push('Department = ?'); params.push(department); }

    if (updates.length === 0)
      return res.status(400).json({ error: 'ไม่มีข้อมูลที่ต้องการอัพเดท' });

    const query = `UPDATE users SET ${updates.join(', ')} WHERE UserID = ?`;
    params.push(req.user.userId);
    await db.query(query, params);
    res.json({ message: 'อัพเดทโปรไฟล์สำเร็จ' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาด' });
  }
});

router.delete('/profile', async (req, res) => {
  try {
    await db.query('DELETE FROM users WHERE UserID = ?', [req.user.userId]);
    res.json({ message: 'ลบบัญชีสำเร็จ' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาด' });
  }
});

/* ===========================================================
 ⚙️ UPDATE EXAM STATUS
=========================================================== */
router.put('/exam/:examId/status', async (req, res) => {
  try {
    const { examId } = req.params;
    const { status } = req.body;
    await db.query('UPDATE exams SET Status=?, UpdatedAt=NOW() WHERE ExamID=?', [status, examId]);
    res.json({ message: 'Status updated successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to update status' });
  }
});

/* ===========================================================
 📂 GET CATEGORIES
=========================================================== */
router.get('/categories', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT CategoryID, CategoryName FROM categories ORDER BY CategoryName ASC');
    res.json(rows);
  } catch (err) {
    console.error('Error loading categories:', err);
    res.status(500).json({ error: 'Failed to load categories' });
  }
});

module.exports = router;
