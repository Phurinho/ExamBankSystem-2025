
-- ================================================================
-- init_200.sql - Seed data (~200 rows) for Online Exam Bank
-- Compatible with schema.sql provided earlier (InnoDB, FK on)
-- Notes:
--   - Uses explicit IDs to keep FK consistent.
--   - All Questions are MCQ with 4 choices each for simplicity.
--   - Points = 1 per question; each exam has 4 questions.
--   - Attempts/Answers kept small but enough to demo features.
-- ================================================================

USE exam_bank;

SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------
-- Users (20): 10 instructors (1-10), 10 students (11-20)
-- Password is placeholder hash-like string (store real hash in prod)
-- -------------------------------
DELETE FROM Users;
INSERT INTO Users (UserID, Username, Email, Password, Department, Role, StudentID, CreatedAt, UpdatedAt) VALUES
(1,'instructor01','ins01@example.com','$2b$10$dummyhash01','CE','instructor',NULL,NOW(),NOW()),
(2,'instructor02','ins02@example.com','$2b$10$dummyhash02','CE','instructor',NULL,NOW(),NOW()),
(3,'instructor03','ins03@example.com','$2b$10$dummyhash03','CS','instructor',NULL,NOW(),NOW()),
(4,'instructor04','ins04@example.com','$2b$10$dummyhash04','CS','instructor',NULL,NOW(),NOW()),
(5,'instructor05','ins05@example.com','$2b$10$dummyhash05','IT','instructor',NULL,NOW(),NOW()),
(6,'instructor06','ins06@example.com','$2b$10$dummyhash06','IT','instructor',NULL,NOW(),NOW()),
(7,'instructor07','ins07@example.com','$2b$10$dummyhash07','Math','instructor',NULL,NOW(),NOW()),
(8,'instructor08','ins08@example.com','$2b$10$dummyhash08','Math','instructor',NULL,NOW(),NOW()),
(9,'instructor09','ins09@example.com','$2b$10$dummyhash09','EE','instructor',NULL,NOW(),NOW()),
(10,'instructor10','ins10@example.com','$2b$10$dummyhash10','EE','instructor',NULL,NOW(),NOW()),
(11,'student01','stu01@example.com','$2b$10$dummyhash11','CE','student','66000001',NOW(),NOW()),
(12,'student02','stu02@example.com','$2b$10$dummyhash12','CE','student','66000002',NOW(),NOW()),
(13,'student03','stu03@example.com','$2b$10$dummyhash13','CS','student','66000003',NOW(),NOW()),
(14,'student04','stu04@example.com','$2b$10$dummyhash14','CS','student','66000004',NOW(),NOW()),
(15,'student05','stu05@example.com','$2b$10$dummyhash15','IT','student','66000005',NOW(),NOW()),
(16,'student06','stu06@example.com','$2b$10$dummyhash16','IT','student','66000006',NOW(),NOW()),
(17,'student07','stu07@example.com','$2b$10$dummyhash17','Math','student','66000007',NOW(),NOW()),
(18,'student08','stu08@example.com','$2b$10$dummyhash18','Math','student','66000008',NOW(),NOW()),
(19,'student09','stu09@example.com','$2b$10$dummyhash19','EE','student','66000009',NOW(),NOW()),
(20,'student10','stu10@example.com','$2b$10$dummyhash20','EE','student','66000010',NOW(),NOW());

-- -------------------------------
-- Courses (6)
-- -------------------------------
DELETE FROM Courses;
INSERT INTO Courses (CourseID, CourseCode, CourseName, CreatedAt) VALUES
(1,'CS101','Intro to Programming',NOW()),
(2,'CS201','Data Structures',NOW()),
(3,'CS301','Algorithms',NOW()),
(4,'EE101','Circuits I',NOW()),
(5,'MATH201','Discrete Math',NOW()),
(6,'IT105','Web Development',NOW());

