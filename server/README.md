# 📚 Exam Bank API Documentation

## 📋 Table of Contents
- [Base URL](#base-url)
- [Authentication](#authentication)
- [Auth Endpoints](#auth-endpoints)
- [Instructor Endpoints](#instructor-endpoints)
- [Student Endpoints](#student-endpoints)
- [Error Responses](#error-responses)

---

## 🌐 Base URL

```
http://localhost:3000
```

---

## 🔐 Authentication

API ใช้ **JWT (JSON Web Token)** สำหรับ authentication

### วิธีใช้ Token:
หลังจาก login สำเร็จ จะได้ token มา ให้ใส่ใน header ทุกครั้งที่เรียก API ที่ต้อง authentication:

```
Authorization: Bearer YOUR_TOKEN_HERE
```

---

## 🔑 Auth Endpoints

### 1. Register (ลงทะเบียน)

สร้างผู้ใช้ใหม่ในระบบ

**Endpoint:**
```
POST /auth/register
```

**Headers:**
```json
{
  "Content-Type": "application/json"
}
```

**Request Body (Instructor):**
```json
{
  "username": "teacher01",
  "email": "teacher01@example.com",
  "password": "password123",
  "department": "Computer Science",
  "role": "instructor"
}
```

**Request Body (Student):**
```json
{
  "username": "student01",
  "email": "student01@example.com",
  "password": "password123",
  "department": "Computer Science",
  "role": "student",
  "studentId": "6510001"
}
```

**Success Response (201 Created):**
```json
{
  "message": "ลงทะเบียนสำเร็จ",
  "userId": 1
}
```

**Error Responses:**
- `400 Bad Request` - ข้อมูลไม่ครบ
- `400 Bad Request` - Username หรือ Email ซ้ำ
- `500 Internal Server Error` - เกิดข้อผิดพลาด

**Test with curl:**
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"teacher01","email":"teacher01@example.com","password":"password123","department":"Computer Science","role":"instructor"}'
```

---

### 2. Login (เข้าสู่ระบบ)

เข้าสู่ระบบและรับ JWT token

**Endpoint:**
```
POST /auth/login
```

**Headers:**
```json
{
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "username": "teacher01",
  "password": "password123"
}
```

หรือใช้ email:
```json
{
  "username": "teacher01@example.com",
  "password": "password123"
}
```

**Success Response (200 OK):**
```json
{
  "message": "เข้าสู่ระบบสำเร็จ",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "userId": 1,
    "username": "teacher01",
    "email": "teacher01@example.com",
    "role": "instructor",
    "department": "Computer Science",
    "studentId": null
  }
}
```

**Error Responses:**
- `400 Bad Request` - ข้อมูลไม่ครบ
- `401 Unauthorized` - username หรือ password ไม่ถูกต้อง
- `500 Internal Server Error` - เกิดข้อผิดพลาด

**Test with curl:**
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"teacher01","password":"password123"}'
```

---

## 👨‍🏫 Instructor Endpoints

> **⚠️ ต้องมี Token และ Role = instructor**

### 3. Get Dashboard (ดูข้อสอบทั้งหมด) ⭐

แสดงรายการข้อสอบทั้งหมดของอาจารย์

**Endpoint:**
```
GET /instructor/dashboard
```

**Headers:**
```json
{
  "Authorization": "Bearer YOUR_TOKEN_HERE"
}
```

**Success Response (200 OK):**
```json
{
  "exams": [
    {
      "ExamID": 1,
      "ExamName": "Midterm Exam",
      "CategoryName": "Computer Science", // ⭐
      "CourseCode": "CS101",
      "CourseName": "Introduction to Programming",
      "TopicName": "Variables and Data Types",
      "Status": "published",
      "UpdatedAt": "2025-10-27T10:30:00.000Z"
    },
    {
      "ExamID": 2,
      "ExamName": "Final Exam",
      "CategoryName": "Mathematics", // ⭐
      "CourseCode": "CS101",
      "CourseName": "Introduction to Programming",
      "TopicName": "Functions",
      "Status": "draft",
      "UpdatedAt": "2025-10-27T11:00:00.000Z"
    }
  ]
}
```

**Test with curl:**
```bash
curl -X GET http://localhost:3000/instructor/dashboard \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

### 4. Search Exams (ค้นหาข้อสอบ) ⭐

ค้นหาข้อสอบจาก ExamName, CourseName, TopicName หรือ CategoryName

**Endpoint:**
```
GET /instructor/search?q=keyword
```

**Headers:**
```json
{
  "Authorization": "Bearer YOUR_TOKEN_HERE"
}
```

**Query Parameters:**
- `q` (string) - คำค้นหา

**Example:**
```
GET /instructor/search?q=midterm
```

**Success Response (200 OK):**
```json
{
  "exams": [
    {
      "ExamID": 1,
      "ExamName": "Midterm Exam",
      "CategoryName": "Computer Science", // ⭐
      "CourseCode": "CS101",
      "CourseName": "Introduction to Programming",
      "TopicName": "Variables and Data Types",
      "Status": "published",
      "UpdatedAt": "2025-10-27T10:30:00.000Z"
    }
  ]
}
```

**Test with curl:**
```bash
curl -X GET "http://localhost:3000/instructor/search?q=midterm" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

### 5. View Exam Detail (ดูรายละเอียดข้อสอบ) ⭐

ดูข้อสอบพร้อมคำถามและคำตอบทั้งหมด

**Endpoint:**
```
GET /instructor/exam/:examId
```

**Headers:**
```json
{
  "Authorization": "Bearer YOUR_TOKEN_HERE"
}
```

**Example:**
```
GET /instructor/exam/1
```

**Success Response (200 OK):**
```json
{
  "exam": {
    "ExamID": 1,
    "ExamName": "Midterm Exam",
    "CourseID": 1,
    "TopicID": 1,
    "InstructorID": 1,
    "Status": "published",
    "CourseCode": "CS101",
    "CourseName": "Introduction to Programming",
    "TopicName": "Variables and Data Types",
    "CategoryName": "Computer Science", // ⭐
    "CategoryID": 1 // ⭐
  },
  "questions": [
    {
      "QuestionID": 1,
      "QuestionText": "What is a variable?",
      "OrderIndex": 0,
      "Points": 1.00,
      "TypeCode": "MCQ",
      "TypeName": "Multiple Choice",
      "LevelCode": "EASY",
      "LevelName": "Easy",
      "choices": [
        {
          "ChoiceID": 1,
          "ChoiceNo": 1,
          "ChoiceText": "A container for data",
          "IsCorrect": 1
        },
        {
          "ChoiceID": 2,
          "ChoiceNo": 2,
          "ChoiceText": "A function",
          "IsCorrect": 0
        },
        {
          "ChoiceID": 3,
          "ChoiceNo": 3,
          "ChoiceText": "A loop",
          "IsCorrect": 0
        }
      ]
    },
    {
      "QuestionID": 2,
      "QuestionText": "Python is a programming language",
      "OrderIndex": 1,
      "Points": 1.00,
      "TypeCode": "TF",
      "TypeName": "True/False",
      "LevelCode": "EASY",
      "LevelName": "Easy",
      "choices": [
        {
          "ChoiceID": 4,
          "ChoiceNo": 1,
          "ChoiceText": "True",
          "IsCorrect": 1
        },
        {
          "ChoiceID": 5,
          "ChoiceNo": 2,
          "ChoiceText": "False",
          "IsCorrect": 0
        }
      ]
    }
  ]
}
```

**Error Responses:**
- `404 Not Found` - ไม่พบข้อสอบนี้

**Test with curl:**
```bash
curl -X GET http://localhost:3000/instructor/exam/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

### 6. Create Exam (สร้างข้อสอบ) ⭐

สร้างข้อสอบใหม่พร้อมคำถาม

**Endpoint:**
```
POST /instructor/exam
```

**Headers:**
```json
{
  "Authorization": "Bearer YOUR_TOKEN_HERE",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "examName": "Midterm Exam",
  "categoryName": "Computer Science", // ⭐
  "courseCode": "CS101",
  "courseName": "Introduction to Programming",
  "topicName": "Variables and Data Types",
  "status": "draft",
  "questions": [
    {
      "questionText": "What is a variable?",
      "typeCode": "MCQ",
      "difficulty": "EASY",
      "points": 1,
      "choices": [
        {
          "text": "A container for data",
          "isCorrect": true
        },
        {
          "text": "A function",
          "isCorrect": false
        },
        {
          "text": "A loop",
          "isCorrect": false
        }
      ]
    },
    {
      "questionText": "Python is a programming language",
      "typeCode": "TF",
      "difficulty": "EASY",
      "points": 1,
      "choices": [
        {
          "text": "True",
          "isCorrect": true
        },
        {
          "text": "False",
          "isCorrect": false
        }
      ]
    }
  ]
}
```

**Field Descriptions:**
- `examName` (string, required) - ชื่อข้อสอบ
- `categoryName` (string, optional) - ⭐ ชื่อหมวดหมู่วิชา
- `courseCode` (string, required) - รหัสวิชา เช่น CS101
- `courseName` (string, required) - ชื่อวิชา
- `topicName` (string, required) - หัวข้อ
- `status` (enum, optional) - "draft" หรือ "published" (default: "draft")
- `questions` (array, optional) - รายการคำถาม
  - `questionText` (string, required) - โจทย์
  - `typeCode` (enum, required) - "MCQ" หรือ "TF"
  - `difficulty` (enum, required) - "EASY", "MEDIUM", หรือ "HARD"
  - `points` (number, optional) - คะแนน (default: 1)
  - `choices` (array, required) - ตัวเลือก
    - `text` (string, required) - ข้อความตัวเลือก
    - `isCorrect` (boolean, required) - คำตอบที่ถูกหรือไม่

**Success Response (201 Created):**
```json
{
  "message": "สร้างข้อสอบสำเร็จ",
  "examId": 1
}
```

**Test with curl:**
```bash
curl -X POST http://localhost:3000/instructor/exam \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "examName": "Midterm Exam",
    "categoryName": "Computer Science",
    "courseCode": "CS101",
    "courseName": "Introduction to Programming",
    "topicName": "Variables and Data Types",
    "status": "draft",
    "questions": [
      {
        "questionText": "What is a variable?",
        "typeCode": "MCQ",
        "difficulty": "EASY",
        "points": 1,
        "choices": [
          {"text": "A container for data", "isCorrect": true},
          {"text": "A function", "isCorrect": false},
          {"text": "A loop", "isCorrect": false}
        ]
      }
    ]
  }'
```

---

### 7. Update Exam (แก้ไขข้อสอบ) ⭐

แก้ไขข้อสอบที่มีอยู่

**Endpoint:**
```
PUT /instructor/exam/:examId
```

**Headers:**
```json
{
  "Authorization": "Bearer YOUR_TOKEN_HERE",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "examName": "Midterm Exam (Updated)",
  "categoryName": "Information Technology", // ⭐
  "status": "published",
  "questions": [
    {
      "questionText": "What is a variable in programming?",
      "typeCode": "MCQ",
      "difficulty": "MEDIUM",
      "points": 2,
      "choices": [
        {"text": "A container for storing data", "isCorrect": true},
        {"text": "A function", "isCorrect": false},
        {"text": "A loop", "isCorrect": false}
      ]
    }
  ]
}
```

**Success Response (200 OK):**
```json
{
  "message": "แก้ไขข้อสอบสำเร็จ"
}
```

**Error Responses:**
- `404 Not Found` - ไม่พบข้อสอบนี้

**Test with curl:**
```bash
curl -X PUT http://localhost:3000/instructor/exam/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{"examName": "Midterm Exam (Updated)", "status": "published"}'
```

---

### 8. Delete Exam (ลบข้อสอบ)

ลบข้อสอบออกจากระบบ

**Endpoint:**
```
DELETE /instructor/exam/:examId
```

**Headers:**
```json
{
  "Authorization": "Bearer YOUR_TOKEN_HERE"
}
```

**Example:**
```
DELETE /instructor/exam/1
```

**Success Response (200 OK):**
```json
{
  "message": "ลบข้อสอบสำเร็จ"
}
```

**Error Responses:**
- `404 Not Found` - ไม่พบข้อสอบนี้

**Test with curl:**
```bash
curl -X DELETE http://localhost:3000/instructor/exam/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

### 9. Get Profile (ดูโปรไฟล์)

ดูข้อมูลส่วนตัวของอาจารย์

**Endpoint:**
```
GET /instructor/profile
```

**Headers:**
```json
{
  "Authorization": "Bearer YOUR_TOKEN_HERE"
}
```

**Success Response (200 OK):**
```json
{
  "user": {
    "UserID": 1,
    "Username": "teacher01",
    "Email": "teacher01@example.com",
    "Department": "Computer Science",
    "Role": "instructor"
  }
}
```

**Test with curl:**
```bash
curl -X GET http://localhost:3000/instructor/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

### 10. Update Profile (แก้ไขโปรไฟล์)

แก้ไขข้อมูลส่วนตัว

**Endpoint:**
```
PUT /instructor/profile
```

**Headers:**
```json
{
  "Authorization": "Bearer YOUR_TOKEN_HERE",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "username": "teacher01_updated",
  "email": "newemail@example.com",
  "password": "newpassword123",
  "department": "Software Engineering"
}
```

**Note:** ส่งเฉพาะฟิลด์ที่ต้องการแก้ไข

**Success Response (200 OK):**
```json
{
  "message": "อัพเดทโปรไฟล์สำเร็จ"
}
```

**Test with curl:**
```bash
curl -X PUT http://localhost:3000/instructor/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{"department": "Software Engineering"}'
```

---

### 11. Delete Account (ลบบัญชี)

ลบบัญชีผู้ใช้ออกจากระบบ

**Endpoint:**
```
DELETE /instructor/profile
```

**Headers:**
```json
{
  "Authorization": "Bearer YOUR_TOKEN_HERE"
}
```

**Success Response (200 OK):**
```json
{
  "message": "ลบบัญชีสำเร็จ"
}
```

**Test with curl:**
```bash
curl -X DELETE http://localhost:3000/instructor/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 👨‍🎓 Student Endpoints

> **⚠️ ต้องมี Token และ Role = student**

### 12. Get Dashboard (ดูข้อสอบและคะแนน) ⭐

แสดงข้อสอบทั้งหมดพร้อมคะแนนล่าสุด

**Endpoint:**
```
GET /student/dashboard
```

**Headers:**
```json
{
  "Authorization": "Bearer YOUR_TOKEN_HERE"
}
```

**Success Response (200 OK):**
```json
{
  "exams": [
    {
      "ExamID": 1,
      "ExamName": "Midterm Exam",
      "CategoryName": "Computer Science", // ⭐
      "CourseCode": "CS101",
      "CourseName": "Introduction to Programming",
      "TopicName": "Variables and Data Types",
      "Status": "published",
      "Score": 8.00,
      "TotalPoints": 10.00,
      "Percentage": 80.00,
      "SubmitTime": "2025-10-27T14:30:00.000Z",
      "AttemptID": 1
    },
    {
      "ExamID": 2,
      "ExamName": "Final Exam",
      "CategoryName": "Mathematics", // ⭐
      "CourseCode": "CS101",
      "CourseName": "Introduction to Programming",
      "TopicName": "Functions",
      "Status": "published",
      "Score": 0.00,
      "TotalPoints": 0.00,
      "Percentage": 0.00,
      "SubmitTime": null,
      "AttemptID": null
    }
  ]
}
```

**Test with curl:**
```bash
curl -X GET http://localhost:3000/student/dashboard \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

### 13. Search Exams (ค้นหาข้อสอบ) ⭐

ค้นหาข้อสอบจาก ExamName, CourseName, TopicName หรือ CategoryName

**Endpoint:**
```
GET /student/search?q=keyword
```

**Headers:**
```json
{
  "Authorization": "Bearer YOUR_TOKEN_HERE"
}
```

**Query Parameters:**
- `q` (string) - คำค้นหา

**Example:**
```
GET /student/search?q=midterm
```

**Success Response (200 OK):**
```json
{
  "exams": [
    {
      "ExamID": 1,
      "ExamName": "Midterm Exam",
      "CategoryName": "Computer Science", // ⭐
      "CourseCode": "CS101",
      "CourseName": "Introduction to Programming",
      "TopicName": "Variables and Data Types",
      "Status": "published",
      "Score": 8.00,
      "TotalPoints": 10.00,
      "Percentage": 80.00,
      "SubmitTime": "2025-10-27T14:30:00.000Z"
    }
  ]
}
```

**Test with curl:**
```bash
curl -X GET "http://localhost:3000/student/search?q=midterm" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

### 14. View Exam (ดูข้อสอบเพื่อทำ) ⭐

ดูคำถามข้อสอบ (ไม่แสดงเฉลย)

**Endpoint:**
```
GET /student/exam/:examId
```

**Headers:**
```json
{
  "Authorization": "Bearer YOUR_TOKEN_HERE"
}
```

**Example:**
```
GET /student/exam/1
```

**Success Response (200 OK):**
```json
{
  "exam": {
    "ExamID": 1,
    "ExamName": "Midterm Exam",
    "CourseID": 1,
    "TopicID": 1,
    "InstructorID": 1,
    "Status": "published",
    "CourseCode": "CS101",
    "CourseName": "Introduction to Programming",
    "TopicName": "Variables and Data Types",
    "CategoryName": "Computer Science" // ⭐
  },
  "questions": [
    {
      "QuestionID": 1,
      "QuestionText": "What is a variable?",
      "OrderIndex": 0,
      "Points": 1.00,
      "TypeCode": "MCQ",
      "TypeName": "Multiple Choice",
      "LevelCode": "EASY",
      "LevelName": "Easy",
      "choices": [
        {
          "ChoiceID": 1,
          "ChoiceNo": 1,
          "ChoiceText": "A container for data"
        },
        {
          "ChoiceID": 2,
          "ChoiceNo": 2,
          "ChoiceText": "A function"
        },
        {
          "ChoiceID": 3,
          "ChoiceNo": 3,
          "ChoiceText": "A loop"
        }
      ]
    },
    {
      "QuestionID": 2,
      "QuestionText": "Python is a programming language",
      "OrderIndex": 1,
      "Points": 1.00,
      "TypeCode": "TF",
      "TypeName": "True/False",
      "LevelCode": "EASY",
      "LevelName": "Easy",
      "choices": [
        {
          "ChoiceID": 4,
          "ChoiceNo": 1,
          "ChoiceText": "True"
        },
        {
          "ChoiceID": 5,
          "ChoiceNo": 2,
          "ChoiceText": "False"
        }
      ]
    }
  ]
}
```

**Note:** ไม่มี `IsCorrect` ในตัวเลือก เพื่อไม่ให้นิสิตเห็นเฉลย

**Error Responses:**
- `404 Not Found` - ไม่พบข้อสอบนี้หรือข้อสอบยังไม่เผยแพร่

**Test with curl:**
```bash
curl -X GET http://localhost:3000/student/exam/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

### 15. Submit Exam (ส่งคำตอบ)

ส่งคำตอบและคำนวณคะแนน

**Endpoint:**
```
POST /student/exam/:examId/submit
```

**Headers:**
```json
{
  "Authorization": "Bearer YOUR_TOKEN_HERE",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "answers": [
    {
      "questionId": 1,
      "choiceId": 1
    },
    {
      "questionId": 2,
      "choiceId": 4
    }
  ]
}
```

**Field Descriptions:**
- `answers` (array, required) - รายการคำตอบ
  - `questionId` (number, required) - ID ของคำถาม
  - `choiceId` (number, required) - ID ของตัวเลือกที่เลือก

**Success Response (200 OK):**
```json
{
  "message": "ส่งคำตอบสำเร็จ",
  "attemptId": 1,
  "score": 2.00,
  "totalPoints": 2.00,
  "percentage": 100.00
}
```

**Test with curl:**
```bash
curl -X POST http://localhost:3000/student/exam/1/submit \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "answers": [
      {"questionId": 1, "choiceId": 1},
      {"questionId": 2, "choiceId": 4}
    ]
  }'
```

---

### 16. View Result (ดูเฉลย) ⭐

ดูเฉลยพร้อมคำตอบที่ตอบไป

**Endpoint:**
```
GET /student/exam/:examId/result/:attemptId
```

**Headers:**
```json
{
  "Authorization": "Bearer YOUR_TOKEN_HERE"
}
```

**Example:**
```
GET /student/exam/1/result/1
```

**Success Response (200 OK):**
```json
{
  "exam": {
    "ExamID": 1,
    "ExamName": "Midterm Exam",
    "CourseCode": "CS101",
    "CourseName": "Introduction to Programming",
    "TopicName": "Variables and Data Types",
    "CategoryName": "Computer Science" // ⭐
  },
  "attempt": {
    "attemptId": 1,
    "score": 2.00,
    "totalPoints": 2.00,
    "percentage": 100.00,
    "submitTime": "2025-10-27T14:30:00.000Z"
  },
  "questions": [
    {
      "QuestionID": 1,
      "QuestionText": "What is a variable?",
      "Points": 1.00,
      "OrderIndex": 0,
      "TypeCode": "MCQ",
      "TypeName": "Multiple Choice",
      "LevelCode": "EASY",
      "LevelName": "Easy",
      "StudentChoiceID": 1,
      "StudentIsCorrect": 1,
      "PointsEarned": 1.00,
      "choices": [
        {
          "ChoiceID": 1,
          "ChoiceNo": 1,
          "ChoiceText": "A container for data",
          "IsCorrect": 1
        },
        {
          "ChoiceID": 2,
          "ChoiceNo": 2,
          "ChoiceText": "A function",
          "IsCorrect": 0
        },
        {
          "ChoiceID": 3,
          "ChoiceNo": 3,
          "ChoiceText": "A loop",
          "IsCorrect": 0
        }
      ]
    },
    {
      "QuestionID": 2,
      "QuestionText": "Python is a programming language",
      "Points": 1.00,
      "OrderIndex": 1,
      "TypeCode": "TF",
      "TypeName": "True/False",
      "LevelCode": "EASY",
      "LevelName": "Easy",
      "StudentChoiceID": 4,
      "StudentIsCorrect": 1,
      "PointsEarned": 1.00,
      "choices": [
        {
          "ChoiceID": 4,
          "ChoiceNo": 1,
          "ChoiceText": "True",
          "IsCorrect": 1
        },
        {
          "ChoiceID": 5,
          "ChoiceNo": 2,
          "ChoiceText": "False",
          "IsCorrect": 0
        }
      ]
    }
  ]
}
```

**Error Responses:**
- `404 Not Found` - ไม่พบผลการสอบนี้

**Test with curl:**
```bash
curl -X GET http://localhost:3000/student/exam/1/result/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

### 17. Get Profile (ดูโปรไฟล์)

ดูข้อมูลส่วนตัวของนิสิต

**Endpoint:**
```
GET /student/profile
```

**Headers:**
```json
{
  "Authorization": "Bearer YOUR_TOKEN_HERE"
}
```

**Success Response (200 OK):**
```json
{
  "user": {
    "UserID": 2,
    "Username": "student01",
    "Email": "student01@example.com",
    "Department": "Computer Science",
    "Role": "student",
    "StudentID": "6510001"
  }
}
```

**Test with curl:**
```bash
curl -X GET http://localhost:3000/student/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

### 18. Update Profile (แก้ไขโปรไฟล์)

แก้ไขข้อมูลส่วนตัว

**Endpoint:**
```
PUT /student/profile
```

**Headers:**
```json
{
  "Authorization": "Bearer YOUR_TOKEN_HERE",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "username": "student01_updated",
  "email": "newemail@example.com",
  "password": "newpassword123",
  "department": "Software Engineering",
  "studentId": "6510002"
}
```

**Note:** ส่งเฉพาะฟิลด์ที่ต้องการแก้ไข

**Success Response (200 OK):**
```json
{
  "message": "อัพเดทโปรไฟล์สำเร็จ"
}
```

**Test with curl:**
```bash
curl -X PUT http://localhost:3000/student/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{"department": "Software Engineering"}'
```

---

### 19. Delete Account (ลบบัญชี)

ลบบัญชีผู้ใช้ออกจากระบบ

**Endpoint:**
```
DELETE /student/profile
```

**Headers:**
```json
{
  "Authorization": "Bearer YOUR_TOKEN_HERE"
}
```

**Success Response (200 OK):**
```json
{
  "message": "ลบบัญชีสำเร็จ"
}
```

**Test with curl:**
```bash
curl -X DELETE http://localhost:3000/student/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## ⚠ Error Responses

### Common Error Codes

| Status Code | Description |
|-------------|-------------|
| `400` | Bad Request - ข้อมูลไม่ครบหรือไม่ถูกต้อง |
| `401` | Unauthorized - ไม่มี token หรือ token ไม่ถูกต้อง |
| `403` | Forbidden - ไม่มีสิทธิ์เข้าถึง |
| `404` | Not Found - ไม่พบข้อมูลที่ต้องการ |
| `500` | Internal Server Error - เกิดข้อผิดพลาดในเซิร์ฟเวอร์ |

### Error Response Format

```json
{
  "error": "คำอธิบาย error"
}
```

**Examples:**

**401 Unauthorized:**
```json
{
  "error": "ไม่มี token"
}
```

**403 Forbidden:**
```json
{
  "error": "ต้องเป็น instructor เท่านั้น"
}
```

**404 Not Found:**
```json
{
  "error": "ไม่พบข้อสอบนี้"
}
```

---

## 🧪 Complete Test Scenarios

### Scenario 1: Instructor สร้างและเผยแพร่ข้อสอบ

**Step 1: Register Instructor**
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "prof_smith",
    "email": "smith@university.com",
    "password": "secure123",
    "department": "Computer Science",
    "role": "instructor"
  }'
