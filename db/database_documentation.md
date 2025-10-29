# 🗄️ Exam Bank Database Documentation (V3)

## 📋 Table of Contents
- [ภาพรวมระบบ](#ภาพรวมระบบ)
- [🆕 What's New in V3](#whats-new-in-v3)
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
- **🆕 จัดหมวดหมู่วิชาตามสาขาวิชา (Subject Categories)**
- คำนวณคะแนนอัตโนมัติ
- เก็บประวัติการทำข้อสอบทั้งหมด
- ค้นหาข้อสอบได้จากชื่อวิชา, หัวข้อ, หรือหมวดหมู่

---

## 🆕 What's New in V3

### เพิ่มฟีเจอร์ใหม่:
1. **ตาราง SubjectCategories** - จัดกลุ่มวิชาตามสาขา
2. **CategoryID ใน Courses** - เชื่อมโยงวิชากับหมวดหมู่
3. **FK TopicID ใน Questions** - แก้ไข FK ที่ขาดหายไป
4. **Views อัปเดต** - แสดง CategoryName ในรายการข้อสอบ

### หมวดหมู่วิชาเริ่มต้น:
```
1. Computer Science & IT
2. Natural Sciences
3. Social Sciences & Humanities
4. Mathematics
5. Engineering
```

---

## 📊 Entity Relationship Diagram

```
┌─────────────────┐
│ SubjectCategories│ 🆕
│  (หมวดหมู่วิชา) │
└────────┬────────┘
         │
         │ (1:N)
         ▼
┌─────────────┐
│   Courses   │
│   (วิชา)    │──────┐
└──────┬──────┘      │
       │             │
       │ (1:N)       │
       ▼             │
┌─────────────┐      │
│   Topics    │      │
│  (หัวข้อ)   │      │
└──────┬──────┘      │
       │             │
       │ (N:1)       │ (N:1)
       ▼             │
┌─────────────┐      │
│   Exams     │◀─────┘
│  (ข้อสอบ)   │
└──────┬──────┘
       │
       │ (1:N)
       ▼
┌─────────────┐
│  Questions  │
│  (คำถาม)    │
└──────┬──────┘
       │
       │ (1:N)
       ▼
┌─────────────┐
│   Choices   │
│ (ตัวเลือก)  │
└─────────────┘

┌─────────────┐
│    Users    │
│  (ผู้ใช้)   │
└──────┬──────┘
       │
       ├──────────────────────────┐
       │ (Instructor)             │ (Student)
       │                          │
       │                   ┌──────▼──────────┐
       │                   │  ExamAttempts   │
       │                   │  (การทำข้อสอบ) │
       │                   └──────┬──────────┘
       │                          │
       │                   ┌──────▼─────────┐
       │                   │ StudentAnswers │
       │                   │  (คำตอบ)      │
       │                   └────────────────┘

┌─────────────────┐     ┌─────────────────┐
│ DifficultyLevels│     │  QuestionTypes  │
│  (ระดับความยาก) │     │  (ประเภทคำถาม) │
└─────────────────┘     └─────────────────┘
```

---

## 📑 ตารางทั้งหมด

### 🆕 1. SubjectCategories (หมวดหมู่วิชา)

**ตารางใหม่** สำหรับจัดกลุ่มวิชาตามสาขาวิชา

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| `CategoryID` | INT | รหัสหมวดหมู่ | PRIMARY KEY, AUTO_INCREMENT |
| `CategoryName` | VARCHAR(100) | ชื่อหมวดหมู่ | UNIQUE, NOT NULL |

**ข้อมูลเริ่มต้น:**
```sql
CategoryID: 1, CategoryName: Computer Science & IT
CategoryID: 2, CategoryName: Natural Sciences
CategoryID: 3, CategoryName: Social Sciences & Humanities
CategoryID: 4, CategoryName: Mathematics
CategoryID: 5, CategoryName: Engineering
```

**ตัวอย่างการใช้งาน:**
```sql
-- ดูหมวดหมู่ทั้งหมด
SELECT * FROM SubjectCategories;

-- เพิ่มหมวดหมู่ใหม่
INSERT INTO SubjectCategories (CategoryName)
VALUES ('Business & Management');

-- แก้ไขชื่อหมวดหมู่
UPDATE SubjectCategories
SET CategoryName = 'Computer Science & Information Technology'
WHERE CategoryID = 1;
```

---

### 2. 👤 Users (ผู้ใช้)

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
UserID: 1, Username: admin, Role: instructor
UserID: 2, Username: teacher, Role: instructor

-- Student
UserID: 11, Username: student1, Role: student, StudentID: 66000001
UserID: 12, Username: student2, Role: student, StudentID: 66000002
```

---

### 3. 📚 Courses (วิชา) - **🔄 Updated**

เก็บข้อมูลรายวิชา **พร้อมหมวดหมู่**

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| `CourseID` | INT | รหัสวิชา | PRIMARY KEY, AUTO_INCREMENT |
| `CourseCode` | VARCHAR(50) | รหัสวิชา เช่น CS101 | UNIQUE, NOT NULL |
| `CourseName` | VARCHAR(255) | ชื่อวิชา | NOT NULL |
| `CategoryID` | INT | 🆕 รหัสหมวดหมู่ | FOREIGN KEY → SubjectCategories, NULL |
| `CreatedAt` | TIMESTAMP | วันที่สร้าง | DEFAULT CURRENT_TIMESTAMP |

**Relationships:**
- `CategoryID` → `SubjectCategories.CategoryID` (ON DELETE SET NULL) 🆕

**ตัวอย่างข้อมูล:**
```sql
CourseID: 1
CourseCode: CS101
CourseName: Intro to Programming
CategoryID: 1  -- Computer Science & IT

CourseID: 4
CourseCode: EE101
CourseName: Circuits I
CategoryID: 5  -- Engineering

CourseID: 7
CourseCode: PHYS101
CourseName: Physics I
CategoryID: 2  -- Natural Sciences
```

**การใช้งาน:**
```sql
-- สร้างวิชาพร้อมหมวดหมู่
INSERT INTO Courses (CourseCode, CourseName, CategoryID)
VALUES ('CS201', 'Data Structures', 1);

-- ดูวิชาตามหมวดหมู่
SELECT c.*, sc.CategoryName
FROM Courses c
LEFT JOIN SubjectCategories sc ON c.CategoryID = sc.CategoryID
WHERE sc.CategoryName = 'Computer Science & IT';

-- นับจำนวนวิชาในแต่ละหมวดหมู่
SELECT sc.CategoryName, COUNT(c.CourseID) AS TotalCourses
FROM SubjectCategories sc
LEFT JOIN Courses c ON c.CategoryID = sc.CategoryID
GROUP BY sc.CategoryID;
```

---

### 4. 📖 Topics (หัวข้อ)

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
TopicID: 1, CourseID: 1, TopicName: Variables & Types
TopicID: 2, CourseID: 1, TopicName: Control Flow
TopicID: 3, CourseID: 2, TopicName: Arrays & Linked Lists
```

---

### 5. 📊 DifficultyLevels (ระดับความยาก)

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

### 6. ❓ QuestionTypes (ประเภทคำถาม)

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

### 7. 📝 Exams (ข้อสอบ)

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

---

### 8. ❔ Questions (คำถาม) - **🔄 Updated**

เก็บคำถามในแต่ละข้อสอบ

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| `QuestionID` | INT | รหัสคำถาม | PRIMARY KEY, AUTO_INCREMENT |
| `ExamID` | INT | รหัสข้อสอบ | FOREIGN KEY → Exams |
| `TopicID` | INT | รหัสหัวข้อ | FOREIGN KEY → Topics 🆕 |
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
- `TopicID` → `Topics.TopicID` **🆕 แก้ไข FK ที่ขาดหายไป**
- `TypeID` → `QuestionTypes.TypeID`
- `DifficultyID` → `DifficultyLevels.DifficultyID`
- `InstructorID` → `Users.UserID` (ON DELETE CASCADE)

---

### 9. ☑️ Choices (ตัวเลือก)

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

---

### 10. 📋 ExamAttempts (การทำข้อสอบ)

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

---

### 11. ✍️ StudentAnswers (คำตอบของนิสิต)

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

---

## 👁️ Views - **🔄 Updated**

### vw_instructor_exam_list - **🆕 เพิ่ม CategoryName**

View สำหรับแสดงรายการข้อสอบของอาจารย์

```sql
CREATE OR REPLACE VIEW vw_instructor_exam_list AS
SELECT
  e.ExamID,
  e.ExamName,
  sc.CategoryName,  -- 🆕 เพิ่ม CategoryName
  c.CourseCode,
  c.CourseName,
  t.TopicName,
  e.Status,
  e.UpdatedAt,
  u.Username AS InstructorName
FROM Exams e
JOIN Courses c ON e.CourseID = c.CourseID
JOIN Topics t ON e.TopicID = t.TopicID
JOIN Users u ON e.InstructorID = u.UserID
LEFT JOIN SubjectCategories sc ON c.CategoryID = sc.CategoryID;  -- 🆕 JOIN
```

**การใช้งาน:**
```sql
-- ดูข้อสอบทั้งหมด
SELECT * FROM vw_instructor_exam_list;

-- ดูข้อสอบตามหมวดหมู่
SELECT * FROM vw_instructor_exam_list 
WHERE CategoryName = 'Computer Science & IT';

-- ดูข้อสอบของอาจารย์คนหนึ่งตามหมวดหมู่
SELECT CategoryName, COUNT(*) AS TotalExams
FROM vw_instructor_exam_list 
WHERE InstructorName = 'admin'
GROUP BY CategoryName;
```

**ตัวอย่างผลลัพธ์:**
```
ExamID | ExamName        | CategoryName              | CourseCode | CourseName           | TopicName          | Status
-------|-----------------|---------------------------|------------|----------------------|--------------------|----------
1      | CS101 Midterm   | Computer Science & IT     | CS101      | Intro to Programming | Variables & Types  | published
7      | EE101 Basic     | Engineering               | EE101      | Circuits I           | Ohm's Law          | published
11     | Physics Quiz    | Natural Sciences          | PHYS101    | Physics I            | Mechanics          | published
```

---

### vw_student_exam_list - **🆕 เพิ่ม CategoryName**

View สำหรับแสดงข้อสอบพร้อมคะแนนของนิสิต

```sql
CREATE OR REPLACE VIEW vw_student_exam_list AS
SELECT
  e.ExamID,
  e.ExamName,
  sc.CategoryName,  -- 🆕 เพิ่ม CategoryName
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
LEFT JOIN ExamAttempts ea ON ea.ExamID = e.ExamID
LEFT JOIN SubjectCategories sc ON c.CategoryID = sc.CategoryID;  -- 🆕 JOIN
```

**การใช้งาน:**
```sql
-- ดูข้อสอบของนิสิตตามหมวดหมู่
SELECT * FROM vw_student_exam_list 
WHERE StudentID = 11 AND CategoryName = 'Computer Science & IT';

-- สรุปคะแนนเฉลี่ยแต่ละหมวดหมู่
SELECT 
  CategoryName,
  COUNT(*) AS ExamsTaken,
  AVG(Percentage) AS AvgPercentage
FROM vw_student_exam_list 
WHERE StudentID = 11 AND Score > 0
GROUP BY CategoryName;
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

  -- คำนวณคะแนนเต็ม
  SELECT SUM(Points) INTO v_total 
  FROM Questions 
  WHERE ExamID = v_examId;

  -- คำนวณคะแนนที่ได้
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

---

## 🔍 Indexes

| Table | Index Name | Columns | Purpose |
|-------|------------|---------|---------|
| Users | `idx_role` | Role | ค้นหาผู้ใช้ตาม role |
| Users | `idx_email` | Email | ค้นหาผู้ใช้ตาม email (login) |

**การเพิ่ม Index เพิ่มเติม:**
```sql
-- เพิ่ม index สำหรับ CategoryID
CREATE INDEX idx_course_category ON Courses(CategoryID);

-- เพิ่ม index สำหรับค้นหาข้อสอบตาม status
CREATE INDEX idx_exam_status ON Exams(Status);

-- เพิ่ม index สำหรับค้นหาการทำข้อสอบของนิสิต
CREATE INDEX idx_attempt_student ON ExamAttempts(StudentID, ExamID);
```

---

## 🔗 ความสัมพันธ์ระหว่างตาราง - **🔄 Updated**

### One-to-Many Relationships

```
SubjectCategories ──→ Courses (1 หมวดหมู่มีหลายวิชา) 🆕

Users (Instructor) ─┬─→ Exams (1 อาจารย์สร้างได้หลายข้อสอบ)