-- -------------------------------
-- Topics (12) - 2 topics per course
-- -------------------------------
DELETE FROM Topics;
INSERT INTO Topics (TopicID, CourseID, TopicName, CreatedAt) VALUES
(1,1,'Variables & Types',NOW()),
(2,1,'Control Flow',NOW()),
(3,2,'Arrays & Linked Lists',NOW()),
(4,2,'Trees & Graphs',NOW()),
(5,3,'Greedy & Divide-Conquer',NOW()),
(6,3,'Dynamic Programming',NOW()),
(7,4,'Ohm’s Law',NOW()),
(8,4,'AC Analysis',NOW()),
(9,5,'Logic & Proof',NOW()),
(10,5,'Combinatorics',NOW()),
(11,6,'HTML/CSS Basics',NOW()),
(12,6,'REST APIs',NOW());

-- -------------------------------
-- Exams (5) - belong to topics above, by instructors 1..5
-- -------------------------------
DELETE FROM Exams;
INSERT INTO Exams (ExamID, ExamName, CourseID, TopicID, InstructorID, Status, CreatedAt, UpdatedAt) VALUES
(1,'CS101 Mid A',1,1,1,'published',NOW(),NOW()),
(2,'CS201 Quiz 1',2,3,2,'published',NOW(),NOW()),
(3,'CS301 DP Drill',3,6,3,'published',NOW(),NOW()),
(4,'EE101 Basics',4,7,4,'draft',NOW(),NOW()),
(5,'WebDev Intro',6,11,5,'published',NOW(),NOW());