```

**Step 2: Login**
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "prof_smith",
    "password": "secure123"
  }'
```
*บันทึก token ที่ได้*

**Step 3: Create Exam**
```bash
curl -X POST http://localhost:3000/instructor/exam \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "examName": "Programming Fundamentals Quiz",
    "categoryName": "Computer Science",
    "courseCode": "CS101",
    "courseName": "Introduction to Programming",
    "topicName": "Basic Concepts",
    "status": "published",
    "questions": [
      {
        "questionText": "What does CPU stand for?",
        "typeCode": "MCQ",
        "difficulty": "EASY",
        "points": 1,
        "choices": [
          {"text": "Central Processing Unit", "isCorrect": true},
          {"text": "Computer Personal Unit", "isCorrect": false},
          {"text": "Central Program Utility", "isCorrect": false},
          {"text": "Central Processor Union", "isCorrect": false}
        ]
      },
      {
        "questionText": "RAM is a type of volatile memory",
        "typeCode": "TF",
        "difficulty": "EASY",
        "points": 1,
        "choices": [
          {"text": "True", "isCorrect": true},
          {"text": "False", "isCorrect": false}
        ]
      },
      {
        "questionText": "Which is NOT a programming language?",
        "typeCode": "MCQ",
        "difficulty": "MEDIUM",
        "points": 2,
        "choices": [
          {"text": "Python", "isCorrect": false},
          {"text": "HTML", "isCorrect": true},
          {"text": "Java", "isCorrect": false},
          {"text": "C++", "isCorrect": false}
        ]
      }
    ]
  }'
```
*บันทึก examId ที่ได้*

