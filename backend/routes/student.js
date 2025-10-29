const express = require('express');
const router = express.Router();
const db = require('../db');
const { authenticateToken, requireStudent } = require('../middleware/auth');

// ใช้ middleware ทุก route
router.use(authenticateToken);
router.use(requireStudent);

// GET /api/student/dashboard - แสดงข้อสอบทั้งหมดและคะแนน (เพิ่ม CategoryName)
router.get('/dashboard', async (req, res) => {
  try {
    const [exams] = await db.query(
      `SELECT 
        e.ExamID, 
        e.ExamName, 
        sc.CategoryName,
        c.CourseCode, 
        c.CourseName, 
        t.TopicName,
        e.Status,
        COALESCE(ea.Score, 0) AS Score,
        COALESCE(ea.TotalPoints, 0) AS TotalPoints,
        COALESCE(ea.Percentage, 0) AS Percentage,
        ea.SubmitTime,
        ea.AttemptID
       FROM Exams e
       JOIN Courses c ON e.CourseID = c.CourseID
       JOIN Topics t ON e.TopicID = t.TopicID
       LEFT JOIN SubjectCategories sc ON c.CategoryID = sc.CategoryID
       LEFT JOIN (
         SELECT ExamID, StudentID, Score, TotalPoints, Percentage, SubmitTime, AttemptID
         FROM ExamAttempts
         WHERE StudentID = ?
         AND AttemptID IN (
           SELECT MAX(AttemptID) 
           FROM ExamAttempts 
           WHERE StudentID = ?
           GROUP BY ExamID
         )
       ) ea ON ea.ExamID = e.ExamID
       WHERE e.Status = 'published'
       ORDER BY e.UpdatedAt DESC`,
      [req.user.userId, req.user.userId]
    );

    res.json({ exams });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาด' });
  }
});

// GET /api/student/search?q=keyword - ค้นหาข้อสอบ (เพิ่ม CategoryName และเงื่อนไขค้นหา)
router.get('/search', async (req, res) => {
  try {
    const keyword = req.query.q || '';
    
    const [exams] = await db.query(
      `SELECT 
        e.ExamID, 
        e.ExamName, 
        sc.CategoryName,
        c.CourseCode, 
        c.CourseName, 
        t.TopicName,
        e.Status,
        COALESCE(ea.Score, 0) AS Score,
        COALESCE(ea.TotalPoints, 0) AS TotalPoints,
        COALESCE(ea.Percentage, 0) AS Percentage,
        ea.SubmitTime
       FROM Exams e
       JOIN Courses c ON e.CourseID = c.CourseID
       JOIN Topics t ON e.TopicID = t.TopicID
       LEFT JOIN SubjectCategories sc ON c.CategoryID = sc.CategoryID
       LEFT JOIN (
         SELECT ExamID, StudentID, Score, TotalPoints, Percentage, SubmitTime
         FROM ExamAttempts
         WHERE StudentID = ?
         AND AttemptID IN (
           SELECT MAX(AttemptID) 
           FROM ExamAttempts 
           WHERE StudentID = ?
           GROUP BY ExamID
         )
       ) ea ON ea.ExamID = e.ExamID
       WHERE e.Status = 'published'
       AND (e.ExamName LIKE ? OR c.CourseName LIKE ? OR t.TopicName LIKE ? OR sc.CategoryName LIKE ?)
       ORDER BY e.UpdatedAt DESC`,
      [req.user.userId, req.user.userId, `%${keyword}%`, `%${keyword}%`, `%${keyword}%`, `%${keyword}%`]
    );

    res.json({ exams });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาด' });
  }
});