-- -------------------------------
-- Questions (20) - 4 per exam, all MCQ (TypeID=1), difficulty rotate 1..3
-- Points=1, ShuffleChoices=1
-- -------------------------------
DELETE FROM Questions;
INSERT INTO Questions
(QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
-- Exam 1 (q1..q4)
(1,1,1,1,1,1,'What is the size of int in most 64-bit compilers?',1,1,1,NOW()),
(2,1,1,1,2,1,'Which keyword declares a constant in C?',1,1,2,NOW()),
(3,1,1,1,3,1,'Which is not a primitive type in C?',1,1,3,NOW()),
(4,1,1,1,1,1,'Which symbol starts a single-line comment in C++?',1,1,4,NOW()),
-- Exam 2 (q5..q8)
(5,2,3,1,2,2,'Big-O for binary search?',1,1,1,NOW()),
(6,2,3,1,3,2,'Which DS fits FIFO?',1,1,2,NOW()),
(7,2,3,1,1,2,'Edge count of tree with N nodes?',1,1,3,NOW()),
(8,2,3,1,2,2,'Which is stable sorting?',1,1,4,NOW()),
-- Exam 3 (q9..q12)
(9,3,6,1,3,3,'DP stands for?',1,1,1,NOW()),
(10,3,6,1,1,3,'Knapsack 0/1 typical approach?',1,1,2,NOW()),
(11,3,6,1,2,3,'LCS problem complexity?',1,1,3,NOW()),
(12,3,6,1,3,3,'Memoization stores what?',1,1,4,NOW()),
-- Exam 4 (q13..q16)
(13,4,7,1,1,4,'Unit of resistance?',1,1,1,NOW()),
(14,4,7,1,2,4,'Series resistors total equals?',1,1,2,NOW()),
(15,4,7,1,3,4,'AC stands for?',1,1,3,NOW()),
(16,4,7,1,1,4,'Which tool is for oscilloscope?',1,1,4,NOW()),
-- Exam 5 (q17..q20)
(17,5,11,1,2,5,'HTML stands for?',1,1,1,NOW()),
(18,5,11,1,3,5,'Which tag for hyperlink?',1,1,2,NOW()),
(19,5,11,1,1,5,'CSS stands for?',1,1,3,NOW()),
(20,5,11,1,2,5,'HTTP method to update resource?',1,1,4,NOW());

-- -------------------------------
-- Choices (80) - 4 per question, ChoiceNo 1..4; mark ChoiceNo=1 correct
-- -------------------------------
DELETE FROM Choices;
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
-- q1
(1,1,1,'4 bytes',1),(2,1,2,'2 bytes',0),(3,1,3,'8 bytes on all compilers',0),(4,1,4,'platform-independent',0),
-- q2
(5,2,1,'const',1),(6,2,2,'let',0),(7,2,3,'final',0),(8,2,4,'static',0),
-- q3
(9,3,1,'string',1),(10,3,2,'int',0),(11,3,3,'char',0),(12,3,4,'float',0),
-- q4
(13,4,1,'//',1),(14,4,2,'/*',0),(15,4,3,'#',0),(16,4,4,'--',0),
-- q5
(17,5,1,'O(log n)',1),(18,5,2,'O(n)',0),(19,5,3,'O(n log n)',0),(20,5,4,'O(1)',0),
-- q6
(21,6,1,'Queue',1),(22,6,2,'Stack',0),(23,6,3,'Deque',0),(24,6,4,'Tree',0),
-- q7
(25,7,1,'N-1',1),(26,7,2,'N',0),(27,7,3,'N+1',0),(28,7,4,'2N',0),
-- q8
(29,8,1,'Merge sort',1),(30,8,2,'Quick sort',0),(31,8,3,'Heap sort',0),(32,8,4,'Selection sort',0),
-- q9
(33,9,1,'Dynamic Programming',1),(34,9,2,'Dual Processing',0),(35,9,3,'Direct Parsing',0),(36,9,4,'Data Partitioning',0),
-- q10
(37,10,1,'DP / Memoization',1),(38,10,2,'Greedy only',0),(39,10,3,'Backtracking only',0),(40,10,4,'Randomized',0),
-- q11
(41,11,1,'O(n*m)',1),(42,11,2,'O(n+m)',0),(43,11,3,'O(1)',0),(44,11,4,'O(n^3)',0),
-- q12
(45,12,1,'Subproblem results',1),(46,12,2,'Random seeds',0),(47,12,3,'Stack frames',0),(48,12,4,'Logs',0),
-- q13
(49,13,1,'Ohm',1),(50,13,2,'Volt',0),(51,13,3,'Ampere',0),(52,13,4,'Watt',0),
-- q14
(53,14,1,'Sum of all resistances',1),(54,14,2,'Product of all resistances',0),(55,14,3,'Max of resistances',0),(56,14,4,'Min of resistances',0),
-- q15
(57,15,1,'Alternating Current',1),(58,15,2,'Analog Circuit',0),(59,15,3,'Active Current',0),(60,15,4,'AC/DC band',0),
-- q16
(61,16,1,'Probe',1),(62,16,2,'Soldering iron',0),(63,16,3,'Multimeter leads',0),(64,16,4,'Breadboard',0),
-- q17
(65,17,1,'HyperText Markup Language',1),(66,17,2,'HighText Markup Language',0),(67,17,3,'Hyperlink Text Markup Language',0),(68,17,4,'Home Tool Markup Language',0),
-- q18
(69,18,1,'<a>',1),(70,18,2,'<link>',0),(71,18,3,'<h1>',0),(72,18,4,'<div>',0),
-- q19
(73,19,1,'Cascading Style Sheets',1),(74,19,2,'Creative Style Syntax',0),(75,19,3,'Cascade Styling Sheet',0),(76,19,4,'Custom Style System',0),
-- q20
(77,20,1,'PUT',1),(78,20,2,'GET',0),(79,20,3,'POST',0),(80,20,4,'PATCH',0);

-- -------------------------------
-- ExamAttempts (15) for students 11..20 across published exams (1,2,3,5)
-- Each exam total points = 4
-- -------------------------------
DELETE FROM ExamAttempts;
INSERT INTO ExamAttempts (AttemptID, ExamID, StudentID, Status, Score, TotalPoints, Percentage, SubmitTime, CreatedAt) VALUES
(1,1,11,'submitted',3,4,75.00,'2025-10-01 09:10:00',NOW()),
(2,1,12,'submitted',4,4,100.00,'2025-10-01 09:12:00',NOW()),
(3,1,13,'submitted',2,4,50.00,'2025-10-01 09:15:00',NOW()),
(4,2,14,'submitted',3,4,75.00,'2025-10-02 10:20:00',NOW()),
(5,2,15,'submitted',1,4,25.00,'2025-10-02 10:30:00',NOW()),
(6,2,16,'submitted',4,4,100.00,'2025-10-02 10:35:00',NOW()),
(7,3,17,'submitted',2,4,50.00,'2025-10-03 11:05:00',NOW()),
(8,3,18,'submitted',3,4,75.00,'2025-10-03 11:08:00',NOW()),
(9,3,19,'submitted',4,4,100.00,'2025-10-03 11:12:00',NOW()),
(10,5,20,'submitted',4,4,100.00,'2025-10-04 12:00:00',NOW()),
(11,5,11,'submitted',2,4,50.00,'2025-10-04 12:05:00',NOW()),
(12,5,12,'submitted',3,4,75.00,'2025-10-04 12:06:00',NOW()),
(13,1,14,'submitted',1,4,25.00,'2025-10-05 09:01:00',NOW()),
(14,2,18,'submitted',2,4,50.00,'2025-10-05 10:01:00',NOW()),
(15,3,20,'submitted',3,4,75.00,'2025-10-05 11:01:00',NOW());

-- -------------------------------
-- StudentAnswers (42) - mix of correct/incorrect
-- Key: For correctness, pick ChoiceNo=1 to be correct per question
-- -------------------------------
DELETE FROM StudentAnswers;
INSERT INTO StudentAnswers (AnswerID, AttemptID, QuestionID, ChoiceID, AnswerText, IsCorrect, PointsEarned) VALUES
-- Attempt 1 (exam 1, q1..q4) score 3
(1,1,1,1,NULL,1,1),(2,1,2,6,NULL,0,0),(3,1,3,9,NULL,1,1),(4,1,4,13,NULL,1,1),
-- Attempt 2 score 4
(5,2,1,1,NULL,1,1),(6,2,2,5,NULL,1,1),(7,2,3,9,NULL,1,1),(8,2,4,13,NULL,1,1),
-- Attempt 3 score 2
(9,3,1,2,NULL,0,0),(10,3,2,7,NULL,0,0),(11,3,3,9,NULL,1,1),(12,3,4,13,NULL,1,1),
-- Attempt 4 (exam2 q5..q8) score 3
(13,4,5,17,NULL,1,1),(14,4,6,21,NULL,1,1),(15,4,7,26,NULL,0,0),(16,4,8,29,NULL,1,1),
-- Attempt 5 score 1
(17,5,5,18,NULL,0,0),(18,5,6,22,NULL,0,0),(19,5,7,25,NULL,1,1),(20,5,8,30,NULL,0,0),
-- Attempt 6 score 4
(21,6,5,17,NULL,1,1),(22,6,6,21,NULL,1,1),(23,6,7,25,NULL,1,1),(24,6,8,29,NULL,1,1),
-- Attempt 7 (exam3 q9..q12) score 2
(25,7,9,34,NULL,0,0),(26,7,10,37,NULL,1,1),(27,7,11,41,NULL,1,1),(28,7,12,46,NULL,0,0),
-- Attempt 8 score 3
(29,8,9,33,NULL,1,1),(30,8,10,38,NULL,0,0),(31,8,11,41,NULL,1,1),(32,8,12,45,NULL,1,1),
-- Attempt 9 score 4
(33,9,9,33,NULL,1,1),(34,9,10,37,NULL,1,1),(35,9,11,41,NULL,1,1),(36,9,12,45,NULL,1,1),
-- Attempt 10 (exam5 q17..q20) score 4
(37,10,17,65,NULL,1,1),(38,10,18,69,NULL,1,1),(39,10,19,73,NULL,1,1),(40,10,20,77,NULL,1,1),
-- Attempt 11 score 2
(41,11,17,66,NULL,0,0),(42,11,18,69,NULL,1,1);

SET FOREIGN_KEY_CHECKS = 1;
