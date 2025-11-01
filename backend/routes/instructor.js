const express = require('express');
const router = express.Router();
const db = require('../db');
const { authenticateToken, requireInstructor } = require('../middleware/auth');

// ใช้ middleware ทุก route
router.use(authenticateToken);
router.use(requireInstructor);

// GET /api/instructor/dashboard - แสดงข้อสอบทั้งหมดของอาจารย์
router.get('/dashboard', async (req, res) => {
  try {
    const [exams] = await db.query(
      `SELECT e.ExamID, e.ExamName, 
              sc.CategoryName, -- ADD
              c.CourseCode, c.CourseName, 
              t.TopicName, e.Status, e.UpdatedAt
       FROM Exams e
       JOIN Courses c ON e.CourseID = c.CourseID
       JOIN Topics t ON e.TopicID = t.TopicID
       LEFT JOIN SubjectCategories sc ON c.CategoryID = sc.CategoryID -- ADD
       WHERE e.InstructorID = ?
       ORDER BY e.UpdatedAt DESC`,
      [req.user.userId]
    );

    res.json({ exams });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาด' });
  }
});

// GET /api/instructor/search?q=keyword - ค้นหาข้อสอบ
router.get('/search', async (req, res) => {
  try {
    const keyword = req.query.q || '';
    
    const [exams] = await db.query(
      `SELECT e.ExamID, e.ExamName,
              sc.CategoryName, -- ADD
              c.CourseCode, c.CourseName,
              t.TopicName, e.Status, e.UpdatedAt
       FROM Exams e
       JOIN Courses c ON e.CourseID = c.CourseID
       JOIN Topics t ON e.TopicID = t.TopicID
       LEFT JOIN SubjectCategories sc ON c.CategoryID = sc.CategoryID -- ADD
       WHERE e.InstructorID = ?
       AND (e.ExamName LIKE ? OR c.CourseName LIKE ? OR t.TopicName LIKE ? OR sc.CategoryName LIKE ?)
       ORDER BY e.UpdatedAt DESC`,
      [req.user.userId, `%${keyword}%`, `%${keyword}%`, `%${keyword}%`, `%${keyword}%`]
    );

    res.json({ exams });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาด' });
  }
});
// GET /api/instructor/exam/:examId - ดูรายละเอียดข้อสอบ
router.get('/exam/:examId', async (req, res) => {
  try {
    const { examId } = req.params;

    // ดึงข้อมูล exam
    const [exams] = await db.query(
      `SELECT e.*, c.CourseCode, c.CourseName, t.TopicName,
              sc.CategoryName, c.CategoryID
       FROM Exams e
       JOIN Courses c ON e.CourseID = c.CourseID
       JOIN Topics t ON e.TopicID = t.TopicID
       LEFT JOIN SubjectCategories sc ON c.CategoryID = sc.CategoryID
       WHERE e.ExamID = ? AND e.InstructorID = ?`,
      [examId, req.user.userId]
    );

    if (exams.length === 0) {
      return res.status(404).json({ error: 'ไม่พบข้อสอบนี้' });
    }

    // ดึงคำถามและตัวเลือก
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

    // ดึง choices สำหรับแต่ละคำถาม
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
      questions: questions
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาด' });
  }
});

