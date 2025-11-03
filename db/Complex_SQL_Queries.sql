-- ===========================================================
-- 1️⃣ Instructor Dashboard - แสดงข้อสอบทั้งหมด
-- ===========================================================
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
ORDER BY e.UpdatedAt DESC;

-- ===========================================================
-- 2️⃣ Instructor Search Exam - ค้นหาข้อสอบด้วย keyword
-- ===========================================================
SELECT 
  e.ExamID, e.ExamName, sc.CategoryName,
  c.CourseCode, c.CourseName, t.TopicName,
  e.Status, e.UpdatedAt, u.Username AS InstructorName
FROM exams e
JOIN courses c ON e.CourseID = c.CourseID
JOIN topics t ON e.TopicID = t.TopicID
LEFT JOIN categories sc ON c.CategoryID = sc.CategoryID
JOIN users u ON e.InstructorID = u.UserID
WHERE e.Status IN ('draft', 'published')
  AND (
    e.ExamName LIKE '%AI%' OR
    c.CourseName LIKE '%AI%' OR
    t.TopicName LIKE '%AI%' OR
    sc.CategoryName LIKE '%AI%' OR
    u.Username LIKE '%AI%'
  )
ORDER BY e.UpdatedAt DESC;

-- ===========================================================
-- 3️⃣ Instructor Exam Detail - แสดงข้อมูลข้อสอบ + Course + Topic
-- ===========================================================
SELECT 
  e.*, c.CourseCode, c.CourseName, t.TopicName,
  sc.CategoryName, c.CategoryID,
  u.Username AS InstructorName
FROM exams e
JOIN courses c ON e.CourseID = c.CourseID
JOIN topics t ON e.TopicID = t.TopicID
LEFT JOIN categories sc ON c.CategoryID = sc.CategoryID
JOIN users u ON e.InstructorID = u.UserID
WHERE e.ExamID = 101;

-- ===========================================================
-- 4️⃣ Questions in Exam - แสดงคำถามแต่ละข้อในข้อสอบ
-- ===========================================================
SELECT 
  q.QuestionID, q.QuestionText, q.OrderIndex, q.Points,
  qt.TypeCode, qt.TypeName,
  dl.LevelCode, dl.LevelName
FROM questions q
JOIN questiontypes qt ON q.TypeID = qt.TypeID
JOIN difficultylevels dl ON q.DifficultyID = dl.DifficultyID
WHERE q.ExamID = 101
ORDER BY q.OrderIndex;

-- ===========================================================
-- 5️⃣ Student Dashboard - แสดงข้อสอบทั้งหมดพร้อมคะแนนล่าสุด
-- ===========================================================
SELECT 
  e.ExamID, e.ExamName, sc.CategoryName,
  c.CourseCode, c.CourseName, t.TopicName,
  e.Status,
  COALESCE(ea.Score, 0) AS Score,
  COALESCE(ea.TotalPoints, 0) AS TotalPoints,
  COALESCE(ea.Percentage, 0) AS Percentage,
  ea.SubmitTime, ea.AttemptID
FROM exams e
JOIN courses c ON e.CourseID = c.CourseID
JOIN topics t ON e.TopicID = t.TopicID
LEFT JOIN categories sc ON c.CategoryID = sc.CategoryID
LEFT JOIN (
  SELECT ExamID, StudentID, Score, TotalPoints, Percentage, SubmitTime, AttemptID
  FROM examattempts
  WHERE StudentID = 1
  AND AttemptID IN (
    SELECT MAX(AttemptID)
    FROM examattempts
    WHERE StudentID = 1
    GROUP BY ExamID
  )
) ea ON ea.ExamID = e.ExamID
WHERE e.Status = 'published'
ORDER BY e.UpdatedAt DESC;

-- ===========================================================
-- 6️⃣ Student Search Exam - ค้นหาข้อสอบที่เปิดเผยแพร่แล้ว
-- ===========================================================
SELECT 
  e.ExamID, e.ExamName, sc.CategoryName,
  c.CourseCode, c.CourseName, t.TopicName,
  e.Status,
  COALESCE(ea.Score, 0) AS Score,
  COALESCE(ea.TotalPoints, 0) AS TotalPoints,
  COALESCE(ea.Percentage, 0) AS Percentage,
  ea.SubmitTime