**Step 4: View Exam Details**
```bash
curl -X GET http://localhost:3000/instructor/exam/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Step 5: View Dashboard**
```bash
curl -X GET http://localhost:3000/instructor/dashboard \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### Scenario 2: Student ทำข้อสอบและดูเฉลย

**Step 1: Register Student**
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john@student.com",
    "password": "student123",
    "department": "Computer Science",
    "role": "student",
    "studentId": "6510001"
  }'
```

**Step 2: Login**
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "password": "student123"
  }'
```
*บันทึก token ที่ได้*

**Step 3: View Dashboard**
```bash
curl -X GET http://localhost:3000/student/dashboard \
  -H "Authorization: Bearer STUDENT_TOKEN"
```

**Step 4: View Exam (Start Exam)**
```bash
curl -X GET http://localhost:3000/student/exam/1 \
  -H "Authorization: Bearer STUDENT_TOKEN"
```

**Step 5: Submit Answers**
```bash
curl -X POST http://localhost:3000/student/exam/1/submit \
  -H "Authorization: Bearer STUDENT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "answers": [
      {"questionId": 1, "choiceId": 1},
      {"questionId": 2, "choiceId": 4},
      {"questionId": 3, "choiceId": 6}
    ]
  }'
```
*บันทึก attemptId ที่ได้*