// POST /api/instructor/exam - สร้างข้อสอบใหม่
router.post('/exam', async (req, res) => {
  const connection = await db.getConnection();
  
  try {
    await connection.beginTransaction();

    const { examName, categoryName, courseCode, courseName, topicName, questions, status } = req.body; // <<<<<<< ADDED categoryName


    // สร้างหรือหา Category ---
    let categoryId = null;
    if (categoryName) {
      let [categories] = await connection.query(
        'SELECT CategoryID FROM SubjectCategories WHERE CategoryName = ?',
        [categoryName]
      );
      if (categories.length === 0) {
        const [catResult] = await connection.query(
          'INSERT INTO SubjectCategories (CategoryName) VALUES (?)',
          [categoryName]
        );
        categoryId = catResult.insertId;
      } else {
        categoryId = categories[0].CategoryID;
      }
    }
    // 

    // สร้างหรือหา Course
    let [courses] = await connection.query(
      'SELECT CourseID FROM Courses WHERE CourseCode = ?',
      [courseCode]
    );

    let courseId;
    if (courses.length === 0) {
      const [result] = await connection.query(
        'INSERT INTO Courses (CourseCode, CourseName, CategoryID) VALUES (?, ?, ?)',
        [courseCode, courseName, categoryId]
      );
      courseId = result.insertId;
    } else {
      courseId = courses[0].CourseID;
      await connection.query('UPDATE Courses SET CategoryID = ? WHERE CourseID = ?', [categoryId, courseId]);
    }

    // สร้างหรือหา Topic
    let [topics] = await connection.query(
      'SELECT TopicID FROM Topics WHERE CourseID = ? AND TopicName = ?',
      [courseId, topicName]
    );

    let topicId;
    if (topics.length === 0) {
      const [result] = await connection.query(
        'INSERT INTO Topics (CourseID, TopicName) VALUES (?, ?)',
        [courseId, topicName]
      );
      topicId = result.insertId;
    } else {
      topicId = topics[0].TopicID;
    }

    // สร้าง Exam
    const [examResult] = await connection.query(
      `INSERT INTO Exams (ExamName, CourseID, TopicID, InstructorID, Status)
       VALUES (?, ?, ?, ?, ?)`,
      [examName, courseId, topicId, req.user.userId, status || 'draft']
    );

    const examId = examResult.insertId;

    // เพิ่มคำถาม
    if (questions && questions.length > 0) {
      for (let i = 0; i < questions.length; i++) {
        const q = questions[i];
        
        // หา TypeID
        const [types] = await connection.query(
          'SELECT TypeID FROM QuestionTypes WHERE TypeCode = ?',
          [q.typeCode]
        );
        
        // หา DifficultyID
        const [difficulties] = await connection.query(
          'SELECT DifficultyID FROM DifficultyLevels WHERE LevelCode = ?',
          [q.difficulty]
        );

        // เพิ่มคำถาม
        const [qResult] = await connection.query(
          `INSERT INTO Questions (ExamID, TopicID, TypeID, DifficultyID, InstructorID, 
                                   QuestionText, Points, OrderIndex)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
          [examId, topicId, types[0].TypeID, difficulties[0].DifficultyID, 
           req.user.userId, q.questionText, q.points || 1, i]
        );

        const questionId = qResult.insertId;

        // เพิ่ม choices
        if (q.choices && q.choices.length > 0) {
          for (let j = 0; j < q.choices.length; j++) {
            const choice = q.choices[j];
            await connection.query(
              `INSERT INTO Choices (QuestionID, ChoiceNo, ChoiceText, IsCorrect)
               VALUES (?, ?, ?, ?)`,
              [questionId, j + 1, choice.text, choice.isCorrect ? 1 : 0]
            );
          }
        }
      }
    }

    await connection.commit();
    res.status(201).json({ 
      message: 'สร้างข้อสอบสำเร็จ',
      examId: examId 
    });

  } catch (error) {
    await connection.rollback();
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาดในการสร้างข้อสอบ' });
  } finally {
    connection.release();
  }
});

// PUT /api/instructor/exam/:examId - แก้ไขข้อสอบ (รองรับ Category)
router.put('/exam/:examId', async (req, res) => {
  const connection = await db.getConnection();

  try {
    await connection.beginTransaction();

    const { examId } = req.params;
    const { examName, status, categoryName, courseName, courseCode, topicName, questions } = req.body; // <<<<<<< ADDED categoryName

    // ตรวจสอบว่า exam นี้เป็นของ instructor คนนี้หรือไม่
    const [exams] = await connection.query(
      'SELECT * FROM Exams WHERE ExamID = ? AND InstructorID = ?',
      [examId, req.user.userId]
    );

    if (exams.length === 0) {
      return res.status(404).json({ error: 'ไม่พบข้อสอบนี้' });
    }
    const currentExam = exams[0];

    // สร้างหรือหา Category
    let categoryId = null;
    if (categoryName) {
      let [categories] = await connection.query(
        'SELECT CategoryID FROM SubjectCategories WHERE CategoryName = ?',
        [categoryName]
      );
      if (categories.length === 0) {
        const [catResult] = await connection.query(
          'INSERT INTO SubjectCategories (CategoryName) VALUES (?)',
          [categoryName]
        );
        categoryId = catResult.insertId;
      } else {
        categoryId = categories[0].CategoryID;
      }
    }


    // หา (หรือสร้างใหม่) Course (เพิ่ม CategoryID)
    let [courses] = await connection.query(
      'SELECT CourseID FROM Courses WHERE CourseCode = ? OR CourseName = ?',
      [courseCode, courseName]
    );

    let courseId;
    if (courses.length === 0) {
      const [newCourse] = await connection.query(
        'INSERT INTO Courses (CourseCode, CourseName, CategoryID) VALUES (?, ?, ?)', // <<<<<<< MODIFIED
        [courseCode || courseName.replace(/\s/g, '_').substring(0, 10), courseName, categoryId] // <<<<<<< MODIFIED
      );
      courseId = newCourse.insertId;
    } else {
      courseId = courses[0].CourseID;
      // (Optional: อัพเดท CategoryID ของ Course ที่มีอยู่)
       await connection.query('UPDATE Courses SET CategoryID = ? WHERE CourseID = ?', [categoryId, courseId]);
    }

    
    // หา (หรือสร้างใหม่) Topic
    let [topics] = await connection.query(
      'SELECT TopicID FROM Topics WHERE CourseID = ? AND TopicName = ?',
      [courseId, topicName]
    );

    let topicId;
    if (topics.length === 0) {
      const [newTopic] = await connection.query(
        'INSERT INTO Topics (CourseID, TopicName) VALUES (?, ?)',
        [courseId, topicName]
      );
      topicId = newTopic.insertId;
    } else {
      topicId = topics[0].TopicID;
    }

    // อัปเดตข้อมูลในตาราง Exams
    await connection.query(
      `UPDATE Exams 
       SET ExamName = ?, Status = ?, CourseID = ?, TopicID = ? 
       WHERE ExamID = ?`,
      [
        examName || currentExam.ExamName,
        status || currentExam.Status,
        courseId,
        topicId,
        examId
      ]
    );

    // ลบคำถามเก่าทั้งหมด
    await connection.query('DELETE FROM Questions WHERE ExamID = ?', [examId]);

    // พิ่มคำถามใหม่
    for (let i = 0; i < (questions || []).length; i++) {
      const q = questions[i];

      const [types] = await connection.query(
        'SELECT TypeID FROM QuestionTypes WHERE TypeCode = ?',
        [q.typeCode]
      );
      const [diffs] = await connection.query(
        'SELECT DifficultyID FROM DifficultyLevels WHERE LevelCode = ?',
        [q.difficulty]
      );

      const [qRes] = await connection.query(
        `INSERT INTO Questions (ExamID, TopicID, TypeID, DifficultyID, InstructorID, 
                                 QuestionText, Points, OrderIndex)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          examId,
          topicId,
          types[0]?.TypeID,
          diffs[0]?.DifficultyID,
          req.user.userId,
          q.questionText,
          q.points || 1,
          i
        ]
      );

      const qid = qRes.insertId;

      for (let j = 0; j < (q.choices || []).length; j++) {
        const choice = q.choices[j];
        await connection.query(
          `INSERT INTO Choices (QuestionID, ChoiceNo, ChoiceText, IsCorrect)
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

// DELETE /api/instructor/exam/:examId - ลบข้อสอบ
router.delete('/exam/:examId', async (req, res) => {
  try {
    const { examId } = req.params;

    const [result] = await db.query(
      'DELETE FROM Exams WHERE ExamID = ? AND InstructorID = ?',
      [examId, req.user.userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'ไม่พบข้อสอบนี้' });
    }

    res.json({ message: 'ลบข้อสอบสำเร็จ' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาด' });
  }
});

// GET /api/instructor/profile - ดูโปรไฟล์
router.get('/profile', async (req, res) => {
  try {
    const [users] = await db.query(
      'SELECT UserID, Username, Email, Department, Role FROM Users WHERE UserID = ?',
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

// PUT /api/instructor/profile - แก้ไขโปรไฟล์
router.put('/profile', async (req, res) => {
  try {
    const { username, email, password, department } = req.body;

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
      // const hashedPassword = await bcrypt.hash(password, 10);
      updates.push('Password = ?');
      params.push(password);
    }
    if (department) {
      updates.push('Department = ?');
      params.push(department);
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

// DELETE /api/instructor/profile - ลบบัญชี
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