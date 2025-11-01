-- ================================================================
-- Online Exam Bank Database Schema (V3 - Categories Minimal Change)
-- Author: Thepthat Boonbumrung
-- Date: 2025-10-30
-- Description:
--   เพิ่มตาราง SubjectCategories และเชื่อมโยงกับ Courses (แก้ไขน้อยที่สุด)
--   แก้ไข FK ที่ขาดหายไปในตาราง Questions
--   คง INSERT lookup และ admin example ไว้ตามเดิม
-- ================================================================

-- ----------------------------------------------------------------
-- 0. Database
-- ----------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS exam_bank
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE exam_bank;
-- ----------------------------------------------------------------
-- A. Cleanup existing objects (views/procedures/tables) safely
-- ----------------------------------------------------------------
-- Drop views first (they depend on tables)
DROP VIEW IF EXISTS vw_student_exam_list;
DROP VIEW IF EXISTS vw_instructor_exam_list;

-- Drop procedures/functions next
DROP PROCEDURE IF EXISTS sp_calculate_exam_score;

-- Disable FK checks to drop in any order without dependency errors
SET @old_fk_check = @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS StudentAnswers;
DROP TABLE IF EXISTS ExamAttempts;
DROP TABLE IF EXISTS Choices;
DROP TABLE IF EXISTS Questions;
DROP TABLE IF EXISTS Exams;
DROP TABLE IF EXISTS Topics;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS SubjectCategories;
DROP TABLE IF EXISTS DifficultyLevels;
DROP TABLE IF EXISTS QuestionTypes;
DROP TABLE IF EXISTS Users;

-- Restore FK checks
SET FOREIGN_KEY_CHECKS = @old_fk_check;


-- ----------------------------------------------------------------
-- 1. Users
-- ----------------------------------------------------------------
CREATE TABLE Users (
  UserID INT PRIMARY KEY AUTO_INCREMENT,
  Username VARCHAR(50) NOT NULL UNIQUE,
  Email VARCHAR(100) NOT NULL UNIQUE,
  Password VARCHAR(255) NOT NULL,
  Department VARCHAR(100),
  Role ENUM('instructor', 'student') NOT NULL,
  StudentID VARCHAR(20) NULL,
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_role (Role),
  INDEX idx_email (Email),
  CHECK (Role = 'instructor' OR (Role = 'student' AND StudentID IS NOT NULL))
) ENGINE=InnoDB;

-- ----------------------------------------------------------------
-- 1.5 Subject Categories (NEW TABLE - ADDED)
-- ----------------------------------------------------------------
CREATE TABLE SubjectCategories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------
-- 2. Courses (MODIFIED TABLE - ADDED CategoryID)
-- ----------------------------------------------------------------
CREATE TABLE Courses (
  CourseID INT PRIMARY KEY AUTO_INCREMENT,
  CourseCode VARCHAR(50) NOT NULL UNIQUE,
  CourseName VARCHAR(255) NOT NULL,
  CategoryID INT NULL, -- NEW COLUMN
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (CategoryID) REFERENCES SubjectCategories(CategoryID) -- NEW FK
    ON DELETE SET NULL
) ENGINE=InnoDB;

