CREATE TABLE `categories` (
  `CategoryID` int NOT NULL AUTO_INCREMENT,
  `CategoryName` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`CategoryID`),
  UNIQUE KEY `CategoryName` (`CategoryName`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `choices` (
  `ChoiceID` int NOT NULL AUTO_INCREMENT,
  `QuestionID` int NOT NULL,
  `ChoiceNo` int NOT NULL,
  `ChoiceText` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `IsCorrect` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`ChoiceID`),
  KEY `QuestionID` (`QuestionID`),
  CONSTRAINT `choices_ibfk_1` FOREIGN KEY (`QuestionID`) REFERENCES `questions` (`QuestionID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=971 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `courses` (
  `CourseID` int NOT NULL AUTO_INCREMENT,
  `CourseCode` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `CourseName` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `CategoryID` int DEFAULT NULL,
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`CourseID`),
  UNIQUE KEY `CourseCode` (`CourseCode`),
  KEY `CategoryID` (`CategoryID`),
  CONSTRAINT `courses_ibfk_1` FOREIGN KEY (`CategoryID`) REFERENCES `categories` (`CategoryID`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `difficultylevels` (
  `DifficultyID` int NOT NULL AUTO_INCREMENT,
  `LevelCode` enum('EASY','MEDIUM','HARD') COLLATE utf8mb4_unicode_ci NOT NULL,
  `LevelName` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`DifficultyID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `examattempts` (
  `AttemptID` int NOT NULL AUTO_INCREMENT,
  `ExamID` int NOT NULL,
  `StudentID` int NOT NULL,
  `Status` enum('in_progress','submitted') COLLATE utf8mb4_unicode_ci DEFAULT 'in_progress',
  `Score` decimal(6,2) DEFAULT '0.00',
  `TotalPoints` decimal(6,2) DEFAULT '0.00',
  `Percentage` decimal(5,2) DEFAULT '0.00',
  `SubmitTime` datetime DEFAULT NULL,
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`AttemptID`),
  KEY `ExamID` (`ExamID`),
  KEY `StudentID` (`StudentID`),
  CONSTRAINT `examattempts_ibfk_1` FOREIGN KEY (`ExamID`) REFERENCES `exams` (`ExamID`) ON DELETE CASCADE,
  CONSTRAINT `examattempts_ibfk_2` FOREIGN KEY (`StudentID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `exams` (
  `ExamID` int NOT NULL AUTO_INCREMENT,
  `ExamName` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `CourseID` int NOT NULL,
  `TopicID` int NOT NULL,
  `InstructorID` int NOT NULL,
  `Status` enum('draft','published') COLLATE utf8mb4_unicode_ci DEFAULT 'draft',
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ExamID`),
  KEY `CourseID` (`CourseID`),
  KEY `TopicID` (`TopicID`),
  KEY `fk_instructor_user` (`InstructorID`),
  CONSTRAINT `exams_ibfk_1` FOREIGN KEY (`CourseID`) REFERENCES `courses` (`CourseID`) ON DELETE CASCADE,
  CONSTRAINT `exams_ibfk_2` FOREIGN KEY (`TopicID`) REFERENCES `topics` (`TopicID`) ON DELETE CASCADE,
  CONSTRAINT `exams_ibfk_3` FOREIGN KEY (`InstructorID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE,
  CONSTRAINT `fk_instructor_user` FOREIGN KEY (`InstructorID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `questions` (
  `QuestionID` int NOT NULL AUTO_INCREMENT,
  `ExamID` int NOT NULL,
  `TopicID` int NOT NULL,
  `TypeID` int NOT NULL,
  `DifficultyID` int NOT NULL,
  `InstructorID` int NOT NULL,
  `QuestionText` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `ShuffleChoices` tinyint(1) DEFAULT '1',
  `Points` decimal(5,2) DEFAULT '1.00',
  `OrderIndex` int DEFAULT '0',
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`QuestionID`),
  KEY `ExamID` (`ExamID`),
  KEY `TopicID` (`TopicID`),
  KEY `TypeID` (`TypeID`),
  KEY `DifficultyID` (`DifficultyID`),
  KEY `InstructorID` (`InstructorID`),
  CONSTRAINT `questions_ibfk_1` FOREIGN KEY (`ExamID`) REFERENCES `exams` (`ExamID`) ON DELETE CASCADE,
  CONSTRAINT `questions_ibfk_2` FOREIGN KEY (`TopicID`) REFERENCES `topics` (`TopicID`),
  CONSTRAINT `questions_ibfk_3` FOREIGN KEY (`TypeID`) REFERENCES `questiontypes` (`TypeID`),
  CONSTRAINT `questions_ibfk_4` FOREIGN KEY (`DifficultyID`) REFERENCES `difficultylevels` (`DifficultyID`),
  CONSTRAINT `questions_ibfk_5` FOREIGN KEY (`InstructorID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=244 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `questiontypes` (
  `TypeID` int NOT NULL AUTO_INCREMENT,
  `TypeCode` enum('MCQ','TF') COLLATE utf8mb4_unicode_ci NOT NULL,
  `TypeName` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`TypeID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `studentanswers` (
  `AnswerID` int NOT NULL AUTO_INCREMENT,
  `AttemptID` int NOT NULL,
  `QuestionID` int NOT NULL,
  `ChoiceID` int DEFAULT NULL,
  `AnswerText` text COLLATE utf8mb4_unicode_ci,
  `IsCorrect` tinyint(1) DEFAULT '0',
  `PointsEarned` decimal(5,2) DEFAULT '0.00',
  PRIMARY KEY (`AnswerID`),
  KEY `AttemptID` (`AttemptID`),
  KEY `QuestionID` (`QuestionID`),
  KEY `ChoiceID` (`ChoiceID`),
  CONSTRAINT `studentanswers_ibfk_1` FOREIGN KEY (`AttemptID`) REFERENCES `examattempts` (`AttemptID`) ON DELETE CASCADE,
  CONSTRAINT `studentanswers_ibfk_2` FOREIGN KEY (`QuestionID`) REFERENCES `questions` (`QuestionID`) ON DELETE CASCADE,
  CONSTRAINT `studentanswers_ibfk_3` FOREIGN KEY (`ChoiceID`) REFERENCES `choices` (`ChoiceID`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=194 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `topics` (
  `TopicID` int NOT NULL AUTO_INCREMENT,
  `CourseID` int NOT NULL,
  `TopicName` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`TopicID`),
  KEY `CourseID` (`CourseID`),
  CONSTRAINT `topics_ibfk_1` FOREIGN KEY (`CourseID`) REFERENCES `courses` (`CourseID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE `users` (
  `UserID` int NOT NULL AUTO_INCREMENT,
  `Username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Department` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Role` enum('student','instructor','admin') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `StudentID` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`UserID`),
  UNIQUE KEY `Username` (`Username`),
  UNIQUE KEY `Email` (`Email`),
  KEY `idx_role` (`Role`),
  KEY `idx_email` (`Email`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