FROM exams e
JOIN courses c ON e.CourseID = c.CourseID
JOIN topics t ON e.TopicID = t.TopicID
LEFT JOIN categories sc ON c.CategoryID = sc.CategoryID
LEFT JOIN (
  SELECT ExamID, StudentID, Score, TotalPoints, Percentage, SubmitTime
  FROM examattempts
  WHERE StudentID = 1
  AND AttemptID IN (
    SELECT MAX(AttemptID)
    FROM examattempts
    WHERE StudentID = 1
    GROUP BY ExamID
  )
) ea ON ea.ExamID = e.ExamID
WHERE e.Status = 'published'
  AND (e.ExamName LIKE '%Data%' OR c.CourseName LIKE '%Data%' OR sc.CategoryName LIKE '%Data%')
ORDER BY e.UpdatedAt DESC;

-- ===========================================================
-- 7️⃣ Student Exam Result - แสดงคะแนนเฉพาะ Attempt หนึ่ง
-- ===========================================================
SELECT 
  q.QuestionID, q.QuestionText, q.Points, q.OrderIndex,
  qt.TypeCode, qt.TypeName,
  dl.LevelCode, dl.LevelName,
  sa.ChoiceID AS StudentChoiceID,
  sa.IsCorrect AS StudentIsCorrect,
  sa.PointsEarned
FROM questions q
JOIN questiontypes qt ON q.TypeID = qt.TypeID
JOIN difficultylevels dl ON q.DifficultyID = dl.DifficultyID
LEFT JOIN studentanswers sa 
  ON sa.QuestionID = q.QuestionID AND sa.AttemptID = 555
WHERE q.ExamID = 101
ORDER BY q.OrderIndex;

-- ===========================================================
-- 8️⃣ Choice Detail - ตัวเลือกคำถามพร้อมเฉลย
-- ===========================================================
SELECT 
  ChoiceID, ChoiceNo, ChoiceText, IsCorrect
FROM choices
WHERE QuestionID = 2001
ORDER BY ChoiceNo;

-- ===========================================================
-- 9️⃣ Aggregate: สรุปคะแนนเฉลี่ยของนักศึกษาในแต่ละข้อสอบ
-- ===========================================================
SELECT 
  e.ExamName,
  AVG(a.Percentage) AS AvgPercentage,
  COUNT(a.AttemptID) AS TotalAttempts
FROM examattempts a
JOIN exams e ON a.ExamID = e.ExamID
GROUP BY e.ExamID
ORDER BY AvgPercentage DESC;

-- ===========================================================
-- 🔟 Rank นักศึกษาตามคะแนนรวมสูงสุด
-- ===========================================================
SELECT 
  u.Username,
  SUM(a.Score) AS TotalScore,
  COUNT(a.AttemptID) AS ExamsTaken
FROM examattempts a
JOIN users u ON a.StudentID = u.UserID
GROUP BY a.StudentID
ORDER BY TotalScore DESC
LIMIT 10;

-- ===========================================================
-- 11️⃣ Course Summary - รวมจำนวนข้อสอบต่อรายวิชา
-- ===========================================================
SELECT 
  c.CourseCode,
  c.CourseName,
  COUNT(e.ExamID) AS ExamCount
FROM courses c
LEFT JOIN exams e ON e.CourseID = c.CourseID
GROUP BY c.CourseID
ORDER BY ExamCount DESC;

-- ===========================================================
-- 12️⃣ Difficulty Distribution - นับจำนวนคำถามตามระดับความยาก
-- ===========================================================
SELECT 
  dl.LevelName,
  COUNT(q.QuestionID) AS TotalQuestions
FROM questions q
JOIN difficultylevels dl ON q.DifficultyID = dl.DifficultyID
GROUP BY dl.LevelName
ORDER BY TotalQuestions DESC;