**Step 6: View Result**
```bash
curl -X GET http://localhost:3000/student/exam/1/result/1 \
  -H "Authorization: Bearer STUDENT_TOKEN"
```

**Step 7: Try Again (Retake Exam)**
```bash
# ทำซ้ำ Step 4-6 ได้เลย
curl -X GET http://localhost:3000/student/exam/1 \
  -H "Authorization: Bearer STUDENT_TOKEN"
```

---

### Scenario 3: Search และ Update

**Instructor Search:**
```bash
curl -X GET "http://localhost:3000/instructor/search?q=programming" \
  -H "Authorization: Bearer INSTRUCTOR_TOKEN"
```

**Student Search:**
```bash
curl -X GET "http://localhost:3000/student/search?q=quiz" \
  -H "Authorization: Bearer STUDENT_TOKEN"
```

**Update Exam Status (Draft → Published):**
```bash
curl -X PUT http://localhost:3000/instructor/exam/1 \
  -H "Authorization: Bearer INSTRUCTOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "published"
  }'
```

**Update Profile:**
```bash
curl -X PUT http://localhost:3000/instructor/profile \
  -H "Authorization: Bearer INSTRUCTOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "department": "Software Engineering"
  }'
```

---

### Scenario 4: Delete Operations

**Delete Exam:**
```bash
curl -X DELETE http://localhost:3000/instructor/exam/1 \
  -H "Authorization: Bearer INSTRUCTOR_TOKEN"
```

