# 🗄️ Exam Bank Database Documentation

## 📋 Table of Contents
- [ภาพรวมระบบ](#ภาพรวมระบบ)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [ตารางทั้งหมด](#ตารางทั้งหมด)
- [Views](#views)
- [Stored Procedures](#stored-procedures)
- [Indexes](#indexes)
- [ความสัมพันธ์ระหว่างตาราง](#ความสัมพันธ์ระหว่างตาราง)
- [ตัวอย่างการใช้งาน](#ตัวอย่างการใช้งาน)

---

## 🎯 ภาพรวมระบบ

ระบบ Exam Bank เป็นระบบจัดการข้อสอบออนไลน์ที่รองรับ 2 บทบาทหลัก:

### 👥 บทบาทผู้ใช้
1. **Instructor (อาจารย์)**
   - สร้างและจัดการข้อสอบ
   - กำหนดคำถามและตัวเลือก
   - เลือกระดับความยาก
   - เผยแพร่หรือซ่อนข้อสอบ

2. **Student (นิสิต)**
   - ทำข้อสอบที่เผยแพร่แล้ว
   - ดูคะแนนและประวัติการทำข้อสอบ
   - ดูเฉลยหลังส่งคำตอบ

### 🎓 ฟีเจอร์หลัก
- รองรับข้อสอบ 2 ประเภท: Multiple Choice (MCQ) และ True/False (TF)
- แบ่งระดับความยาก: Easy, Medium, Hard
- คำนวณคะแนนอัตโนมัติ
- เก็บประวัติการทำข้อสอบทั้งหมด
- ค้นหาข้อสอบได้จากชื่อวิชา, หัวข้อ

---

## 📊 Entity Relationship Diagram

```
┌─────────────┐
│    Users    │
│  (ผู้ใช้)   │
└──────┬──────┘
       │
       ├──────────────────────────┐
       │                          │
       │ (Instructor)             │ (Student)
       │                          │
┌──────▼──────┐            ┌──────▼──────────┐
│    Exams    │            │  ExamAttempts   │
│  (ข้อสอบ)   │            │  (การทำข้อสอบ) │
└──────┬──────┘            └──────┬──────────┘
       │                          │
       │                   ┌──────▼─────────┐
       │                   │ StudentAnswers │
       │                   │  (คำตอบ)      │
       │                   └────────────────┘
       │
┌──────▼──────┐
│  Questions  │
│  (คำถาม)    │
└──────┬──────┘
       │
┌──────▼──────┐
│   Choices   │
│ (ตัวเลือก)  │
└─────────────┘

┌─────────────┐     ┌───────────────────┐     ┌─────────────────┐
│   Courses   │────▶│      Topics       │     │ DifficultyLevels│
│   (วิชา)    │     │     (หัวข้อ)      │     │  (ระดับความยาก) │
└─────────────┘     └───────────────────┘     └─────────────────┘

                    ┌───────────────────┐
                    │  QuestionTypes    │
                    │  (ประเภทคำถาม)   │
                    └───────────────────┘
```

---

## 📑 ตารางทั้งหมด

### 1. 👤 Users (ผู้ใช้)

เก็บข้อมูลผู้ใช้ทั้งอาจารย์และนิสิต

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| `UserID` | INT | รหัสผู้ใช้ | PRIMARY KEY, AUTO_INCREMENT |
| `Username` | VARCHAR(50) | ชื่อผู้ใช้ | UNIQUE, NOT NULL |
| `Email` | VARCHAR(100) | อีเมล | UNIQUE, NOT NULL |
| `Password` | VARCHAR(255) | รหัสผ่าน (hash) | NOT NULL |
| `Department` | VARCHAR(100) | ภาควิชา | |
| `Role` | ENUM | บทบาท | 'instructor' หรือ 'student' |
| `StudentID` | VARCHAR(20) | รหัสนิสิต | NULL สำหรับ instructor |
| `CreatedAt` | TIMESTAMP | วันที่สร้าง | DEFAULT CURRENT_TIMESTAMP |
| `UpdatedAt` | TIMESTAMP | วันที่แก้ไขล่าสุด | ON UPDATE CURRENT_TIMESTAMP |

**Indexes:**
- `idx_role` - เพิ่มความเร็วการค้นหาตาม role
- `idx_email` - เพิ่มความเร็วการค้นหาตาม email

**Business Rules:**
- ถ้า Role = 'student' ต้องมี StudentID (CHECK constraint)
- Username และ Email ต้องไม่ซ้ำ (UNIQUE)

**ตัวอย่างข้อมูล:**
```sql
-- Instructor
UserID: 1
Username: prof_smith
Email: smith@university.com
Password: $2b$10$hashed...
Department: Computer Science
Role: instructor
StudentID: NULL

-- Student
UserID: 2
Username: john_doe
Email: john@student.com
Password: $2b$10$hashed...
Department: Computer Science
Role: student
StudentID: 6510001
```

---

### 2. 📚 Courses (วิชา)

เก็บข้อมูลรายวิชา

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| `CourseID` | INT | รหัสวิชา | PRIMARY KEY, AUTO_INCREMENT |
| `CourseCode` | VARCHAR(50) | รหัสวิชา เช่น CS101 | UNIQUE, NOT NULL |
| `CourseName` | VARCHAR(255) | ชื่อวิชา | NOT NULL |
| `CreatedAt` | TIMESTAMP | วันที่สร้าง | DEFAULT CURRENT_TIMESTAMP |

**ตัวอย่างข้อมูล:**
```sql
CourseID: 1
CourseCode: CS101
CourseName: Introduction to Programming
```

---

### 3. 📖 Topics (หัวข้อ)

เก็บหัวข้อในแต่ละวิชา

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| `TopicID` | INT | รหัสหัวข้อ | PRIMARY KEY, AUTO_INCREMENT |
| `CourseID` | INT | รหัสวิชา | FOREIGN KEY → Courses(CourseID) |
| `TopicName` | VARCHAR(255) | ชื่อหัวข้อ | NOT NULL |
| `CreatedAt` | TIMESTAMP | วันที่สร้าง | DEFAULT CURRENT_TIMESTAMP |

**Relationships:**
- `CourseID` → `Courses.CourseID` (ON DELETE CASCADE)

**ตัวอย่างข้อมูล:**
```sql
TopicID: 1
CourseID: 1
TopicName: Variables and Data Types

TopicID: 2
CourseID: 1
TopicName: Control Flow
```

---

### 4. 📊 DifficultyLevels (ระดับความยาก)

เก็บระดับความยากของคำถาม (ตารางอ้างอิง)

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| `DifficultyID` | INT | รหัสระดับความยาก | PRIMARY KEY, AUTO_INCREMENT |
| `LevelCode` | ENUM | รหัสระดับ | 'EASY', 'MEDIUM', 'HARD' |
| `LevelName` | VARCHAR(50) | ชื่อระดับ | NOT NULL |

**ข้อมูลเริ่มต้น:**
```sql
DifficultyID: 1, LevelCode: EASY,   LevelName: Easy
DifficultyID: 2, LevelCode: MEDIUM, LevelName: Medium
DifficultyID: 3, LevelCode: HARD,   LevelName: Hard
```

---

### 5. ❓ QuestionTypes (ประเภทคำถาม)

เก็บประเภทของคำถาม (ตารางอ้างอิง)

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| `TypeID` | INT | รหัสประเภท | PRIMARY KEY, AUTO_INCREMENT |
| `TypeCode` | ENUM | รหัสประเภท | 'MCQ', 'TF' |
| `TypeName` | VARCHAR(100) | ชื่อประเภท | NOT NULL |

**ข้อมูลเริ่มต้น:**
```sql
TypeID: 1, TypeCode: MCQ, TypeName: Multiple Choice
TypeID: 2, TypeCode: TF,  TypeName: True/False
```

---

### 6. 📝 Exams (ข้อสอบ)

เก็บข้อมูลชุดข้อสอบ

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| `ExamID` | INT | รหัสข้อสอบ | PRIMARY KEY, AUTO_INCREMENT |
| `ExamName` | VARCHAR(255) | ชื่อข้อสอบ | NOT NULL |
| `CourseID` | INT | รหัสวิชา | FOREIGN KEY → Courses |
| `TopicID` | INT | รหัสหัวข้อ | FOREIGN KEY → Topics |
| `InstructorID` | INT | รหัสอาจารย์ผู้สร้าง | FOREIGN KEY → Users |
| `Status` | ENUM | สถานะ | 'draft', 'published' (default: 'draft') |
| `CreatedAt` | TIMESTAMP | วันที่สร้าง | DEFAULT CURRENT_TIMESTAMP |
| `UpdatedAt` | TIMESTAMP | วันที่แก้ไขล่าสุด | ON UPDATE CURRENT_TIMESTAMP |

**Relationships:**
- `CourseID` → `Courses.CourseID` (ON DELETE CASCADE)
- `TopicID` → `Topics.TopicID` (ON DELETE CASCADE)
- `InstructorID` → `Users.UserID` (ON DELETE CASCADE)

**Business Rules:**
- Status = 'draft' → ข้อสอบยังไม่เผยแพร่ (นิสิตไม่เห็น)
- Status = 'published' → ข้อสอบเผยแพร่แล้ว (นิสิตเห็น)

**ตัวอย่างข้อมูล:**
```sql
ExamID: 1
ExamName: Midterm Exam
CourseID: 1
TopicID: 1
InstructorID: 1
Status: published
```

---

### 7. ❔ Questions (คำถาม)

เก็บคำถามในแต่ละข้อสอบ

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| `QuestionID` | INT | รหัสคำถาม | PRIMARY KEY, AUTO_INCREMENT |
| `ExamID` | INT | รหัสข้อสอบ | FOREIGN KEY → Exams |
| `TopicID` | INT | รหัสหัวข้อ | FOREIGN KEY → Topics |
| `TypeID` | INT | รหัสประเภทคำถาม | FOREIGN KEY → QuestionTypes |
| `DifficultyID` | INT | รหัสระดับความยาก | FOREIGN KEY → DifficultyLevels |
| `InstructorID` | INT | รหัสอาจารย์ผู้สร้าง | FOREIGN KEY → Users |
| `QuestionText` | TEXT | โจทย์คำถาม | NOT NULL |
| `ShuffleChoices` | BOOLEAN | สลับตัวเลือกหรือไม่ | DEFAULT TRUE |
| `Points` | DECIMAL(5,2) | คะแนน | DEFAULT 1.0 |
| `OrderIndex` | INT | ลำดับคำถาม | DEFAULT 0 |
| `CreatedAt` | TIMESTAMP | วันที่สร้าง | DEFAULT CURRENT_TIMESTAMP |

**Relationships:**
- `ExamID` → `Exams.ExamID` (ON DELETE CASCADE)
- `TypeID` → `QuestionTypes.TypeID`
- `DifficultyID` → `DifficultyLevels.DifficultyID`
- `InstructorID` → `Users.UserID` (ON DELETE CASCADE)

**ตัวอย่างข้อมูล:**
```sql
-- Multiple Choice Question
QuestionID: 1
ExamID: 1
TypeID: 1 (MCQ)
DifficultyID: 1 (EASY)
QuestionText: What is a variable?
Points: 1.00
OrderIndex: 0

-- True/False Question
QuestionID: 2
ExamID: 1
TypeID: 2 (TF)
DifficultyID: 1 (EASY)
QuestionText: Python is a programming language
Points: 1.00
OrderIndex: 1
```

---

### 8. ☑️ Choices (ตัวเลือก)

เก็บตัวเลือกของแต่ละคำถาม

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| `ChoiceID` | INT | รหัสตัวเลือก | PRIMARY KEY, AUTO_INCREMENT |
| `QuestionID` | INT | รหัสคำถาม | FOREIGN KEY → Questions |
| `ChoiceNo` | INT | ลำดับตัวเลือก | NOT NULL |
| `ChoiceText` | VARCHAR(500) | ข้อความตัวเลือก | NOT NULL |
| `IsCorrect` | BOOLEAN | คำตอบที่ถูกหรือไม่ | DEFAULT FALSE |

**Relationships:**
- `QuestionID` → `Questions.QuestionID` (ON DELETE CASCADE)

**Business Rules:**
- MCQ: มีหลายตัวเลือก (3-4 ตัวเลือก), มี 1 คำตอบที่ถูก
- TF: มี 2 ตัวเลือก (True/False), มี 1 คำตอบที่ถูก

**ตัวอย่างข้อมูล:**
```sql
-- Choices for Question 1 (MCQ)
ChoiceID: 1, QuestionID: 1, ChoiceNo: 1, 
ChoiceText: A container for data, IsCorrect: 1

ChoiceID: 2, QuestionID: 1, ChoiceNo: 2, 
ChoiceText: A function, IsCorrect: 0

ChoiceID: 3, QuestionID: 1, ChoiceNo: 3, 
ChoiceText: A loop, IsCorrect: 0

-- Choices for Question 2 (TF)
ChoiceID: 4, QuestionID: 2, ChoiceNo: 1, 
ChoiceText: True, IsCorrect: 1

ChoiceID: 5, QuestionID: 2, ChoiceNo: 2, 
ChoiceText: False, IsCorrect: 0
```

---

### 9. 📋 ExamAttempts (การทำข้อสอบ)

เก็บประวัติการทำข้อสอบของนิสิต

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| `AttemptID` | INT | รหัสการทำข้อสอบ | PRIMARY KEY, AUTO_INCREMENT |
| `ExamID` | INT | รหัสข้อสอบ | FOREIGN KEY → Exams |
| `StudentID` | INT | รหัสนิสิต | FOREIGN KEY → Users |
| `Status` | ENUM | สถานะ | 'in_progress', 'submitted' |
| `Score` | DECIMAL(6,2) | คะแนนที่ได้ | DEFAULT 0 |
| `TotalPoints` | DECIMAL(6,2) | คะแนนเต็ม | DEFAULT 0 |
| `Percentage` | DECIMAL(5,2) | เปอร์เซ็นต์ | DEFAULT 0 |
| `SubmitTime` | DATETIME | เวลาที่ส่งคำตอบ | NULL |
| `CreatedAt` | TIMESTAMP | เวลาที่เริ่มทำ | DEFAULT CURRENT_TIMESTAMP |

**Relationships:**
- `ExamID` → `Exams.ExamID` (ON DELETE CASCADE)
- `StudentID` → `Users.UserID` (ON DELETE CASCADE)

**Business Rules:**
- Status = 'in_progress' → กำลังทำข้อสอบ
- Status = 'submitted' → ส่งคำตอบแล้ว
- นิสิตสามารถทำข้อสอบซ้ำได้ (สร้าง AttemptID ใหม่)
- Percentage = (Score / TotalPoints) × 100

**ตัวอย่างข้อมูล:**
```sql
AttemptID: 1
ExamID: 1
StudentID: 2
Status: submitted
Score: 8.00
TotalPoints: 10.00
Percentage: 80.00
SubmitTime: 2025-10-27 14:30:00
```

---

### 10. ✍️ StudentAnswers (คำตอบของนิสิต)

เก็บคำตอบของนิสิตในแต่ละคำถาม

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| `AnswerID` | INT | รหัสคำตอบ | PRIMARY KEY, AUTO_INCREMENT |
| `AttemptID` | INT | รหัสการทำข้อสอบ | FOREIGN KEY → ExamAttempts |
| `QuestionID` | INT | รหัสคำถาม | FOREIGN KEY → Questions |
| `ChoiceID` | INT | รหัสตัวเลือกที่เลือก | FOREIGN KEY → Choices |
| `AnswerText` | TEXT | คำตอบแบบข้อความ | NULL (ใช้สำหรับอนาคต) |
| `IsCorrect` | BOOLEAN | ตอบถูกหรือไม่ | DEFAULT FALSE |
| `PointsEarned` | DECIMAL(5,2) | คะแนนที่ได้ | DEFAULT 0 |

**Relationships:**
- `AttemptID` → `ExamAttempts.AttemptID` (ON DELETE CASCADE)
- `QuestionID` → `Questions.QuestionID` (ON DELETE CASCADE)
- `ChoiceID` → `Choices.ChoiceID` (ON DELETE SET NULL)

**Business Rules:**
- ถ้าตอบถูก: IsCorrect = 1, PointsEarned = คะแนนของคำถาม
- ถ้าตอบผิด: IsCorrect = 0, PointsEarned = 0

**ตัวอย่างข้อมูล:**
```sql
-- คำตอบถูก
AnswerID: 1
AttemptID: 1
QuestionID: 1
ChoiceID: 1
IsCorrect: 1
PointsEarned: 1.00

-- คำตอบผิด
AnswerID: 2
AttemptID: 1
QuestionID: 2
ChoiceID: 5
IsCorrect: 0
PointsEarned: 0.00
```

---

## 👁️ Views

### vw_instructor_exam_list

View สำหรับแสดงรายการข้อสอบของอาจารย์

```sql
CREATE OR REPLACE VIEW vw_instructor_exam_list AS
SELECT
  e.ExamID,
  e.ExamName,
  c.CourseCode,
  c.CourseName,
  t.TopicName,
  e.Status,
  e.UpdatedAt,
  u.Username AS InstructorName
FROM Exams e
JOIN Courses c ON e.CourseID = c.CourseID
JOIN Topics t ON e.TopicID = t.TopicID
JOIN Users u ON e.InstructorID = u.UserID;
```

**การใช้งาน:**
```sql
-- ดูข้อสอบทั้งหมด
SELECT * FROM vw_instructor_exam_list;

-- ดูข้อสอบของอาจารย์คนหนึ่ง
SELECT * FROM vw_instructor_exam_list 
WHERE InstructorName = 'prof_smith';

-- ดูเฉพาะข้อสอบที่เผยแพร่แล้ว
SELECT * FROM vw_instructor_exam_list 
WHERE Status = 'published';
```

---

### vw_student_exam_list

View สำหรับแสดงข้อสอบพร้อมคะแนนของนิสิต

```sql
CREATE OR REPLACE VIEW vw_student_exam_list AS
SELECT
  e.ExamID,
  e.ExamName,
  c.CourseCode,
  c.CourseName,
  t.TopicName,
  e.Status,
  ea.StudentID,
  COALESCE(ea.Score, 0) AS Score,
  COALESCE(ea.TotalPoints, 0) AS TotalPoints,
  CASE 
    WHEN ea.TotalPoints > 0 
    THEN ROUND(ea.Score * 100 / ea.TotalPoints, 2) 
    ELSE 0 
  END AS Percentage
FROM Exams e
JOIN Courses c ON e.CourseID = c.CourseID
JOIN Topics t ON e.TopicID = t.TopicID
LEFT JOIN ExamAttempts ea ON ea.ExamID = e.ExamID;
```

**การใช้งาน:**
```sql
-- ดูข้อสอบและคะแนนของนิสิตคนหนึ่ง
SELECT * FROM vw_student_exam_list 
WHERE StudentID = 2;

-- ดูเฉพาะข้อสอบที่ทำแล้ว
SELECT * FROM vw_student_exam_list 
WHERE StudentID = 2 AND Score > 0;

-- ดูข้อสอบที่ยังไม่ได้ทำ
SELECT * FROM vw_student_exam_list 
WHERE StudentID = 2 AND Score = 0;
```

---

## ⚙️ Stored Procedures

### sp_calculate_exam_score

Stored Procedure สำหรับคำนวณคะแนนหลังส่งคำตอบ

```sql
DELIMITER $$

CREATE PROCEDURE sp_calculate_exam_score(IN inAttemptID INT)
BEGIN
  DECLARE v_examId INT;
  DECLARE v_total DECIMAL(6,2);
  DECLARE v_score DECIMAL(6,2);
  DECLARE v_pct DECIMAL(5,2);

  -- หา ExamID จาก AttemptID
  SELECT ExamID INTO v_examId 
  FROM ExamAttempts 
  WHERE AttemptID = inAttemptID;

  -- คำนวณคะแนนเต็ม (รวม Points ของทุกคำถาม)
  SELECT SUM(Points) INTO v_total 
  FROM Questions 
  WHERE ExamID = v_examId;

  -- คำนวณคะแนนที่ได้ (รวม PointsEarned ของทุกคำตอบ)
  SELECT SUM(PointsEarned) INTO v_score 
  FROM StudentAnswers 
  WHERE AttemptID = inAttemptID;

  -- ป้องกัน NULL
  SET v_total = COALESCE(v_total, 0);
  SET v_score = COALESCE(v_score, 0);
  
  -- คำนวณ Percentage
  SET v_pct = IF(v_total > 0, ROUND(v_score * 100 / v_total, 2), 0);

  -- Update ExamAttempts
  UPDATE ExamAttempts
  SET Score = v_score,
      TotalPoints = v_total,
      Percentage = v_pct,
      Status = 'submitted',
      SubmitTime = NOW()
  WHERE AttemptID = inAttemptID;
END$$

DELIMITER ;
```

**การใช้งาน:**
```sql
-- คำนวณคะแนนหลังนิสิตส่งคำตอบ
CALL sp_calculate_exam_score(1);

-- ดูผลลัพธ์
SELECT * FROM ExamAttempts WHERE AttemptID = 1;
```

**ตัวอย่างผลลัพธ์:**
```
AttemptID: 1
Score: 8.00
TotalPoints: 10.00
Percentage: 80.00
Status: submitted
SubmitTime: 2025-10-27 14:30:00
```

---

## 🔍 Indexes

Indexes ที่สร้างไว้เพื่อเพิ่มประสิทธิภาพการค้นหา:

| Table | Index Name | Columns | Purpose |
|-------|------------|---------|---------|
| Users | `idx_role` | Role | ค้นหาผู้ใช้ตาม role |
| Users | `idx_email` | Email | ค้นหาผู้ใช้ตาม email (login) |

**การเพิ่ม Index เพิ่มเติม (ถ้าจำเป็น):**
```sql
-- เพิ่ม index สำหรับค้นหาข้อสอบตาม status
CREATE INDEX idx_exam_status ON Exams(Status);

-- เพิ่ม index สำหรับค้นหาการทำข้อสอบของนิสิต
CREATE INDEX idx_attempt_student ON ExamAttempts(StudentID, ExamID);

-- เพิ่ม index สำหรับค้นหาคำถามในข้อสอบ
CREATE INDEX idx_question_exam ON Questions(ExamID);
```

---

## 🔗 ความสัมพันธ์ระหว่างตาราง

### One-to-Many Relationships

```
Users (Instructor) ─┬─→ Exams (1 อาจารย์สร้างได้หลายข้อสอบ)
                    └─→ Questions (1 อาจารย์สร้างได้หลายคำถาม)

Users (Student) ────→ ExamAttempts (1 นิสิตทำได้หลายครั้ง)

Courses ────────────→ Topics (1 วิชามีได้หลายหัวข้อ)

Exams ──────────────→ Questions (1 ข้อสอบมีได้หลายคำถาม)

Questions ──────────→ Choices (1 คำถามมีได้หลายตัวเลือก)

ExamAttempts ───────→ StudentAnswers (1 การทำข้อสอบมีหลายคำตอบ)
```

### Cascade Delete Rules

เมื่อลบข้อมูลหลัก ข้อมูลที่เกี่ยวข้องจะถูกลบตาม:

```
Users (Instructor) ลบ
  └─→ Exams ลบ
      └─→ Questions ลบ
          └─→ Choices ลบ

Exams ลบ
  ├─→ Questions ลบ
  └─→ ExamAttempts ลบ
      └─→ StudentAnswers ลบ

Courses ลบ
  └─→ Topics ลบ
```

**ตัวอย่าง:**
```sql
-- ถ้าลบ Exam ID 1
DELETE FROM Exams WHERE ExamID = 1;

-- จะลบข้อมูลเหล่านี้ด้วย:
-- - Questions ทั้งหมดในข้อสอบนี้
-- - Choices ของคำถามเหล่านั้น
-- - ExamAttempts ของข้อสอบนี้
-- - StudentAnswers ของ attempts เหล่านั้น
```

---

## 📖 ตัวอย่างการใช้งาน

### 1. สร้างผู้ใช้ใหม่

```sql
-- สร้าง Instructor
INSERT INTO Users (Username, Email, Password, Department, Role)
VALUES ('prof_smith', 'smith@university.com', '$2b$10$hashed...', 'Computer Science', 'instructor');

-- สร้าง Student
INSERT INTO Users (Username, Email, Password, Department, Role, StudentID)
VALUES ('john_doe', 'john@student.com', '$2b$10$hashed...', 'Computer Science', 'student', '6510001');
```

---

### 2. สร้างวิชาและหัวข้อ

```sql
-- สร้างวิชา
INSERT INTO Courses (CourseCode, CourseName)
VALUES ('CS101', 'Introduction to Programming');

-- สร้างหัวข้อ
INSERT INTO Topics (CourseID, TopicName)
VALUES 
  (1, 'Variables and Data Types'),
  (1, 'Control Flow'),
  (1, 'Functions');
```

---

### 3. สร้างข้อสอบ

```sql
-- สร้างข้อสอบ
INSERT INTO Exams (ExamName, CourseID, TopicID, InstructorID, Status)
VALUES ('Midterm Exam', 1, 1, 1, 'published');

-- สร้างคำถาม MCQ
INSERT INTO Questions (ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, Points, OrderIndex)
VALUES (1, 1, 1, 1, 1, 'What is a variable?', 1.00, 0);

-- สร้างตัวเลือก
INSERT INTO Choices (QuestionID, ChoiceNo, ChoiceText, IsCorrect)
VALUES 
  (1, 1, 'A container for data', 1),
  (1, 2, 'A function', 0),
  (1, 3, 'A loop', 0),
  (1, 4, 'A class', 0);

-- สร้างคำถาม True/False
INSERT INTO Questions (ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, Points, OrderIndex)
VALUES (1, 1, 2, 1, 1, 'Python is a programming language', 1.00, 1);

INSERT INTO Choices (QuestionID, ChoiceNo, ChoiceText, IsCorrect)
VALUES 
  (2, 1, 'True', 1),
  (2, 2, 'False', 0);
```

---

### 4. นิสิทำข้อสอบ

```sql
-- เริ่มทำข้อสอบ (สร้าง attempt)
INSERT INTO ExamAttempts (ExamID, StudentID, Status)
VALUES (1, 2, 'in_progress');
-- ได้ AttemptID = 1

-- บันทึกคำตอบคำถามที่ 1 (ตอบถูก)
INSERT INTO StudentAnswers (AttemptID, QuestionID, ChoiceID, IsCorrect, PointsEarned)
VALUES (1, 1, 1, 1, 1.00);

-- บันทึกคำตอบคำถามที่ 2 (ตอบผิด)
INSERT INTO StudentAnswers (AttemptID, QuestionID, ChoiceID, IsCorrect, PointsEarned)
VALUES (1, 2, 2, 0, 0.00);

-- คำนวณคะแนน
CALL sp_calculate_exam_score(1);
```

---

### 5. Query ที่ใช้บ่อย

#### ดูข้อสอบทั้งหมดของอาจารย์

```sql
SELECT 
  e.ExamID,
  e.ExamName,
  c.CourseCode,
  c.CourseName,
  t.TopicName,
  e.Status,
  COUNT(DISTINCT q.QuestionID) AS TotalQuestions,
  SUM(q.Points) AS TotalPoints
FROM Exams e
JOIN Courses c ON e.CourseID = c.CourseID
JOIN Topics t ON e.TopicID = t.TopicID
LEFT JOIN Questions q ON q.ExamID = e.ExamID
WHERE e.InstructorID = 1
GROUP BY e.ExamID
ORDER BY e.UpdatedAt DESC;
```

**ผลลัพธ์:**
```
ExamID | ExamName      | CourseCode | CourseName                    | TopicName              | Status    | TotalQuestions | TotalPoints
-------|---------------|------------|-------------------------------|------------------------|-----------|----------------|-------------
1      | Midterm Exam  | CS101      | Introduction to Programming   | Variables and Data Types| published | 2              | 2.00
```

---

#### ดูคำถามในข้อสอบพร้อมตัวเลือก

```sql
SELECT 
  q.QuestionID,
  q.QuestionText,
  q.Points,
  qt.TypeName,
  dl.LevelName,
  c.ChoiceNo,
  c.ChoiceText,
  c.IsCorrect
FROM Questions q
JOIN QuestionTypes qt ON q.TypeID = qt.TypeID
JOIN DifficultyLevels dl ON q.DifficultyID = dl.DifficultyID
JOIN Choices c ON c.QuestionID = q.QuestionID
WHERE q.ExamID = 1
ORDER BY q.OrderIndex, c.ChoiceNo;
```

**ผลลัพธ์:**
```
QuestionID | QuestionText                      | Points | TypeName        | LevelName | ChoiceNo | ChoiceText           | IsCorrect
-----------|-----------------------------------|--------|-----------------|-----------|----------|----------------------|-----------
1          | What is a variable?               | 1.00   | Multiple Choice | Easy      | 1        | A container for data | 1
1          | What is a variable?               | 1.00   | Multiple Choice | Easy      | 2        | A function           | 0
1          | What is a variable?               | 1.00   | Multiple Choice | Easy      | 3        | A loop               | 0
2          | Python is a programming language  | 1.00   | True/False      | Easy      | 1        | True                 | 1
2          | Python is a programming language  | 1.00   | True/False      | Easy      | 2        | False                | 0
```

---

#### ดูคะแนนของนิสิตในแต่ละข้อสอบ

```sql
SELECT 
  e.ExamName,
  c.CourseCode,
  ea.Score,
  ea.TotalPoints,
  ea.Percentage,
  ea.SubmitTime
FROM ExamAttempts ea
JOIN Exams e ON ea.ExamID = e.ExamID
JOIN Courses c ON e.CourseID = c.CourseID
WHERE ea.StudentID = 2
ORDER BY ea.SubmitTime DESC;
```

**ผลลัพธ์:**
```
ExamName      | CourseCode | Score | TotalPoints | Percentage | SubmitTime
--------------|------------|-------|-------------|------------|--------------------
Midterm Exam  | CS101      | 1.00  | 2.00        | 50.00      | 2025-10-27 14:30:00
```

---

#### ดูเฉลยพร้อมคำตอบของนิสิต

```sql
SELECT 
  q.QuestionText,
  q.Points,
  c.ChoiceText,
  c.IsCorrect AS CorrectAnswer,
  sa.ChoiceID AS StudentChoice,
  sa.IsCorrect AS StudentCorrect,
  sa.PointsEarned
FROM Questions q
JOIN Choices c ON c.QuestionID = q.QuestionID
LEFT JOIN StudentAnswers sa ON sa.QuestionID = q.QuestionID AND sa.AttemptID = 1
WHERE q.ExamID = 1
ORDER BY q.OrderIndex, c.ChoiceNo;
```

**ผลลัพธ์:**
```
QuestionText                      | Points | ChoiceText           | CorrectAnswer | StudentChoice | StudentCorrect | PointsEarned
----------------------------------|--------|----------------------|---------------|---------------|----------------|-------------
What is a variable?               | 1.00   | A container for data | 1             | 1             | 1              | 1.00
What is a variable?               | 1.00   | A function           | 0             | NULL          | NULL           | NULL
What is a variable?               | 1.00   | A loop               | 0             | NULL          | NULL           | NULL
Python is a programming language  | 1.00   | True                 | 1             | NULL          | NULL           | NULL
Python is a programming language  | 1.00   | False                | 0             | 2             | 0              | 0.00
```

---

#### นับจำนวนนิสิตที่ทำข้อสอบแต่ละข้อ

```sql
SELECT 
  e.ExamName,
  COUNT(DISTINCT ea.StudentID) AS TotalStudents,
  AVG(ea.Percentage) AS AverageScore,
  MAX(ea.Percentage) AS HighestScore,
  MIN(ea.Percentage) AS LowestScore
FROM Exams e
LEFT JOIN ExamAttempts ea ON ea.ExamID = e.ExamID AND ea.Status = 'submitted'
WHERE e.InstructorID = 1
GROUP BY e.ExamID;
```

**ผลลัพธ์:**
```
ExamName      | TotalStudents | AverageScore | HighestScore | LowestScore
--------------|---------------|--------------|--------------|-------------
Midterm Exam  | 1             | 50.00        | 50.00        | 50.00
```

---

#### ค้นหาข้อสอบ (Search)

```sql
SELECT 
  e.ExamID,
  e.ExamName,
  c.CourseCode,
  c.CourseName,
  t.TopicName,
  e.Status
FROM Exams e
JOIN Courses c ON e.CourseID = c.CourseID
JOIN Topics t ON e.TopicID = t.TopicID
WHERE e.InstructorID = 1
  AND (
    e.ExamName LIKE '%midterm%' 
    OR c.CourseName LIKE '%programming%'
    OR t.TopicName LIKE '%variable%'
  )
ORDER BY e.UpdatedAt DESC;
```

---

#### ดูประวัติการทำข้อสอบทั้งหมดของนิสิต

```sql
SELECT 
  e.ExamName,
  c.CourseCode,
  ea.AttemptID,
  ea.Score,
  ea.TotalPoints,
  ea.Percentage,
  ea.SubmitTime,
  ROW_NUMBER() OVER (PARTITION BY ea.ExamID ORDER BY ea.SubmitTime DESC) AS AttemptNumber
FROM ExamAttempts ea
JOIN Exams e ON ea.ExamID = e.ExamID
JOIN Courses c ON e.CourseID = c.CourseID
WHERE ea.StudentID = 2 AND ea.Status = 'submitted'
ORDER BY ea.SubmitTime DESC;
```

**ผลลัพธ์:** (แสดงว่าทำข้อสอบเดียวกันกี่ครั้ง)
```
ExamName      | CourseCode | AttemptID | Score | TotalPoints | Percentage | SubmitTime          | AttemptNumber
--------------|------------|-----------|-------|-------------|------------|---------------------|---------------
Midterm Exam  | CS101      | 3         | 2.00  | 2.00        | 100.00     | 2025-10-27 16:00:00 | 1
Midterm Exam  | CS101      | 2         | 1.50  | 2.00        | 75.00      | 2025-10-27 15:00:00 | 2
Midterm Exam  | CS101      | 1         | 1.00  | 2.00        | 50.00      | 2025-10-27 14:30:00 | 3
```

---

#### สถิติคำถามตามระดับความยาก

```sql
SELECT 
  e.ExamName,
  dl.LevelName,
  COUNT(q.QuestionID) AS QuestionCount,
  SUM(q.Points) AS TotalPoints
FROM Exams e
LEFT JOIN Questions q ON q.ExamID = e.ExamID
LEFT JOIN DifficultyLevels dl ON q.DifficultyID = dl.DifficultyID
WHERE e.ExamID = 1
GROUP BY e.ExamID, dl.LevelName;
```

**ผลลัพธ์:**
```
ExamName      | LevelName | QuestionCount | TotalPoints
--------------|-----------|---------------|-------------
Midterm Exam  | Easy      | 2             | 2.00
Midterm Exam  | Medium    | 0             | 0.00
Midterm Exam  | Hard      | 0             | 0.00
```

---

### 6. Transactions (การทำงานแบบ Transaction)

#### สร้างข้อสอบพร้อมคำถามแบบ Transaction

```sql
START TRANSACTION;

-- 1. สร้างข้อสอบ
INSERT INTO Exams (ExamName, CourseID, TopicID, InstructorID, Status)
VALUES ('Final Exam', 1, 2, 1, 'draft');

SET @examId = LAST_INSERT_ID();

-- 2. สร้างคำถามที่ 1
INSERT INTO Questions (ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, Points, OrderIndex)
VALUES (@examId, 2, 1, 2, 1, 'What is a function?', 2.00, 0);

SET @questionId1 = LAST_INSERT_ID();

-- 3. สร้างตัวเลือกคำถามที่ 1
INSERT INTO Choices (QuestionID, ChoiceNo, ChoiceText, IsCorrect)
VALUES 
  (@questionId1, 1, 'A reusable block of code', 1),
  (@questionId1, 2, 'A variable', 0),
  (@questionId1, 3, 'A data type', 0);

-- 4. สร้างคำถามที่ 2
INSERT INTO Questions (ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, Points, OrderIndex)
VALUES (@examId, 2, 2, 1, 1, 'Functions can return values', 1.00, 1);

SET @questionId2 = LAST_INSERT_ID();

-- 5. สร้างตัวเลือกคำถามที่ 2
INSERT INTO Choices (QuestionID, ChoiceNo, ChoiceText, IsCorrect)
VALUES 
  (@questionId2, 1, 'True', 1),
  (@questionId2, 2, 'False', 0);

-- ถ้าทุกอย่างสำเร็จ commit
COMMIT;

-- ถ้ามี error ให้ rollback
-- ROLLBACK;
```

---

### 7. Update และ Delete

#### แก้ไขข้อสอบ

```sql
-- เปลี่ยนสถานะข้อสอบจาก draft เป็น published
UPDATE Exams
SET Status = 'published'
WHERE ExamID = 2 AND InstructorID = 1;

-- แก้ไขชื่อข้อสอบ
UPDATE Exams
SET ExamName = 'Final Exam (Updated)'
WHERE ExamID = 2 AND InstructorID = 1;
```

#### แก้ไขคำถาม

```sql
-- แก้ไขโจทย์คำถาม
UPDATE Questions
SET QuestionText = 'What is a function in programming?'
WHERE QuestionID = 3;

-- แก้ไขคะแนนคำถาม
UPDATE Questions
SET Points = 3.00
WHERE QuestionID = 3;
```

#### ลบข้อสอบ (จะลบ Questions และ Choices ด้วยอัตโนมัติ)

```sql
DELETE FROM Exams
WHERE ExamID = 2 AND InstructorID = 1;
```

#### ลบคำถาม (จะลบ Choices ด้วยอัตโนมัติ)

```sql
DELETE FROM Questions
WHERE QuestionID = 3;
```

---

## 🔒 Security Best Practices

### 1. การเก็บรหัสผ่าน

```sql
-- ❌ ไม่ถูกต้อง: เก็บ plain text
INSERT INTO Users (Username, Email, Password, Role)
VALUES ('user1', 'user1@email.com', 'password123', 'student');

-- ✅ ถูกต้อง: เก็บ hash (ทำใน backend ด้วย bcrypt)
INSERT INTO Users (Username, Email, Password, Role)
VALUES ('user1', 'user1@email.com', '$2b$10$EixZaYVK1fsbw1ZfbX3OXe...', 'student');
```

### 2. การป้องกัน SQL Injection

```sql
-- ❌ ไม่ถูกต้อง: String concatenation
SELECT * FROM Users WHERE Username = '" + username + "'";

-- ✅ ถูกต้อง: ใช้ Prepared Statements
SELECT * FROM Users WHERE Username = ?;
```

### 3. Role-based Access Control

```sql
-- ตรวจสอบว่าเป็น instructor ก่อนสร้างข้อสอบ
SELECT Role FROM Users WHERE UserID = ? AND Role = 'instructor';

-- ตรวจสอบว่าเป็นเจ้าของข้อสอบก่อนแก้ไข
SELECT * FROM Exams 
WHERE ExamID = ? AND InstructorID = ?;
```

---

## 📊 Database Performance Tips

### 1. การใช้ Index

```sql
-- เพิ่ม index สำหรับ column ที่ใช้ค้นหาบ่อยๆ
CREATE INDEX idx_exam_status ON Exams(Status);
CREATE INDEX idx_exam_instructor ON Exams(InstructorID);
CREATE INDEX idx_attempt_student_exam ON ExamAttempts(StudentID, ExamID);

-- ดู indexes ที่มีอยู่
SHOW INDEX FROM Exams;
```

### 2. Query Optimization

```sql
-- ❌ ช้า: ใช้ SELECT *
SELECT * FROM Exams;

-- ✅ เร็ว: เลือกเฉพาะ column ที่ต้องการ
SELECT ExamID, ExamName, Status FROM Exams;

-- ❌ ช้า: N+1 Query Problem
-- ดึง exams แล้วดึง questions ทีละ exam

-- ✅ เร็ว: ใช้ JOIN
SELECT e.*, q.*
FROM Exams e
LEFT JOIN Questions q ON q.ExamID = e.ExamID;
```

### 3. การใช้ EXPLAIN

```sql
-- ดูว่า query ทำงานอย่างไร
EXPLAIN SELECT * FROM Exams WHERE Status = 'published';

-- ดู execution plan
EXPLAIN ANALYZE
SELECT e.ExamName, COUNT(q.QuestionID)
FROM Exams e
LEFT JOIN Questions q ON q.ExamID = e.ExamID
GROUP BY e.ExamID;
```

---

## 🧹 Maintenance Queries

### 1. ลบข้อมูลทดสอบ

```sql
-- ลบ attempts ที่ไม่ได้ submit
DELETE FROM ExamAttempts
WHERE Status = 'in_progress' 
  AND CreatedAt < DATE_SUB(NOW(), INTERVAL 1 DAY);

-- ลบ exams ที่เป็น draft นานเกิน 30 วัน
DELETE FROM Exams
WHERE Status = 'draft'
  AND CreatedAt < DATE_SUB(NOW(), INTERVAL 30 DAY);
```

### 2. Backup และ Restore

```bash
# Backup database
mysqldump -u root -p exam_bank > exam_bank_backup.sql

# Restore database
mysql -u root -p exam_bank < exam_bank_backup.sql

# Backup เฉพาะ structure
mysqldump -u root -p --no-data exam_bank > exam_bank_structure.sql

# Backup เฉพาะข้อมูล
mysqldump -u root -p --no-create-info exam_bank > exam_bank_data.sql
```

### 3. ดูขนาด Database

```sql
SELECT 
  table_name AS 'Table',
  ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.TABLES
WHERE table_schema = 'exam_bank'
ORDER BY (data_length + index_length) DESC;
```

---

## 📝 สรุปสำหรับทีม Frontend

### ข้อมูลที่ Frontend ต้องรู้:

#### 1. User Roles
- `instructor` - สามารถสร้าง/แก้ไข/ลบข้อสอบ
- `student` - สามารถทำข้อสอบและดูคะแนน

#### 2. Exam Status
- `draft` - ยังไม่เผยแพร่ (นิสิตไม่เห็น)
- `published` - เผยแพร่แล้ว (นิสิตเห็น)

#### 3. Question Types
- `MCQ` (TypeID: 1) - Multiple Choice (3-4 ตัวเลือก)
- `TF` (TypeID: 2) - True/False (2 ตัวเลือก)

#### 4. Difficulty Levels
- `EASY` (DifficultyID: 1) - ง่าย
- `MEDIUM` (DifficultyID: 2) - ปานกลาง
- `HARD` (DifficultyID: 3) - ยาก

#### 5. Attempt Status
- `in_progress` - กำลังทำข้อสอบ
- `submitted` - ส่งคำตอบแล้ว

#### 6. การคำนวณคะแนน
```javascript
// Frontend แสดงแบบนี้:
Score: 8.00 / 10.00 (80.00%)

// หรือ
8 / 10 คะแนน (80%)
```

#### 7. การแสดงคำถาม
```javascript
// Multiple Choice
{
  questionText: "What is a variable?",
  type: "MCQ",
  choices: [
    { id: 1, text: "A container for data" },
    { id: 2, text: "A function" },
    { id: 3, text: "A loop" }
  ]
}

// True/False
{
  questionText: "Python is a programming language",
  type: "TF",
  choices: [
    { id: 4, text: "True" },
    { id: 5, text: "False" }
  ]
}
```

---

## ❓ FAQ

### Q: นิสิตสามารถทำข้อสอบซ้ำได้ไหม?
A: ได้ โดยจะสร้าง `AttemptID` ใหม่ทุกครั้ง และเก็บประวัติไว้ทั้งหมด

### Q: อาจารย์แก้ไขข้อสอบที่เผยแพร่แล้วได้ไหม?
A: ได้ แต่จะกระทบคะแนนของนิสิตที่ทำไปแล้ว (ควรเตือนอาจารย์)

### Q: ถ้าลบคำถาม คะแนนนิสิตจะเปลี่ยนไหม?
A: จะเปลี่ยน เพราะ TotalPoints ลดลง (ควรเตือนอาจารย์)

### Q: ข้อสอบสามารถมีคำถามหลายระดับความยากได้ไหม?
A: ได้ แต่ละคำถามมีระดับความยากของตัวเอง

### Q: ตัวเลือกจะถูกสลับทุกครั้งไหม?
A: ดูที่ `ShuffleChoices` ใน Questions (default = TRUE)

---

## 📞 ติดต่อ

หากมีคำถามเกี่ยวกับ Database:
- ตรวจสอบ ERD และความสัมพันธ์ระหว่างตาราง
- ดูตัวอย่าง Query ในเอกสารนี้
- ทดสอบ Query ใน MySQL Workbench ก่อน
- ใช้ `EXPLAIN` เพื่อ optimize query

---

**End of Database Documentation** 🎉