// GET /api/student/exam/:examId - ดูข้อสอบและเริ่มทำ (เพิ่ม CategoryName)
router.get('/exam/:examId', async (req, res) => {
  try {
    const { examId } = req.params;

    const [exams] = await db.query(
      `SELECT e.*, c.CourseCode, c.CourseName, t.TopicName,
              sc.CategoryName
       FROM Exams e
       JOIN Courses c ON e.CourseID = c.CourseID
       JOIN Topics t ON e.TopicID = t.TopicID
       LEFT JOIN SubjectCategories sc ON c.CategoryID = sc.CategoryID
       WHERE e.ExamID = ? AND e.Status = 'published'`,
      [examId]
    );

    if (exams.length === 0) {
      return res.status(404).json({ error: 'ไม่พบข้อสอบนี้หรือข้อสอบยังไม่เผยแพร่' });
    }

    // ดึงคำถามและตัวเลือก (ไม่แสดงเฉลย)
    const [questions] = await db.query(
      `SELECT q.QuestionID, q.QuestionText, q.OrderIndex, q.Points,
              qt.TypeCode, qt.TypeName,
              dl.LevelCode, dl.LevelName
       FROM Questions q
       JOIN QuestionTypes qt ON q.TypeID = qt.TypeID
       JOIN DifficultyLevels dl ON q.DifficultyID = dl.DifficultyID
       WHERE q.ExamID = ?
       ORDER BY q.OrderIndex`,
      [examId]
    );

    for (let question of questions) {
      const [choices] = await db.query(
        `SELECT ChoiceID, ChoiceNo, ChoiceText
         FROM Choices
         WHERE QuestionID = ?
         ORDER BY ${question.ShuffleChoices ? 'RAND()' : 'ChoiceNo'}`,
        [question.QuestionID]
      );
      question.choices = choices;
    }

    res.json({
      exam: exams[0],
      questions: questions
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาด' });
  }
});

// POST /api/student/exam/:examId/submit - ส่งคำตอบและคำนวณคะแนน
router.post('/exam/:examId/submit', async (req, res) => {
  const connection = await db.getConnection();
  
  try {
    await connection.beginTransaction();

    const { examId } = req.params;
    const { answers } = req.body; // answers = [{ questionId, choiceId }, ...]

    if (!answers || answers.length === 0) {
      return res.status(400).json({ error: 'ไม่มีคำตอบ' });
    }

    // สร้าง ExamAttempt
    const [attemptResult] = await connection.query(
      'INSERT INTO ExamAttempts (ExamID, StudentID, Status) VALUES (?, ?, ?)',
      [examId, req.user.userId, 'in_progress']
    );

    const attemptId = attemptResult.insertId;

    // บันทึกคำตอบและตรวจ
    for (let answer of answers) {
      // ดึงข้อมูลคำถาม
      const [questions] = await connection.query(
        'SELECT Points FROM Questions WHERE QuestionID = ?',
        [answer.questionId]
      );

      if (questions.length === 0) continue;

      const questionPoints = questions[0].Points;

      // เช็คว่าตอบถูกหรือไม่
      const [choices] = await connection.query(
        'SELECT IsCorrect FROM Choices WHERE ChoiceID = ?',
        [answer.choiceId]
      );

      const isCorrect = choices.length > 0 && choices[0].IsCorrect === 1;
      const pointsEarned = isCorrect ? questionPoints : 0;

      // บันทึกคำตอบ
      await connection.query(
        `INSERT INTO StudentAnswers (AttemptID, QuestionID, ChoiceID, IsCorrect, PointsEarned)
         VALUES (?, ?, ?, ?, ?)`,
        [attemptId, answer.questionId, answer.choiceId, isCorrect ? 1 : 0, pointsEarned]
      );
    }

    // คำนวณคะแนนโดยใช้ stored procedure
    await connection.query('CALL sp_calculate_exam_score(?)', [attemptId]);

    // ดึงผลคะแนน
    const [attempts] = await connection.query(
      'SELECT Score, TotalPoints, Percentage FROM ExamAttempts WHERE AttemptID = ?',
      [attemptId]
    );

    await connection.commit();

    res.json({
      message: 'ส่งคำตอบสำเร็จ',
      attemptId: attemptId,
      score: attempts[0].Score,
      totalPoints: attempts[0].TotalPoints,
      percentage: attempts[0].Percentage
    });

  } catch (error) {
    await connection.rollback();
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาดในการส่งคำตอบ' });
  } finally {
    connection.release();
  }
});

// GET /api/student/exam/:examId/result/:attemptId - ดูเฉลย (เพิ่ม CategoryName)
router.get('/exam/:examId/result/:attemptId', async (req, res) => {
  try {
    const { examId, attemptId } = req.params;

    const [attempts] = await db.query(
      `SELECT * FROM ExamAttempts 
       WHERE AttemptID = ? AND ExamID = ? AND StudentID = ?`,
      [attemptId, examId, req.user.userId]
    );

    if (attempts.length === 0) {
      return res.status(404).json({ error: 'ไม่พบผลการสอบนี้' });
    }

    const attempt = attempts[0];

    const [exams] = await db.query(
      `SELECT e.*, c.CourseCode, c.CourseName, t.TopicName,
              sc.CategoryName
       FROM Exams e
       JOIN Courses c ON e.CourseID = c.CourseID
       JOIN Topics t ON e.TopicID = t.TopicID
       LEFT JOIN SubjectCategories sc ON c.CategoryID = sc.CategoryID
       WHERE e.ExamID = ?`,
      [examId]
    );

    // ดึงคำถาม คำตอบของนิสิต และเฉลย
    const [questions] = await db.query(
      `SELECT 
        q.QuestionID,
        q.QuestionText,
        q.Points,
        q.OrderIndex,
        qt.TypeCode,
        qt.TypeName,
        dl.LevelCode,
        dl.LevelName,
        sa.ChoiceID AS StudentChoiceID,
        sa.IsCorrect AS StudentIsCorrect,
        sa.PointsEarned
       FROM Questions q
       JOIN QuestionTypes qt ON q.TypeID = qt.TypeID
       JOIN DifficultyLevels dl ON q.DifficultyID = dl.DifficultyID
       LEFT JOIN StudentAnswers sa ON sa.QuestionID = q.QuestionID AND sa.AttemptID = ?
       WHERE q.ExamID = ?
       ORDER BY q.OrderIndex`,
      [attemptId, examId]
    );

    for (let question of questions) {
      const [choices] = await db.query(
        `SELECT ChoiceID, ChoiceNo, ChoiceText, IsCorrect
         FROM Choices
         WHERE QuestionID = ?
         ORDER BY ChoiceNo`,
        [question.QuestionID]
      );
      question.choices = choices;
    }

    res.json({
      exam: exams[0],
      attempt: {
        attemptId: attempt.AttemptID,
        score: attempt.Score,
        totalPoints: attempt.TotalPoints,
        percentage: attempt.Percentage,
        submitTime: attempt.SubmitTime
      },
      questions: questions
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาด' });
  }
});

// GET /api/student/profile - ดูโปรไฟล์
router.get('/profile', async (req, res) => {
  try {
    const [users] = await db.query(
      'SELECT UserID, Username, Email, Department, Role, StudentID FROM Users WHERE UserID = ?',
      [req.user.userId]
    );

    if (users.length === 0) {
      return res.status(404).json({ error: 'ไม่พบผู้ใช้' });
    }

    res.json({ user: users[0] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาด' });
  }
});

// PUT /api/student/profile - แก้ไขโปรไฟล์
router.put('/profile', async (req, res) => {
  try {
    const { username, email, password, department, studentId } = req.body;

    let query = 'UPDATE Users SET ';
    let params = [];
    let updates = [];

    if (username) {
      updates.push('Username = ?');
      params.push(username);
    }
    if (email) {
      updates.push('Email = ?');
      params.push(email);
    }
    if (password) {
      const bcrypt = require('bcrypt');
      const hashedPassword = await bcrypt.hash(password, 10);
      updates.push('Password = ?');
      params.push(hashedPassword);
    }
    if (department) {
      updates.push('Department = ?');
      params.push(department);
    }
    if (studentId) {
      updates.push('StudentID = ?');
      params.push(studentId);
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'ไม่มีข้อมูลที่ต้องการอัพเดท' });
    }

    query += updates.join(', ') + ' WHERE UserID = ?';
    params.push(req.user.userId);

    await db.query(query, params);

    res.json({ message: 'อัพเดทโปรไฟล์สำเร็จ' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาด' });
  }
});

// DELETE /api/student/profile - ลบบัญชี
router.delete('/profile', async (req, res) => {
  try {
    await db.query('DELETE FROM Users WHERE UserID = ?', [req.user.userId]);
    res.json({ message: 'ลบบัญชีสำเร็จ' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาด' });
  }
});

module.exports = router;