**Delete Account:**
```bash
curl -X DELETE http://localhost:3000/student/profile \
  -H "Authorization: Bearer STUDENT_TOKEN"
```

---

## 📊 Data Models

### User
```json
{
  "UserID": 1,
  "Username": "string",
  "Email": "string",
  "Password": "hashed_string",
  "Department": "string",
  "Role": "instructor | student",
  "StudentID": "string | null",
  "CreatedAt": "timestamp",
  "UpdatedAt": "timestamp"
}
```

### Exam
```json
{
  "ExamID": 1,
  "ExamName": "string",
  "CourseID": 1,
  "TopicID": 1,
  "InstructorID": 1,
  "Status": "draft | published",
  "CreatedAt": "timestamp",
  "UpdatedAt": "timestamp"
}
```

### Question
```json
{
  "QuestionID": 1,
  "ExamID": 1,
  "TopicID": 1,
  "TypeID": 1,
  "DifficultyID": 1,
  "InstructorID": 1,
  "QuestionText": "string",
  "ShuffleChoices": true,
  "Points": 1.00,
  "OrderIndex": 0,
  "CreatedAt": "timestamp"
}
```

### Choice
```json
{
  "ChoiceID": 1,
  "QuestionID": 1,
  "ChoiceNo": 1,
  "ChoiceText": "string",
  "IsCorrect": true
}
```