-- ----------------------------------------------------------------
-- 3. Topics
-- ----------------------------------------------------------------
CREATE TABLE Topics (
  TopicID INT PRIMARY KEY AUTO_INCREMENT,
  CourseID INT NOT NULL,
  TopicName VARCHAR(255) NOT NULL,
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------
-- 4. Difficulty Levels (UNCHANGED from original)
-- ----------------------------------------------------------------
CREATE TABLE DifficultyLevels (
  DifficultyID INT PRIMARY KEY AUTO_INCREMENT,
  LevelCode ENUM('EASY', 'MEDIUM', 'HARD') NOT NULL,
  LevelName VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

INSERT INTO DifficultyLevels (LevelCode, LevelName)
VALUES ('EASY','Easy'),('MEDIUM','Medium'),('HARD','Hard');

-- ----------------------------------------------------------------
-- 5. Question Types (UNCHANGED from original)
-- ----------------------------------------------------------------
CREATE TABLE QuestionTypes (
  TypeID INT PRIMARY KEY AUTO_INCREMENT,
  TypeCode ENUM('MCQ','TF') NOT NULL,
  TypeName VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

INSERT INTO QuestionTypes (TypeCode, TypeName)
VALUES ('MCQ','Multiple Choice'),('TF','True/False');

-- ----------------------------------------------------------------
-- 6. Exams
-- ----------------------------------------------------------------
CREATE TABLE Exams (
  ExamID INT PRIMARY KEY AUTO_INCREMENT,
  ExamName VARCHAR(255) NOT NULL,
  CourseID INT NOT NULL,
  TopicID INT NOT NULL,
  InstructorID INT NOT NULL,
  Status ENUM('draft','published') DEFAULT 'draft',
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
    ON DELETE CASCADE,
  FOREIGN KEY (TopicID) REFERENCES Topics(TopicID)
    ON DELETE CASCADE,
  FOREIGN KEY (InstructorID) REFERENCES Users(UserID)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------
-- 7. Questions (MODIFIED - Added missing TopicID FK)
-- ----------------------------------------------------------------
CREATE TABLE Questions (
  QuestionID INT PRIMARY KEY AUTO_INCREMENT,
  ExamID INT NOT NULL,
  TopicID INT NOT NULL,
  TypeID INT NOT NULL,
  DifficultyID INT NOT NULL,
  InstructorID INT NOT NULL,
  QuestionText TEXT NOT NULL,
  ShuffleChoices BOOLEAN DEFAULT TRUE,
  Points DECIMAL(5,2) DEFAULT 1.0,
  OrderIndex INT DEFAULT 0,
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (ExamID) REFERENCES Exams(ExamID)
    ON DELETE CASCADE,
  FOREIGN KEY (TopicID) REFERENCES Topics(TopicID), -- FK for TopicID ADDED
  FOREIGN KEY (TypeID) REFERENCES QuestionTypes(TypeID),
  FOREIGN KEY (DifficultyID) REFERENCES DifficultyLevels(DifficultyID),
  FOREIGN KEY (InstructorID) REFERENCES Users(UserID)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------
-- 8. Choices
-- ----------------------------------------------------------------
CREATE TABLE Choices (
  ChoiceID INT PRIMARY KEY AUTO_INCREMENT,
  QuestionID INT NOT NULL,
  ChoiceNo INT NOT NULL,
  ChoiceText VARCHAR(500) NOT NULL,
  IsCorrect BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (QuestionID) REFERENCES Questions(QuestionID)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------
-- 9. ExamAttempts
-- ----------------------------------------------------------------
CREATE TABLE ExamAttempts (
  AttemptID INT PRIMARY KEY AUTO_INCREMENT,
  ExamID INT NOT NULL,
  StudentID INT NOT NULL,
  Status ENUM('in_progress','submitted') DEFAULT 'in_progress',
  Score DECIMAL(6,2) DEFAULT 0,
  TotalPoints DECIMAL(6,2) DEFAULT 0,
  Percentage DECIMAL(5,2) DEFAULT 0,
  SubmitTime DATETIME NULL,
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (ExamID) REFERENCES Exams(ExamID)
    ON DELETE CASCADE,
  FOREIGN KEY (StudentID) REFERENCES Users(UserID)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------
-- 10. Student Answers
-- ----------------------------------------------------------------
CREATE TABLE StudentAnswers (
  AnswerID INT PRIMARY KEY AUTO_INCREMENT,
  AttemptID INT NOT NULL,
  QuestionID INT NOT NULL,
  ChoiceID INT NULL,
  AnswerText TEXT NULL,
  IsCorrect BOOLEAN DEFAULT FALSE,
  PointsEarned DECIMAL(5,2) DEFAULT 0,
  FOREIGN KEY (AttemptID) REFERENCES ExamAttempts(AttemptID)
    ON DELETE CASCADE,
  FOREIGN KEY (QuestionID) REFERENCES Questions(QuestionID)
    ON DELETE CASCADE,
  FOREIGN KEY (ChoiceID) REFERENCES Choices(ChoiceID)
    ON DELETE SET NULL
) ENGINE=InnoDB;

-- ----------------------------------------------------------------
-- 11. View: Instructor Exam List (UPDATED VIEW - Added CategoryName)
-- ----------------------------------------------------------------
CREATE OR REPLACE VIEW vw_instructor_exam_list AS
SELECT
  e.ExamID,
  e.ExamName,
  sc.CategoryName, -- ADDED Category Name
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
LEFT JOIN SubjectCategories sc ON c.CategoryID = sc.CategoryID; -- ADDED JOIN

-- ----------------------------------------------------------------
-- 12. View: Student Exam Dashboard (UPDATED VIEW - Added CategoryName)
-- ----------------------------------------------------------------
CREATE OR REPLACE VIEW vw_student_exam_list AS
SELECT
  e.ExamID,
  e.ExamName,
  sc.CategoryName, -- ADDED Category Name
  c.CourseCode,
  c.CourseName,
  t.TopicName,
  e.Status,
  ea.StudentID,
  COALESCE(ea.Score, 0) AS Score,
  COALESCE(ea.TotalPoints, 0) AS TotalPoints,
  CASE WHEN ea.TotalPoints > 0 THEN ROUND(ea.Score * 100 / ea.TotalPoints, 2) ELSE 0 END AS Percentage
FROM Exams e
JOIN Courses c ON e.CourseID = c.CourseID
JOIN Topics t ON e.TopicID = t.TopicID
LEFT JOIN ExamAttempts ea ON ea.ExamID = e.ExamID
LEFT JOIN SubjectCategories sc ON c.CategoryID = sc.CategoryID; -- ADDED JOIN

-- ----------------------------------------------------------------
-- 13. Procedure: Calculate Score
-- ----------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE sp_calculate_exam_score(IN inAttemptID INT)
BEGIN
  DECLARE v_examId INT;
  DECLARE v_total DECIMAL(6,2);
  DECLARE v_score DECIMAL(6,2);
  DECLARE v_pct DECIMAL(5,2);

  SELECT ExamID INTO v_examId FROM ExamAttempts WHERE AttemptID = inAttemptID;

  -- Calculate total points possible for the exam
  SELECT SUM(q.Points) INTO v_total
  FROM Questions q
  WHERE q.ExamID = v_examId;

  -- Calculate earned points for the attempt
  SELECT SUM(sa.PointsEarned) INTO v_score
  FROM StudentAnswers sa
  WHERE sa.AttemptID = inAttemptID;

  -- Handle cases where total might be zero or score is null
  SET v_total = COALESCE(v_total, 0);
  SET v_score = COALESCE(v_score, 0);
  SET v_pct = IF(v_total > 0, ROUND(v_score * 100 / v_total, 2), 0);

  -- Update the attempt record
  UPDATE ExamAttempts
  SET Score = v_score,
      TotalPoints = v_total,
      Percentage = v_pct,
      Status = 'submitted',
      SubmitTime = NOW()
  WHERE AttemptID = inAttemptID;

END$$

DELIMITER ;

-- ----------------------------------------------------------------
-- 14. Default Admin / Instructor Example (UNCHANGED from original)
-- ----------------------------------------------------------------



-- ----------------------------------------------------------------
-- DONE
-- ----------------------------------------------------------------