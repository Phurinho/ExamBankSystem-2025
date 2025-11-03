-- ================================================================
-- Online Exam Bank Database Schema (V3 - lowercase table names only)
-- Author: Thepthat Boonbumrung
-- Date: 2025-10-30
-- ================================================================

CREATE DATABASE IF NOT EXISTS exam_bank
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE exam_bank;

-- ----------------------------------------------------------------
-- Cleanup existing objects
-- ----------------------------------------------------------------
DROP VIEW IF EXISTS vw_student_exam_list;
DROP VIEW IF EXISTS vw_instructor_exam_list;
DROP PROCEDURE IF EXISTS sp_calculate_exam_score;

SET @old_fk_check = @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS studentanswers;
DROP TABLE IF EXISTS examattempts;
DROP TABLE IF EXISTS choices;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS exams;
DROP TABLE IF EXISTS topics;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS subjectcategories;
DROP TABLE IF EXISTS difficultylevels;
DROP TABLE IF EXISTS questiontypes;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = @old_fk_check;

-- ----------------------------------------------------------------
-- 1. users
-- ----------------------------------------------------------------
CREATE TABLE users (
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
-- 1.5 subjectcategories
-- ----------------------------------------------------------------
CREATE TABLE subjectcategories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------
-- 2. courses
-- ----------------------------------------------------------------
CREATE TABLE courses (
  CourseID INT PRIMARY KEY AUTO_INCREMENT,
  CourseCode VARCHAR(50) NOT NULL UNIQUE,
  CourseName VARCHAR(255) NOT NULL,
  CategoryID INT NULL,
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (CategoryID) REFERENCES subjectcategories(CategoryID)
    ON DELETE SET NULL
) ENGINE=InnoDB;

-- ----------------------------------------------------------------
-- 3. topics
-- ----------------------------------------------------------------
CREATE TABLE topics (
  TopicID INT PRIMARY KEY AUTO_INCREMENT,
  CourseID INT NOT NULL,
  TopicName VARCHAR(255) NOT NULL,
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (CourseID) REFERENCES courses(CourseID)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------
-- 4. difficultylevels
-- ----------------------------------------------------------------
CREATE TABLE difficultylevels (
  DifficultyID INT PRIMARY KEY AUTO_INCREMENT,
  LevelCode ENUM('EASY', 'MEDIUM', 'HARD') NOT NULL,
  LevelName VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

INSERT INTO difficultylevels (LevelCode, LevelName)
VALUES ('EASY','Easy'),('MEDIUM','Medium'),('HARD','Hard');

-- ----------------------------------------------------------------
-- 5. questiontypes
-- ----------------------------------------------------------------
CREATE TABLE questiontypes (
  TypeID INT PRIMARY KEY AUTO_INCREMENT,
  TypeCode ENUM('MCQ','TF') NOT NULL,
  TypeName VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

INSERT INTO questiontypes (TypeCode, TypeName)
VALUES ('MCQ','Multiple Choice'),('TF','True/False');

-- ----------------------------------------------------------------
-- 6. exams
-- ----------------------------------------------------------------
CREATE TABLE exams (
  ExamID INT PRIMARY KEY AUTO_INCREMENT,
  ExamName VARCHAR(255) NOT NULL,
  CourseID INT NOT NULL,
  TopicID INT NOT NULL,
  InstructorID INT NOT NULL,
  Status ENUM('draft','published') DEFAULT 'draft',
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (CourseID) REFERENCES courses(CourseID)
    ON DELETE CASCADE,
  FOREIGN KEY (TopicID) REFERENCES topics(TopicID)
    ON DELETE CASCADE,
  FOREIGN KEY (InstructorID) REFERENCES users(UserID)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------
-- 7. questions
-- ----------------------------------------------------------------
CREATE TABLE questions (
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
  FOREIGN KEY (ExamID) REFERENCES exams(ExamID)
    ON DELETE CASCADE,
  FOREIGN KEY (TopicID) REFERENCES topics(TopicID),
  FOREIGN KEY (TypeID) REFERENCES questiontypes(TypeID),
  FOREIGN KEY (DifficultyID) REFERENCES difficultylevels(DifficultyID),
  FOREIGN KEY (InstructorID) REFERENCES users(UserID)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------
-- 8. choices
-- ----------------------------------------------------------------
CREATE TABLE choices (
  ChoiceID INT PRIMARY KEY AUTO_INCREMENT,
  QuestionID INT NOT NULL,
  ChoiceNo INT NOT NULL,
  ChoiceText VARCHAR(500) NOT NULL,
  IsCorrect BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (QuestionID) REFERENCES questions(QuestionID)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------
-- 9. examattempts
-- ----------------------------------------------------------------
CREATE TABLE examattempts (
  AttemptID INT PRIMARY KEY AUTO_INCREMENT,
  ExamID INT NOT NULL,
  StudentID INT NOT NULL,
  Status ENUM('in_progress','submitted') DEFAULT 'in_progress',
  Score DECIMAL(6,2) DEFAULT 0,
  TotalPoints DECIMAL(6,2) DEFAULT 0,
  Percentage DECIMAL(5,2) DEFAULT 0,
  SubmitTime DATETIME NULL,
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (ExamID) REFERENCES exams(ExamID)
    ON DELETE CASCADE,
  FOREIGN KEY (StudentID) REFERENCES users(UserID)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------
-- 10. studentanswers
-- ----------------------------------------------------------------
CREATE TABLE studentanswers (
  AnswerID INT PRIMARY KEY AUTO_INCREMENT,
  AttemptID INT NOT NULL,
  QuestionID INT NOT NULL,
  ChoiceID INT NULL,
  AnswerText TEXT NULL,
  IsCorrect BOOLEAN DEFAULT FALSE,
  PointsEarned DECIMAL(5,2) DEFAULT 0,
  FOREIGN KEY (AttemptID) REFERENCES examattempts(AttemptID)
    ON DELETE CASCADE,
  FOREIGN KEY (QuestionID) REFERENCES questions(QuestionID)
    ON DELETE CASCADE,
  FOREIGN KEY (ChoiceID) REFERENCES choices(ChoiceID)
    ON DELETE SET NULL
) ENGINE=InnoDB;

-- ----------------------------------------------------------------
-- 11. Views
-- ----------------------------------------------------------------
CREATE OR REPLACE VIEW vw_instructor_exam_list AS
SELECT
  e.ExamID,
  e.ExamName,
  sc.CategoryName,
  c.CourseCode,
  c.CourseName,
  t.TopicName,
  e.Status,
  e.UpdatedAt,
  u.Username AS InstructorName
FROM exams e
JOIN courses c ON e.CourseID = c.CourseID
JOIN topics t ON e.TopicID = t.TopicID
JOIN users u ON e.InstructorID = u.UserID
LEFT JOIN subjectcategories sc ON c.CategoryID = sc.CategoryID;

CREATE OR REPLACE VIEW vw_student_exam_list AS
SELECT
  e.ExamID,
  e.ExamName,
  sc.CategoryName,
  c.CourseCode,
  c.CourseName,
  t.TopicName,
  e.Status,
  ea.StudentID,
  COALESCE(ea.Score, 0) AS Score,
  COALESCE(ea.TotalPoints, 0) AS TotalPoints,
  CASE WHEN ea.TotalPoints > 0 THEN ROUND(ea.Score * 100 / ea.TotalPoints, 2) ELSE 0 END AS Percentage
FROM exams e
JOIN courses c ON e.CourseID = c.CourseID
JOIN topics t ON e.TopicID = t.TopicID
LEFT JOIN examattempts ea ON ea.ExamID = e.ExamID
LEFT JOIN subjectcategories sc ON c.CategoryID = sc.CategoryID;

-- ----------------------------------------------------------------
-- 12. Procedure
-- ----------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE sp_calculate_exam_score(IN inAttemptID INT)
BEGIN
  DECLARE v_examId INT;
  DECLARE v_total DECIMAL(6,2);
  DECLARE v_score DECIMAL(6,2);
  DECLARE v_pct DECIMAL(5,2);

  SELECT ExamID INTO v_examId FROM examattempts WHERE AttemptID = inAttemptID;

  SELECT SUM(q.Points) INTO v_total
  FROM questions q
  WHERE q.ExamID = v_examId;

  SELECT SUM(sa.PointsEarned) INTO v_score
  FROM studentanswers sa
  WHERE sa.AttemptID = inAttemptID;

  SET v_total = COALESCE(v_total, 0);
  SET v_score = COALESCE(v_score, 0);
  SET v_pct = IF(v_total > 0, ROUND(v_score * 100 / v_total, 2), 0);

  UPDATE examattempts
  SET Score = v_score,
      TotalPoints = v_total,
      Percentage = v_pct,
      Status = 'submitted',
      SubmitTime = NOW()
  WHERE AttemptID = inAttemptID;

END$$

DELIMITER ;

-- ----------------------------------------------------------------
-- DONE
-- ----------------------------------------------------------------