### ExamAttempt
```json
{
  "AttemptID": 1,
  "ExamID": 1,
  "StudentID": 1,
  "Status": "in_progress | submitted",
  "Score": 8.00,
  "TotalPoints": 10.00,
  "Percentage": 80.00,
  "SubmitTime": "timestamp",
  "CreatedAt": "timestamp"
}
```

---

## 🎯 Testing Tips

### Using Postman

1. **Create Environment Variables:**
   - `base_url`: `http://localhost:3000`
   - `instructor_token`: (paste after login)
   - `student_token`: (paste after login)

2. **Use Variables in Requests:**
   - URL: `{{base_url}}/auth/login`
   - Header: `Authorization: Bearer {{instructor_token}}`

3. **Save Responses Automatically:**
   ```javascript
   // In Postman Tests tab
   var jsonData = pm.response.json();
   pm.environment.set("instructor_token", jsonData.token);
   ```

### Using Thunder Client (VS Code)

1. Install "Thunder Client" extension
2. Create new environment
3. Add variables like Postman
4. Use `{{variable}}` syntax in requests

### Quick Test Script (save as `test_api.sh`)

```bash
#!/bin/bash

BASE_URL="http://localhost:3000"

echo "Testing Exam Bank API..."

# 1. Register Instructor
echo -e "\n1. Registering Instructor..."
INSTRUCTOR_RESPONSE=$(curl -s -X POST $BASE_URL/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "test_teacher",
    "email": "teacher@test.com",
    "password": "test123",
    "department": "CS",
    "role": "instructor"
  }')
echo $INSTRUCTOR_RESPONSE

# 2. Login Instructor
echo -e "\n2. Login Instructor..."
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "test_teacher",
    "password": "test123"
  }')
echo $LOGIN_RESPONSE

INSTRUCTOR_TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
echo "Token: $INSTRUCTOR_TOKEN"

# 3. Create Exam
echo -e "\n3. Creating Exam..."
EXAM_RESPONSE=$(curl -s -X POST $BASE_URL/instructor/exam \
  -H "Authorization: Bearer $INSTRUCTOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "examName": "Test Exam",
    "categoryName": "Computer Science",
    "courseCode": "TEST101",
    "courseName": "Testing Course",
    "topicName": "Testing Topic",
    "status": "published",
    "questions": [
      {
        "questionText": "Test Question?",
        "typeCode": "TF",
        "difficulty": "EASY",
        "points": 1,
        "choices": [
          {"text": "True", "isCorrect": true},
          {"text": "False", "isCorrect": false}
        ]
      }
    ]
  }')
echo $EXAM_RESPONSE

echo -e "\n✅ Test completed!"
```

**Run on Mac/Linux:**
```bash
chmod +x test_api.sh
./test_api.sh
```

---

## 🔒 Security Notes

1. **Token Expiration:** JWT tokens expire after 24 hours
2. **Password Storage:** Passwords are hashed with bcrypt (10 rounds)
3. **CORS:** Currently allows all origins (production should restrict)
4. **Rate Limiting:** Not implemented (should add in production)
5. **Input Validation:** Basic validation implemented (should enhance)

---

## 📞 Support

สำหรับคำถามหรือปัญหา:
- ตรวจสอบ error response และ status code
- ดู console log ของ server
- ตรวจสอบว่า token ถูกต้องและยังไม่หมดอายุ
- ตรวจสอบว่า role ตรงกับ endpoint ที่เรียกใช้

---

## 📝 Changelog

### Version 1.1.0 (2025-10-30) ⭐ CURRENT

**Added:**
- เพิ่ม `CategoryName` field ใน response ของทุก endpoint ที่แสดงข้อมูลข้อสอบ
- เพิ่มการค้นหาด้วย `CategoryName` ใน search endpoints
- เพิ่ม `CategoryID` ใน instructor exam detail endpoint
- เพิ่มการรองรับ `categoryName` ใน POST /instructor/exam
- เพิ่มการรองรับ `categoryName` ใน PUT /instructor/exam/:examId

**Updated Endpoints:**
- ⭐ GET /instructor/dashboard
- ⭐ GET /instructor/search
- ⭐ GET /instructor/exam/:examId
- ⭐ POST /instructor/exam
- ⭐ PUT /instructor/exam/:examId
- ⭐ GET /student/dashboard
- ⭐ GET /student/search
- ⭐ GET /student/exam/:examId
- ⭐ GET /student/exam/:examId/result/:attemptId

---

### Version 1.0.0 (2025-10-27)
- Initial release
- Auth endpoints (Register, Login)
- Instructor endpoints (Dashboard, Create/Update/Delete Exam, Profile)
- Student endpoints (Dashboard, Take Exam, Submit, View Result, Profile)
- Search functionality for both roles

---

**End of Documentation** 🎉