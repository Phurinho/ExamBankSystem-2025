-- ================================================================
-- full_seed_v5_categories_minimal.sql - Seed data with Categories (Minimal Change)
-- Compatible with schema_v3_categories_minimal.sql
--
-- Changes from v3 seed:
--   - Added SubjectCategories INSERT
--   - Modified Courses INSERT to include CategoryID
--   - Kept all other DELETE/INSERT statements as they were
--
-- PASSWORDS (all users): "password123"
-- ================================================================

USE exam_bank;

SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------
-- Clear Data First (in dependency order)
-- -------------------------------
DELETE FROM StudentAnswers;
DELETE FROM ExamAttempts;
DELETE FROM Choices;
DELETE FROM Questions;
DELETE FROM Exams;
DELETE FROM Topics;
DELETE FROM Courses;
DELETE FROM SubjectCategories; -- NEW DELETE
DELETE FROM Users;
-- Removed DELETE for DifficultyLevels and QuestionTypes

-- -------------------------------
-- Users (5)
-- -------------------------------
INSERT INTO Users (UserID, Username, Email, Password, Department, Role, StudentID, CreatedAt, UpdatedAt) VALUES
(1,'admin','admin@example.com','password123','Computer Engineering','instructor',NULL,NOW(),NOW()),
(2,'teacher','teacher@example.com','password123','IT','instructor',NULL,NOW(),NOW()),
(11,'student1','student1@example.com','password123','CS','student','66000001',NOW(),NOW()),
(12,'student2','student2@example.com','password123','IT','student','66000002',NOW(),NOW()),
(13,'student3','student3@example.com','password123','EE','student','66000003',NOW(),NOW());

-- -------------------------------
-- SubjectCategories (5) - NEW INSERT
-- -------------------------------
INSERT INTO SubjectCategories (CategoryID, CategoryName) VALUES
(1, 'Computer Science & IT'),
(2, 'Natural Sciences'),
(3, 'Social Sciences & Humanities'),
(4, 'Mathematics'),
(5, 'Engineering');

-- -------------------------------
-- Courses (11) - MODIFIED (CategoryID added directly)
-- -------------------------------
INSERT INTO Courses (CourseID, CourseCode, CourseName, CategoryID, CreatedAt) VALUES
(1,'CS101','Intro to Programming',1,NOW()),           -- Category 1: CS & IT
(2,'CS201','Data Structures',1,NOW()),                -- Category 1: CS & IT
(3,'CS301','Algorithms',1,NOW()),                     -- Category 1: CS & IT
(4,'EE101','Circuits I',5,NOW()),                     -- Category 5: Engineering
(5,'MATH201','Discrete Math',4,NOW()),                -- Category 4: Mathematics
(6,'IT105','Web Development',1,NOW()),                -- Category 1: CS & IT
(7,'PHYS101','Physics I',2,NOW()),                    -- Category 2: Natural Sciences
(8,'CHEM101','Chemistry I',2,NOW()),                   -- Category 2: Natural Sciences
(9,'ECON101','Intro to Economics',3,NOW()),           -- Category 3: Social Sciences
(10,'HIST101','World History',3,NOW()),                -- Category 3: Social Sciences
(11,'CS401','Artificial Intelligence',1,NOW());        -- Category 1: CS & IT

-- -------------------------------
-- Topics (22)
-- -------------------------------
DELETE FROM Topics;
INSERT INTO Topics (TopicID, CourseID, TopicName, CreatedAt) VALUES
(1,1,'Variables & Types',NOW()),
(2,1,'Control Flow',NOW()),
(3,2,'Arrays & Linked Lists',NOW()),
(4,2,'Trees & Graphs',NOW()),
(5,3,'Greedy & Divide-Conquer',NOW()),
(6,3,'Dynamic Programming',NOW()),
(7,4,'Ohm\'s Law',NOW()),
(8,4,'AC Analysis',NOW()),
(9,5,'Logic & Proof',NOW()),
(10,5,'Combinatorics',NOW()),
(11,6,'HTML/CSS Basics',NOW()),
(12,6,'REST APIs',NOW()),
(13,7,'Mechanics',NOW()),
(14,7,'Electromagnetism',NOW()),
(15,8,'Atomic Structure',NOW()),
(16,8,'Chemical Bonds',NOW()),
(17,9,'Microeconomics',NOW()),
(18,9,'Macroeconomics',NOW()),
(19,10,'Ancient Civilizations',NOW()),
(20,10,'Modern Era',NOW()),
(21,11,'Search Algorithms',NOW()),
(22,11,'Machine Learning Basics',NOW());

-- -------------------------------
-- Exams (20)
-- -------------------------------
DELETE FROM Exams;
INSERT INTO Exams (ExamID, ExamName, CourseID, TopicID, InstructorID, Status, CreatedAt, UpdatedAt) VALUES
(1,'CS101 Midterm',1,1,1,'published',NOW(),NOW()),
(2,'CS101 Final',1,2,1,'published',NOW(),NOW()),
(3,'CS201 Quiz 1',2,3,2,'published',NOW(),NOW()),
(4,'CS201 Trees Test',2,4,2,'published',NOW(),NOW()),
(5,'CS301 Greedy',3,5,1,'published',NOW(),NOW()),
(6,'CS301 DP Mastery',3,6,1,'published',NOW(),NOW()),
(7,'EE101 Basic Circuit',4,7,2,'published',NOW(),NOW()),
(8,'Math Logic Exam',5,9,1,'published',NOW(),NOW()),
(9,'WebDev HTML/CSS',6,11,2,'published',NOW(),NOW()),
(10,'WebDev API Test',6,12,2,'published',NOW(),NOW()),
(11,'Physics Mechanics Quiz',7,13,1,'published',NOW(),NOW()),
(12,'Physics E&M Test',7,14,1,'published',NOW(),NOW()),
(13,'Chem Atoms Midterm',8,15,2,'published',NOW(),NOW()),
(14,'Chem Bonding Final',8,16,2,'published',NOW(),NOW()),
(15,'Microeconomics 101',9,17,1,'published',NOW(),NOW()),
(16,'Macroeconomics 101',9,18,1,'published',NOW(),NOW()),
(17,'Ancient History',10,19,2,'published',NOW(),NOW()),
(18,'Modern History',10,20,2,'published',NOW(),NOW()),
(19,'AI Search Methods',11,21,1,'published',NOW(),NOW()),
(20,'AI ML Intro',11,22,1,'published',NOW(),NOW());

-- -------------------------------
-- Questions (240)
-- -------------------------------
DELETE FROM Questions;
-- ... (ส่วน Questions ทั้งหมด เหมือนเดิม ไม่มีการเปลี่ยนแปลง) ...
-- Exam 1: CS101 Midterm (Variables & Types) - Q1-12
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(1,1,1,1,1,1,'What is the size of int in most 32-bit systems?',1,1,1,NOW()),
(2,1,1,1,2,1,'Which keyword declares a constant in C?',1,1,2,NOW()),
(3,1,1,1,3,1,'Which is NOT a primitive type in Java?',1,1,3,NOW()),
(4,1,1,1,1,1,'Which symbol starts a single-line comment in C++?',1,1,4,NOW()),
(5,1,1,1,2,1,'What does "int *p" declare in C?',1,1,5,NOW()),
(6,1,1,1,3,1,'Which has automatic type inference?',1,1,6,NOW()),
(7,1,1,1,1,1,'Default value of boolean in Java?',1,1,7,NOW()),
(8,1,1,1,2,1,'Which is a valid variable name?',1,1,8,NOW()),
(9,1,1,1,3,1,'Size of char in C?',1,1,9,NOW()),
(10,1,1,1,1,1,'Which is pass-by-value language?',1,1,10,NOW()),
(11,1,1,1,2,1,'What does "void" return type mean?',1,1,11,NOW()),
(12,1,1,1,3,1,'Which operator is for address-of in C?',1,1,12,NOW());

-- Exam 2: CS101 Final (Control Flow) - Q13-24
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(13,2,2,1,1,1,'Which loop checks condition first?',1,1,1,NOW()),
(14,2,2,1,2,1,'What does "break" do in a loop?',1,1,2,NOW()),
(15,2,2,1,3,1,'Which is the syntax for ternary operator?',1,1,3,NOW()),
(16,2,2,1,1,1,'Default case in switch is optional?',1,1,4,NOW()),
(17,2,2,1,2,1,'Which loop guarantees at least one execution?',1,1,5,NOW()),
(18,2,2,1,3,1,'What does "continue" do?',1,1,6,NOW()),
(19,2,2,1,1,1,'Syntax for if-else in Python?',1,1,7,NOW()),
(20,2,2,1,2,1,'Which keyword for pattern matching in C++17?',1,1,8,NOW()),
(21,2,2,1,3,1,'Can you nest loops?',1,1,9,NOW()),
(22,2,2,1,1,1,'For loop has how many parts?',1,1,10,NOW()),
(23,2,2,1,2,1,'Which loop is best for iterating arrays?',1,1,11,NOW()),
(24,2,2,1,3,1,'What is tail recursion?',1,1,12,NOW());

-- Exam 3: CS201 Quiz (Arrays & Linked Lists) - Q25-36
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(25,3,3,1,1,2,'Array indexing starts at?',1,1,1,NOW()),
(26,3,3,1,2,2,'Time complexity for array access?',1,1,2,NOW()),
(27,3,3,1,3,2,'Linked list advantage over array?',1,1,3,NOW()),
(28,3,3,1,1,2,'Which structure is LIFO?',1,1,4,NOW()),
(29,3,3,1,2,2,'Which structure is FIFO?',1,1,5,NOW()),
(30,3,3,1,3,2,'Doubly linked list has?',1,1,6,NOW()),
(31,3,3,1,1,2,'Circular linked list last node points to?',1,1,7,NOW()),
(32,3,3,1,2,2,'Array insertion at end is?',1,1,8,NOW()),
(33,3,3,1,3,2,'Linked list deletion at head is?',1,1,9,NOW()),
(34,3,3,1,1,2,'Stack operations are?',1,1,10,NOW()),
(35,3,3,1,2,2,'Queue uses which principle?',1,1,11,NOW()),
(36,3,3,1,3,2,'Deque allows insertion at?',1,1,12,NOW());

-- Exam 4: CS201 Trees (Trees & Graphs) - Q37-48
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(37,4,4,1,1,2,'Binary tree node has max children?',1,1,1,NOW()),
(38,4,4,1,2,2,'Tree with N nodes has edges?',1,1,2,NOW()),
(39,4,4,1,3,2,'BST inorder traversal gives?',1,1,3,NOW()),
(40,4,4,1,1,2,'Tree height with 1 node?',1,1,4,NOW()),
(41,4,4,1,2,2,'Full binary tree means?',1,1,5,NOW()),
(42,4,4,1,3,2,'Complete binary tree fills levels?',1,1,6,NOW()),
(43,4,4,1,1,2,'DFS uses which structure?',1,1,7,NOW()),
(44,4,4,1,2,2,'BFS uses which structure?',1,1,8,NOW()),
(45,4,4,1,3,2,'Graph cycle detection uses?',1,1,9,NOW()),
(46,4,4,1,1,2,'Directed graph is also called?',1,1,10,NOW()),
(47,4,4,1,2,2,'Shortest path algorithm?',1,1,11,NOW()),
(48,4,4,1,3,2,'Minimum spanning tree algorithm?',1,1,12,NOW());

-- Exam 5: CS301 Greedy - Q49-60
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(49,5,5,1,1,1,'Greedy makes choice based on?',1,1,1,NOW()),
(50,5,5,1,2,1,'Greedy guarantees optimal solution?',1,1,2,NOW()),
(51,5,5,1,3,1,'Which problem uses greedy?',1,1,3,NOW()),
(52,5,5,1,1,1,'Huffman coding is?',1,1,4,NOW()),
(53,5,5,1,2,1,'Activity selection sorts by?',1,1,5,NOW()),
(54,5,5,1,3,1,'Fractional knapsack allows?',1,1,6,NOW()),
(55,5,5,1,1,1,'Dijkstra algorithm finds?',1,1,7,NOW()),
(56,5,5,1,2,1,'Kruskal algorithm is for?',1,1,8,NOW()),
(57,5,5,1,3,1,'Prim algorithm uses?',1,1,9,NOW()),
(58,5,5,1,1,1,'Coin change greedy works for?',1,1,10,NOW()),
(59,5,5,1,2,1,'Job sequencing maximizes?',1,1,11,NOW()),
(60,5,5,1,3,1,'Divide and conquer divides into?',1,1,12,NOW());

-- Exam 6: CS301 DP - Q61-72
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(61,6,6,1,1,1,'DP stands for?',1,1,1,NOW()),
(62,6,6,1,2,1,'DP uses which technique?',1,1,2,NOW()),
(63,6,6,1,3,1,'Memoization stores?',1,1,3,NOW()),
(64,6,6,1,1,1,'Fibonacci with DP is?',1,1,4,NOW()),
(65,6,6,1,2,1,'LCS problem complexity?',1,1,5,NOW()),
(66,6,6,1,3,1,'0/1 Knapsack uses?',1,1,6,NOW()),
(67,6,6,1,1,1,'Edit distance measures?',1,1,7,NOW()),
(68,6,6,1,2,1,'Matrix chain multiplication optimizes?',1,1,8,NOW()),
(69,6,6,1,3,1,'Coin change DP finds?',1,1,9,NOW()),
(70,6,6,1,1,1,'Longest increasing subsequence?',1,1,10,NOW()),
(71,6,6,1,2,1,'Subset sum is?',1,1,11,NOW()),
(72,6,6,1,3,1,'DP table is also called?',1,1,12,NOW());

-- Exam 7: EE101 - Q73-84
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(73,7,7,1,1,2,'Unit of resistance?',1,1,1,NOW()),
(74,7,7,1,2,2,'Ohm\'s law formula?',1,1,2,NOW()),
(75,7,7,1,3,2,'Series resistors total?',1,1,3,NOW()),
(76,7,7,1,1,2,'Parallel resistors total?',1,1,4,NOW()),
(77,7,7,1,2,2,'Unit of current?',1,1,5,NOW()),
(78,7,7,1,3,2,'Unit of voltage?',1,1,6,NOW()),
(79,7,7,1,1,2,'Power formula?',1,1,7,NOW()),
(80,7,7,1,2,2,'Kirchhoff current law?',1,1,8,NOW()),
(81,7,7,1,3,2,'Kirchhoff voltage law?',1,1,9,NOW()),
(82,7,7,1,1,2,'AC stands for?',1,1,10,NOW()),
(83,7,7,1,2,2,'DC stands for?',1,1,11,NOW()),
(84,7,7,1,3,2,'Capacitor stores?',1,1,12,NOW());

-- Exam 8: Math Logic - Q85-96
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(85,8,9,1,1,1,'AND gate output when both inputs 1?',1,1,1,NOW()),
(86,8,9,1,2,1,'OR gate output when both inputs 0?',1,1,2,NOW()),
(87,8,9,1,3,1,'NOT gate is also called?',1,1,3,NOW()),
(88,8,9,1,1,1,'XOR gate outputs 1 when?',1,1,4,NOW()),
(89,8,9,1,2,1,'De Morgan\'s law for NOT(A AND B)?',1,1,5,NOW()),
(90,8,9,1,3,1,'Proof by contradiction assumes?',1,1,6,NOW()),
(91,8,9,1,1,1,'Proof by induction has steps?',1,1,7,NOW()),
(92,8,9,1,2,1,'Tautology is?',1,1,8,NOW()),
(93,8,9,1,3,1,'Contradiction is?',1,1,9,NOW()),
(94,8,9,1,1,1,'Implication A→B is false when?',1,1,10,NOW()),
(95,8,9,1,2,1,'Biconditional A↔B means?',1,1,11,NOW()),
(96,8,9,1,3,1,'Contrapositive of A→B?',1,1,12,NOW());

-- Exam 9: WebDev HTML/CSS - Q97-108
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(97,9,11,1,1,2,'HTML stands for?',1,1,1,NOW()),
(98,9,11,1,2,2,'Which tag for hyperlink?',1,1,2,NOW()),
(99,9,11,1,3,2,'CSS stands for?',1,1,3,NOW()),
(100,9,11,1,1,2,'Which tag for heading 1?',1,1,4,NOW()),
(101,9,11,1,2,2,'<div> is a?',1,1,5,NOW()),
(102,9,11,1,3,2,'Which attribute for image source?',1,1,6,NOW()),
(103,9,11,1,1,2,'CSS selector for class?',1,1,7,NOW()),
(104,9,11,1,2,2,'CSS selector for id?',1,1,8,NOW()),
(105,9,11,1,3,2,'Flexbox is for?',1,1,9,NOW()),
(106,9,11,1,1,2,'Grid is for?',1,1,10,NOW()),
(107,9,11,1,2,2,'Position absolute is relative to?',1,1,11,NOW()),
(108,9,11,1,3,2,'Z-index controls?',1,1,12,NOW());

-- Exam 10: WebDev API - Q109-120
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(109,10,12,1,1,2,'REST stands for?',1,1,1,NOW()),
(110,10,12,1,2,2,'HTTP method for creating resource?',1,1,2,NOW()),
(111,10,12,1,3,2,'HTTP method for updating resource?',1,1,3,NOW()),
(112,10,12,1,1,2,'HTTP method for deleting resource?',1,1,4,NOW()),
(113,10,12,1,2,2,'HTTP method for reading resource?',1,1,5,NOW()),
(114,10,12,1,3,2,'Status code 200 means?',1,1,6,NOW()),
(115,10,12,1,1,2,'Status code 404 means?',1,1,7,NOW()),
(116,10,12,1,2,2,'Status code 500 means?',1,1,8,NOW()),
(117,10,12,1,3,2,'JSON stands for?',1,1,9,NOW()),
(118,10,12,1,1,2,'API endpoint is?',1,1,10,NOW()),
(119,10,12,1,2,2,'Bearer token is used for?',1,1,11,NOW()),
(120,10,12,1,3,2,'CORS stands for?',1,1,12,NOW());

-- Exam 11: Physics Mechanics (Topic 13) - Q121-132
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(121,11,13,1,1,1,'Unit of Force?',1,1,1,NOW()),
(122,11,13,1,2,1,'Newton\'s Second Law?',1,1,2,NOW()),
(123,11,13,1,3,1,'Formula for kinetic energy?',1,1,3,NOW()),
(124,11,13,1,1,1,'Unit of Work?',1,1,4,NOW()),
(125,11,13,1,2,1,'Momentum is?',1,1,5,NOW()),
(126,11,13,1,3,1,'Centripetal force is directed?',1,1,6,NOW()),
(127,11,13,1,1,1,'What is inertia?',1,1,7,NOW()),
(128,11,13,1,2,1,'Formula for potential energy?',1,1,8,NOW()),
(129,11,13,1,3,1,'Hooke\'s Law relates?',1,1,9,NOW()),
(130,11,13,1,1,1,'g on Earth (approx)?',1,1,10,NOW()),
(131,11,13,1,2,1,'Friction opposes?',1,1,11,NOW()),
(132,11,13,1,3,1,'Torque is?',1,1,12,NOW());

-- Exam 12: Physics E&M (Topic 14) - Q133-144
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(133,12,14,1,1,1,'Unit of electric charge?',1,1,1,NOW()),
(134,12,14,1,2,1,'Coulomb\'s Law describes?',1,1,2,NOW()),
(135,12,14,1,3,1,'Magnetic field lines point from?',1,1,3,NOW()),
(136,12,14,1,1,1,'Unit of capacitance?',1,1,4,NOW()),
(137,12,14,1,2,1,'Inductor stores energy in?',1,1,5,NOW()),
(138,12,14,1,3,1,'Lenz\'s Law relates to?',1,1,6,NOW()),
(139,12,14,1,1,1,'Like charges do what?',1,1,7,NOW()),
(140,12,14,1,2,1,'Ohm\'s Law is?',1,1,8,NOW()),
(141,12,14,1,3,1,'Right-hand rule finds?',1,1,9,NOW()),
(142,12,14,1,1,1,'Unit of magnetic flux?',1,1,10,NOW()),
(143,12,14,1,2,1,'Transformer changes?',1,1,11,NOW()),
(144,12,14,1,3,1,'Maxwell\'s equations describe?',1,1,12,NOW());

-- Exam 13: Chem Atoms (Topic 15) - Q145-156
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(145,13,15,1,1,2,'Particle with negative charge?',1,1,1,NOW()),
(146,13,15,1,2,2,'Center of atom is?',1,1,2,NOW()),
(147,13,15,1,3,2,'Atomic number is number of?',1,1,3,NOW()),
(148,13,15,1,1,2,'Particle with no charge?',1,1,4,NOW()),
(149,13,15,1,2,2,'Isotopes have different number of?',1,1,5,NOW()),
(150,13,15,1,3,2,'Electron shell model is by?',1,1,6,NOW()),
(151,13,15,1,1,2,'Proton charge?',1,1,7,NOW()),
(152,13,15,1,2,2,'Mass number is?',1,1,8,NOW()),
(153,13,15,1,3,2,'Valence electrons are?',1,1,9,NOW()),
(154,13,15,1,1,2,'Group 18 elements are?',1,1,10,NOW()),
(155,13,15,1,2,2,'Avogadro\'s number is?',1,1,11,NOW()),
(156,13,15,1,3,2,'What is an ion?',1,1,12,NOW());

-- Exam 14: Chem Bonding (Topic 16) - Q157-168
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(157,14,16,1,1,2,'Bond from sharing electrons?',1,1,1,NOW()),
(158,14,16,1,2,2,'Bond from transferring electrons?',1,1,2,NOW()),
(159,14,16,1,3,2,'Water (H2O) has which bond?',1,1,3,NOW()),
(160,14,16,1,1,2,'NaCl has which bond?',1,1,4,NOW()),
(161,14,16,1,2,2,'Bond in metals?',1,1,5,NOW()),
(162,14,16,1,3,2,'What is electronegativity?',1,1,6,NOW()),
(163,14,16,1,1,2,'Octet rule means?',1,1,7,NOW()),
(164,14,16,1,2,2,'VSEPR theory predicts?',1,1,8,NOW()),
(165,14,16,1,3,2,'Hydrogen bond is?',1,1,9,NOW()),
(166,14,16,1,1,2,'Diatomic molecule example?',1,1,10,NOW()),
(167,14,16,1,2,2,'Polar bond means?',1,1,11,NOW()),
(168,14,16,1,3,2,'Lewis structure shows?',1,1,12,NOW());

-- Exam 15: Microeconomics (Topic 17) - Q169-180
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(169,15,17,1,1,1,'Law of demand states?',1,1,1,NOW()),
(170,15,17,1,2,1,'Law of supply states?',1,1,2,NOW()),
(171,15,17,1,3,1,'Equilibrium price is where?',1,1,3,NOW()),
(172,15,17,1,1,1,'Elasticity measures?',1,1,4,NOW()),
(173,15,17,1,2,1,'Opportunity cost is?',1,1,5,NOW()),
(174,15,17,1,3,1,'Monopoly means?',1,1,6,NOW()),
(175,15,17,1,1,1,'Oligopoly means?',1,1,7,NOW()),
(176,15,17,1,2,1,'Perfect competition means?',1,1,8,NOW()),
(177,15,17,1,3,1,'Utility is?',1,1,9,NOW()),
(178,15,17,1,1,1,'Scarcity is?',1,1,10,NOW()),
(179,15,17,1,2,1,'Capital, in economics, is?',1,1,11,NOW()),
(180,15,17,1,3,1,'Diminishing returns means?',1,1,12,NOW());

-- Exam 16: Macroeconomics (Topic 18) - Q181-192
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(181,16,18,1,1,1,'GDP stands for?',1,1,1,NOW()),
(182,16,18,1,2,1,'Inflation is?',1,1,2,NOW()),
(183,16,18,1,3,1,'Deflation is?',1,1,3,NOW()),
(184,16,18,1,1,1,'Central bank controls?',1,1,4,NOW()),
(185,16,18,1,2,1,'Monetary policy is?',1,1,5,NOW()),
(186,16,18,1,3,1,'Fiscal policy is?',1,1,6,NOW()),
(187,16,18,1,1,1,'Unemployment rate is?',1,1,7,NOW()),
(188,16,18,1,2,1,'Recession is?',1,1,8,NOW()),
(189,16,18,1,3,1,'Exchange rate is?',1,1,9,NOW()),
(190,16,18,1,1,1,'Keynesian economics focuses on?',1,1,10,NOW()),
(191,16,18,1,2,1,'Tariff is?',1,1,11,NOW()),
(192,16,18,1,3,1,'Supply-side economics focuses on?',1,1,12,NOW());

-- Exam 17: Ancient History (Topic 19) - Q193-204
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(193,17,19,1,1,2,'Mesopotamia is between which rivers?',1,1,1,NOW()),
(194,17,19,1,2,2,'Egyptian writing system?',1,1,2,NOW()),
(195,17,19,1,3,2,'Who founded Roman Empire?',1,1,3,NOW()),
(196,17,19,1,1,2,'Birthplace of democracy?',1,1,4,NOW()),
(197,17,19,1,2,2,'Code of Hammurabi is?',1,1,5,NOW()),
(198,17,19,1,3,2,'Peloponnesian War was between?',1,1,6,NOW()),
(199,17,19,1,1,2,'Pyramids were built as?',1,1,7,NOW()),
(200,17,19,1,2,2,'Who was Alexander the Great\'s tutor?',1,1,8,NOW()),
(201,17,19,1,3,2,'Indus Valley civilization is in?',1,1,9,NOW()),
(202,17,19,1,1,2,'Great Wall of China purpose?',1,1,10,NOW()),
(203,17,19,1,2,2,'First Roman Emperor?',1,1,11,NOW()),
(204,17,19,1,3,2,'Fall of Western Roman Empire year?',1,1,12,NOW());

-- Exam 18: Modern History (Topic 20) - Q205-216
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(205,18,20,1,1,2,'Renaissance means?',1,1,1,NOW()),
(206,18,20,1,2,2,'Who started Protestant Reformation?',1,1,2,NOW()),
(207,18,20,1,3,2,'Industrial Revolution started where?',1,1,3,NOW()),
(208,18,20,1,1,2,'WWI started in which year?',1,1,4,NOW()),
(209,18,20,1,2,2,'WWII started in which year?',1,1,5,NOW()),
(210,18,20,1,3,2,'The Cold War was between?',1,1,6,NOW()),
(211,18,20,1,1,2,'French Revolution slogan?',1,1,7,NOW()),
(212,18,20,1,2,2,'American Declaration of Independence year?',1,1,8,NOW()),
(213,18,20,1,3,2,'Who invented printing press (Europe)?',1,1,9,NOW()),
(214,18,20,1,1,2,'Berlin Wall fell in?',1,1,10,NOW()),
(215,18,20,1,2,2,'Apartheid was policy in?',1,1,11,NOW()),
(216,18,20,1,3,2,'League of Nations was precursor to?',1,1,12,NOW());

-- Exam 19: AI Search (Topic 21) - Q217-228
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(217,19,21,1,1,1,'BFS stands for?',1,1,1,NOW()),
(218,19,21,1,2,1,'DFS stands for?',1,1,2,NOW()),
(219,19,21,1,3,1,'Which search is optimal (shortest path)?',1,1,3,NOW()),
(220,19,21,1,1,1,'Which search uses a queue?',1,1,4,NOW()),
(221,19,21,1,2,1,'Which search uses a stack?',1,1,5,NOW()),
(222,19,21,1,3,1,'A* uses which function?',1,1,6,NOW()),
(223,19,21,1,1,1,'Heuristic function estimates?',1,1,7,NOW()),
(224,19,21,1,2,1,'Uninformed search means?',1,1,8,NOW()),
(225,19,21,1,3,1,'Informed search means?',1,1,9,NOW()),
(226,19,21,1,1,1,'Dijkstra\'s algorithm finds?',1,1,10,NOW()),
(227,19,21,1,2,1,'Hill climbing can get stuck in?',1,1,11,NOW()),
(228,19,21,1,3,1,'Minimax algorithm is used in?',1,1,12,NOW());

-- Exam 20: AI ML Intro (Topic 22) - Q229-240
INSERT INTO Questions (QuestionID, ExamID, TopicID, TypeID, DifficultyID, InstructorID, QuestionText, ShuffleChoices, Points, OrderIndex, CreatedAt) VALUES
(229,20,22,1,1,1,'ML stands for?',1,1,1,NOW()),
(230,20,22,1,2,1,'Supervised learning uses?',1,1,2,NOW()),
(231,20,22,1,3,1,'Unsupervised learning finds?',1,1,3,NOW()),
(232,20,22,1,1,1,'Example of classification?',1,1,4,NOW()),
(233,20,22,1,2,1,'Example of regression?',1,1,5,NOW()),
(234,20,22,1,3,1,'K-Means is what type of algorithm?',1,1,6,NOW()),
(235,20,22,1,1,1,'Decision Tree is?',1,1,7,NOW()),
(236,20,22,1,2,1,'Neural Network is inspired by?',1,1,8,NOW()),
(237,20,22,1,3,1,'Overfitting means?',1,1,9,NOW()),
(238,20,22,1,1,1,'Training set is used for?',1,1,10,NOW()),
(239,20,22,1,2,1,'Test set is used for?',1,1,11,NOW()),
(240,20,22,1,3,1,'Reinforcement learning uses?',1,1,12,NOW());

-- -------------------------------
-- Choices (960)
-- -------------------------------
-- ... (ส่วน Choices ทั้งหมด เหมือนเดิม ไม่มีการเปลี่ยนแปลง) ...
-- Q1-12: Exam 1
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(1,1,1,'4 bytes',1),(2,1,2,'2 bytes',0),(3,1,3,'8 bytes',0),(4,1,4,'16 bytes',0),
(5,2,1,'const',1),(6,2,2,'let',0),(7,2,3,'final',0),(8,2,4,'static',0),
(9,3,1,'String',1),(10,3,2,'int',0),(11,3,3,'boolean',0),(12,3,4,'char',0),
(13,4,1,'//',1),(14,4,2,'/*',0),(15,4,3,'#',0),(16,4,4,'--',0),
(17,5,1,'Pointer to int',1),(18,5,2,'Array of int',0),(19,5,3,'Reference to int',0),(20,5,4,'Int pointer array',0),
(21,6,1,'auto in C++',1),(22,6,2,'var in C',0),(23,6,3,'dim in C',0),(24,6,4,'infer in Java',0),
(25,7,1,'false',1),(26,7,2,'true',0),(27,7,3,'0',0),(28,7,4,'null',0),
(29,8,1,'myVariable',1),(30,8,2,'2variable',0),(31,8,3,'my-variable',0),(32,8,4,'my variable',0),
(33,9,1,'1 byte',1),(34,9,2,'2 bytes',0),(35,9,3,'4 bytes',0),(36,9,4,'8 bytes',0),
(37,10,1,'C',1),(38,10,2,'JavaScript',0),(39,10,3,'Java',0),(40,10,4,'Python',0),
(41,11,1,'Returns nothing',1),(42,11,2,'Returns void type',0),(43,11,3,'Returns null',0),(44,11,4,'Returns 0',0),
(45,12,1,'&',1),(46,12,2,'*',0),(47,12,3,'@',0),(48,12,4,'#',0);

-- Q13-24: Exam 2
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(49,13,1,'while',1),(50,13,2,'do-while',0),(51,13,3,'for',0),(52,13,4,'repeat',0),
(53,14,1,'Exits loop',1),(54,14,2,'Skips iteration',0),(55,14,3,'Continues loop',0),(56,14,4,'Pauses loop',0),
(57,15,1,'condition ? true : false',1),(58,15,2,'if ? true : false',0),(59,15,3,'condition : true ? false',0),(60,15,4,'? condition true false',0),
(61,16,1,'Yes',1),(62,16,2,'No',0),(63,16,3,'Only in C++',0),(64,16,4,'Only in Java',0),
(65,17,1,'do-while',1),(66,17,2,'while',0),(67,17,3,'for',0),(68,17,4,'foreach',0),
(69,18,1,'Skips to next iteration',1),(70,18,2,'Exits loop',0),(71,18,3,'Exits program',0),(72,18,4,'Does nothing',0),
(73,19,1,'if condition:',1),(74,19,2,'if (condition)',0),(75,19,3,'if condition then',0),(76,19,4,'if {condition}',0),
(77,20,1,'switch',1),(78,20,2,'match',0),(79,20,3,'case',0),(80,20,4,'when',0),
(81,21,1,'Yes',1),(82,21,2,'No',0),(83,21,3,'Only 2 levels',0),(84,21,4,'Only in C',0),
(85,22,1,'3',1),(86,22,2,'2',0),(87,22,3,'4',0),(88,22,4,'5',0),
(89,23,1,'for',1),(90,23,2,'while',0),(91,23,3,'do-while',0),(92,23,4,'repeat',0),
(93,24,1,'Recursive call at end',1),(94,24,2,'Recursive call at start',0),(95,24,3,'No recursion',0),(96,24,4,'Multiple recursive calls',0);

-- Q25-36: Exam 3
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(97,25,1,'0',1),(98,25,2,'1',0),(99,25,3,'-1',0),(100,25,4,'Depends',0),
(101,26,1,'O(1)',1),(102,26,2,'O(n)',0),(103,26,3,'O(log n)',0),(104,26,4,'O(n^2)',0),
(105,27,1,'Dynamic size',1),(106,27,2,'Faster access',0),(107,27,3,'Less memory',0),(108,27,4,'Simpler',0),
(109,28,1,'Stack',1),(110,28,2,'Queue',0),(111,28,3,'List',0),(112,28,4,'Tree',0),
(113,29,1,'Queue',1),(114,29,2,'Stack',0),(115,29,3,'Heap',0),(116,29,4,'Tree',0),
(117,30,1,'Two pointers per node',1),(118,30,2,'One pointer per node',0),(119,30,3,'Three pointers per node',0),(120,30,4,'No pointers',0),
(121,31,1,'Head',1),(122,31,2,'NULL',0),(123,31,3,'Itself',0),(124,31,4,'Previous',0),
(125,32,1,'O(1)',1),(126,32,2,'O(n)',0),(127,32,3,'O(log n)',0),(128,32,4,'O(n^2)',0),
(129,33,1,'O(1)',1),(130,33,2,'O(n)',0),(131,33,3,'O(log n)',0),(132,33,4,'O(n^2)',0),
(133,34,1,'push and pop',1),(134,34,2,'enqueue and dequeue',0),(135,34,3,'insert and delete',0),(136,34,4,'add and remove',0),
(137,35,1,'FIFO',1),(138,35,2,'LIFO',0),(139,35,3,'Random',0),(140,35,4,'Priority',0),
(141,36,1,'Both ends',1),(142,36,2,'Front only',0),(143,36,3,'Rear only',0),(144,36,4,'Middle only',0);

-- Q37-48: Exam 4
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(145,37,1,'2',1),(146,37,2,'1',0),(147,37,3,'3',0),(148,37,4,'4',0),
(149,38,1,'N-1',1),(150,38,2,'N',0),(151,38,3,'N+1',0),(152,38,4,'2N',0),
(153,39,1,'Sorted order',1),(154,39,2,'Reverse order',0),(155,39,3,'Random order',0),(156,39,4,'Level order',0),
(157,40,1,'0',1),(158,40,2,'1',0),(159,40,3,'-1',0),(160,40,4,'NULL',0),
(161,41,1,'All nodes have 0 or 2 children',1),(162,41,2,'All nodes have 1 child',0),(163,41,3,'All nodes have 3 children',0),(164,41,4,'All levels filled',0),
(165,42,1,'Left to right',1),(166,42,2,'Right to left',0),(167,42,3,'Random',0),(168,42,4,'Top to bottom only',0),
(169,43,1,'Stack',1),(170,43,2,'Queue',0),(171,43,3,'Array',0),(172,43,4,'Heap',0),
(173,44,1,'Queue',1),(174,44,2,'Stack',0),(175,44,3,'Array',0),(176,44,4,'Tree',0),
(177,45,1,'DFS',1),(178,45,2,'BFS',0),(179,45,3,'Dijkstra',0),(180,45,4,'Floyd',0),
(181,46,1,'Digraph',1),(182,46,2,'Undigraph',0),(183,46,3,'Bidirectional',0),(184,46,4,'Multgraph',0),
(185,47,1,'Dijkstra',1),(186,47,2,'DFS',0),(187,47,3,'BFS',0),(188,47,4,'Kruskal',0),
(189,48,1,'Kruskal',1),(190,48,2,'Dijkstra',0),(191,48,3,'DFS',0),(192,48,4,'BFS',0);

-- Q49-60: Exam 5
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(193,49,1,'Current local optimum',1),(194,49,2,'Global optimum',0),(195,49,3,'Random choice',0),(196,49,4,'Previous choice',0),
(197,50,1,'No, not always',1),(198,50,2,'Yes, always',0),(199,50,3,'Only for sorting',0),(200,50,4,'Only for graphs',0),
(201,51,1,'Activity selection',1),(202,51,2,'0/1 Knapsack',0),(203,51,3,'All problems',0),(204,51,4,'No problems',0),
(205,52,1,'Greedy compression',1),(206,52,2,'Dynamic programming',0),(207,52,3,'Divide and conquer',0),(208,52,4,'Brute force',0),
(209,53,1,'Finish time',1),(210,53,2,'Start time',0),(211,53,3,'Duration',0),(212,53,4,'Priority',0),
(213,54,1,'Taking fractions',1),(214,54,2,'Only whole items',0),(215,54,3,'No items',0),(216,54,4,'All items',0),
(217,55,1,'Shortest path',1),(218,55,2,'Longest path',0),(219,55,3,'All paths',0),(220,55,4,'Cycles',0),
(221,56,1,'MST',1),(222,56,2,'Shortest path',0),(223,56,3,'Longest path',0),(224,56,4,'Cycle detection',0),
(225,57,1,'Priority queue',1),(226,57,2,'Stack',0),(227,57,3,'Array',0),(228,57,4,'List',0),
(229,58,1,'Canonical coin systems',1),(230,58,2,'All coin systems',0),(231,58,3,'No coin systems',0),(232,58,4,'Binary coins only',0),
(233,59,1,'Profit',1),(234,59,2,'Time',0),(235,59,3,'Jobs count',0),(236,59,4,'Deadlines',0),
(237,60,1,'Subproblems',1),(238,60,2,'Iterations',0),(239,60,3,'Choices',0),(240,60,4,'Options',0);

-- Q61-72: Exam 6
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(241,61,1,'Dynamic Programming',1),(242,61,2,'Data Processing',0),(243,61,3,'Direct Programming',0),(244,61,4,'Dual Processing',0),
(245,62,1,'Memoization',1),(246,62,2,'Randomization',0),(247,62,3,'Simulation',0),(248,62,4,'Iteration only',0),
(249,63,1,'Subproblem results',1),(250,63,2,'Input data',0),(251,63,3,'Output data',0),(252,63,4,'Random values',0),
(253,64,1,'O(n)',1),(254,64,2,'O(2^n)',0),(255,64,3,'O(n^2)',0),(256,64,4,'O(log n)',0),
(257,65,1,'O(n*m)',1),(258,65,2,'O(n+m)',0),(259,65,3,'O(n^2)',0),(260,65,4,'O(1)',0),
(261,66,1,'DP table',1),(262,66,2,'Greedy choice',0),(263,66,3,'Backtracking',0),(264,66,4,'Brute force',0),
(265,67,1,'String difference',1),(266,67,2,'String length',0),(267,67,3,'Character count',0),(268,67,4,'Word count',0),
(269,68,1,'Multiplication order',1),(270,68,2,'Matrix values',0),(271,68,3,'Matrix size',0),(272,68,4,'Matrix count',0),
(273,69,1,'Minimum coins',1),(274,69,2,'Maximum coins',0),(275,69,3,'All combinations',0),(276,69,4,'Coin types',0),
(277,70,1,'O(n^2) DP solution',1),(278,70,2,'O(n) greedy',0),(279,70,3,'O(2^n) brute',0),(280,70,4,'O(log n) binary',0),
(281,71,1,'NP-complete',1),(282,71,2,'P',0),(283,71,3,'NP-hard only',0),(284,71,4,'Polynomial',0),
(285,72,1,'DP array',1),(286,72,2,'Hash table',0),(287,72,3,'Stack',0),(288,72,4,'Queue',0);

-- Q73-84: Exam 7
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(289,73,1,'Ohm',1),(290,73,2,'Volt',0),(291,73,3,'Ampere',0),(292,73,4,'Watt',0),
(293,74,1,'V = IR',1),(294,74,2,'V = I/R',0),(295,74,3,'V = R/I',0),(296,74,4,'V = I+R',0),
(297,75,1,'Sum of all',1),(298,75,2,'Product of all',0),(299,75,3,'Average of all',0),(300,75,4,'Max of all',0),
(301,76,1,'1/R_total = sum(1/R_i)',1),(302,76,2,'R_total = sum(R_i)',0),(303,76,3,'R_total = product(R_i)',0),(304,76,4,'R_total = max(R_i)',0),
(305,77,1,'Ampere',1),(306,77,2,'Volt',0),(307,77,3,'Ohm',0),(308,77,4,'Watt',0),
(309,78,1,'Volt',1),(310,78,2,'Ampere',0),(311,78,3,'Ohm',0),(312,78,4,'Watt',0),
(313,79,1,'P = VI',1),(314,79,2,'P = V/I',0),(315,79,3,'P = I/V',0),(316,79,4,'P = V+I',0),
(317,80,1,'Sum of currents = 0',1),(318,80,2,'Sum of voltages = 0',0),(319,80,3,'Current in = Current out',0),(320,80,4,'Voltage in = Voltage out',0),
(321,81,1,'Sum of voltages = 0',1),(322,81,2,'Sum of currents = 0',0),(323,81,3,'Voltage drop = 0',0),(324,81,4,'Current drop = 0',0),
(325,82,1,'Alternating Current',1),(326,82,2,'Analog Current',0),(327,82,3,'Active Current',0),(328,82,4,'Automatic Current',0),
(329,83,1,'Direct Current',1),(330,83,2,'Digital Current',0),(331,83,3,'Dynamic Current',0),(332,83,4,'Dual Current',0),
(333,84,1,'Electric charge',1),(334,84,2,'Magnetic field',0),(335,84,3,'Heat',0),(336,84,4,'Light',0);

-- Q85-96: Exam 8
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(337,85,1,'1',1),(338,85,2,'0',0),(339,85,3,'True',0),(340,85,4,'False',0),
(341,86,1,'0',1),(342,86,2,'1',0),(343,86,3,'True',0),(344,86,4,'Undefined',0),
(345,87,1,'Inverter',1),(346,87,2,'Buffer',0),(347,87,3,'Converter',0),(348,87,4,'Transformer',0),
(349,88,1,'Inputs differ',1),(350,88,2,'Inputs same',0),(351,88,3,'Both 1',0),(352,88,4,'Both 0',0),
(353,89,1,'NOT(A) OR NOT(B)',1),(354,89,2,'NOT(A) AND NOT(B)',0),(355,89,3,'A OR B',0),(356,89,4,'A AND B',0),
(357,90,1,'Opposite is true',1),(358,90,2,'Statement is true',0),(359,90,3,'Statement is false',0),(360,90,4,'Nothing',0),
(361,91,1,'Base + Inductive',1),(362,91,2,'Base only',0),(363,91,3,'Inductive only',0),(364,91,4,'Neither',0),
(365,92,1,'Always true',1),(366,92,2,'Always false',0),(367,92,3,'Sometimes true',0),(368,92,4,'Undefined',0),
(369,93,1,'Always false',1),(370,93,2,'Always true',0),(371,93,3,'Sometimes false',0),(372,93,4,'Undefined',0),
(373,94,1,'A is true, B is false',1),(374,94,2,'A is false, B is true',0),(375,94,3,'Both true',0),(376,94,4,'Both false',0),
(377,95,1,'Both true or both false',1),(378,95,2,'One true one false',0),(379,95,3,'Both true only',0),(380,95,4,'Both false only',0),
(381,96,1,'NOT(B) -> NOT(A)',1),(382,96,2,'B -> A',0),(383,96,3,'NOT(A) -> NOT(B)',0),(384,96,4,'A -> NOT(B)',0);

-- Q97-108: Exam 9
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(385,97,1,'HyperText Markup Language',1),(386,97,2,'HighText Markup Language',0),(387,97,3,'Hyperlink Text Language',0),(388,97,4,'Home Tool Markup Language',0),
(389,98,1,'<a>',1),(390,98,2,'<link>',0),(391,98,3,'<href>',0),(392,98,4,'<url>',0),
(393,99,1,'Cascading Style Sheets',1),(394,99,2,'Creative Style Syntax',0),(395,99,3,'Computer Style System',0),(396,99,4,'Custom Styling Sheets',0),
(397,100,1,'<h1>',1),(398,100,2,'<header>',0),(399,100,3,'<head>',0),(400,100,4,'<h>',0),
(401,101,1,'Block element',1),(402,101,2,'Inline element',0),(403,101,3,'Table element',0),(404,101,4,'Form element',0),
(405,102,1,'src',1),(406,102,2,'href',0),(407,102,3,'url',0),(408,102,4,'link',0),
(409,103,1,'.classname',1),(410,103,2,'#classname',0),(411,103,3,'*classname',0),(412,103,4,'@classname',0),
(413,104,1,'#idname',1),(414,104,2,'.idname',0),(415,104,3,'*idname',0),(416,104,4,'@idname',0),
(417,105,1,'Layout in 1D',1),(418,105,2,'Layout in 2D',0),(419,105,3,'Positioning',0),(420,105,4,'Animation',0),
(421,106,1,'Layout in 2D',1),(422,106,2,'Layout in 1D',0),(423,106,3,'Positioning',0),(424,106,4,'Animation',0),
(425,107,1,'Nearest positioned ancestor',1),(426,107,2,'Body',0),(427,107,3,'Parent element',0),(428,107,4,'Viewport',0),
(429,108,1,'Stacking order',1),(430,108,2,'Horizontal position',0),(431,108,3,'Vertical position',0),(432,108,4,'Opacity',0);

-- Q109-120: Exam 10
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(433,109,1,'Representational State Transfer',1),(434,109,2,'Remote State Transfer',0),(435,109,3,'Resource State Transfer',0),(436,109,4,'Relational State Transfer',0),
(437,110,1,'POST',1),(438,110,2,'GET',0),(439,110,3,'PUT',0),(440,110,4,'DELETE',0),
(441,111,1,'PUT',1),(442,111,2,'POST',0),(443,111,3,'GET',0),(444,111,4,'DELETE',0),
(445,112,1,'DELETE',1),(446,112,2,'GET',0),(447,112,3,'POST',0),(448,112,4,'PUT',0),
(449,113,1,'GET',1),(450,113,2,'POST',0),(451,113,3,'PUT',0),(452,113,4,'DELETE',0),
(453,114,1,'OK / Success',1),(454,114,2,'Not Found',0),(455,114,3,'Server Error',0),(456,114,4,'Bad Request',0),
(457,115,1,'Not Found',1),(458,115,2,'OK',0),(459,115,3,'Server Error',0),(460,115,4,'Unauthorized',0),
(461,116,1,'Server Error',1),(462,116,2,'Not Found',0),(463,116,3,'OK',0),(464,116,4,'Bad Request',0),
(465,117,1,'JavaScript Object Notation',1),(466,117,2,'Java Standard Object Notation',0),(467,117,3,'JavaScript Ordered Notation',0),(468,117,4,'Java Serialized Object Notation',0),
(469,118,1,'URL path for resource',1),(470,118,2,'Database query',0),(471,118,3,'HTML page',0),(472,118,4,'CSS file',0),
(473,119,1,'Authentication',1),(474,119,2,'Encryption',0),(475,119,3,'Compression',0),(476,119,4,'Validation',0),
(477,120,1,'Cross-Origin Resource Sharing',1),(478,120,2,'Cross-Origin Request Security',0),(479,120,3,'Common Origin Resource Sharing',0),(480,120,4,'Cross-Origin Response System',0);

-- Q121-132: Exam 11 (Physics Mechanics)
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(481,121,1,'Newton',1),(482,121,2,'Joule',0),(483,121,3,'Watt',0),(484,121,4,'Pascal',0),
(485,122,1,'F = ma',1),(486,122,2,'E = mc^2',0),(487,122,3,'P = V^2/R',0),(488,122,4,'F = G(m1m2)/r^2',0),
(489,123,1,'1/2 mv^2',1),(490,123,2,'mgh',0),(491,123,3,'mv',0),(492,123,4,'1/2 kx^2',0),
(493,124,1,'Joule',1),(494,124,2,'Newton',0),(495,124,3,'Watt',0),(496,124,4,'Ampere',0),
(497,125,1,'mass * velocity',1),(498,125,2,'mass * acceleration',0),(499,125,3,'force * time',0),(500,125,4,'mass / velocity',0),
(501,126,1,'Toward center',1),(502,126,2,'Away from center',0),(503,126,3,'Tangent to path',0),(504,126,4,'No direction',0),
(505,127,1,'Resistance to change in motion',1),(506,127,2,'A type of force',0),(507,127,3,'Speed',0),(508,127,4,'Energy',0),
(509,128,1,'mgh',1),(510,128,2,'1/2 mv^2',0),(511,128,3,'mv',0),(512,128,4,'F*d',0),
(513,129,1,'Force and displacement (spring)',1),(514,129,2,'Voltage and current',0),(515,129,3,'Mass and gravity',0),(516,129,4,'Force and area',0),
(517,130,1,'9.8 m/s^2',1),(518,130,2,'12.1 m/s^2',0),(519,130,3,'5.5 m/s^2',0),(520,130,4,'98 m/s^2',0),
(521,131,1,'Motion',1),(522,131,2,'Gravity',0),(523,131,3,'Normal force',0),(524,131,4,'Momentum',0),
(525,132,1,'Rotational force',1),(526,132,2,'Linear force',0),(527,132,3,'Energy',0),(528,132,4,'Power',0);

-- Q133-144: Exam 12 (Physics E&M)
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(529,133,1,'Coulomb',1),(530,133,2,'Ampere',0),(531,133,3,'Volt',0),(532,133,4,'Ohm',0),
(533,134,1,'Force between charges',1),(534,134,2,'Force of gravity',0),(535,134,3,'Magnetic force',0),(536,134,4,'Nuclear force',0),
(537,135,1,'North to South',1),(538,135,2,'South to North',0),(539,135,3,'Positive to Negative',0),(540,135,4,'Negative to Positive',0),
(541,136,1,'Farad',1),(542,136,2,'Henry',0),(543,136,3,'Weber',0),(544,136,4,'Tesla',0),
(545,137,1,'Magnetic field',1),(546,137,2,'Electric field',0),(547,137,3,'Heat',0),(548,137,4,'Light',0),
(549,138,1,'Induced current direction',1),(550,138,2,'Capacitance',0),(551,138,3,'Resistance',0),(552,138,4,'Gravity',0),
(553,139,1,'Repel',1),(554,139,2,'Attract',0),(555,139,3,'Do nothing',0),(556,139,4,'Explode',0),
(557,140,1,'V = IR',1),(558,140,2,'F = ma',0),(559,140,3,'E = mc^2',0),(560,140,4,'P = VI',0),
(561,141,1,'Magnetic force direction',1),(562,141,2,'Electric field strength',0),(563,141,3,'Gravity direction',0),(564,141,4,'Resistance value',0),
(565,142,1,'Weber',1),(566,142,2,'Tesla',0),(567,142,3,'Farad',0),(568,142,4,'Henry',0),
(569,143,1,'Voltage/Current',1),(570,143,2,'Energy type',0),(571,143,3,'Resistance',0),(572,143,4,'Charge',0),
(573,144,1,'Electromagnetism',1),(574,144,2,'Gravity',0),(575,144,3,'Thermodynamics',0),(576,144,4,'Mechanics',0);

-- Q145-156: Exam 13 (Chem Atoms)
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(577,145,1,'Electron',1),(578,145,2,'Proton',0),(579,145,3,'Neutron',0),(580,145,4,'Photon',0),
(581,146,1,'Nucleus',1),(582,146,2,'Electron cloud',0),(583,146,3,'Mitochondria',0),(584,146,4,'Shell',0),
(585,147,1,'Protons',1),(586,147,2,'Neutrons',0),(587,147,3,'Electrons',0),(588,147,4,'Molecules',0),
(589,148,1,'Neutron',1),(590,148,2,'Proton',0),(591,148,3,'Electron',0),(592,148,4,'Ion',0),
(593,149,1,'Neutrons',1),(594,149,2,'Protons',0),(595,149,3,'Electrons',0),(596,149,4,'Atomic number',0),
(597,150,1,'Bohr',1),(598,150,2,'Rutherford',0),(599,150,3,'Dalton',0),(600,150,4,'Thomson',0),
(601,151,1,'+1',1),(602,151,2,'-1',0),(603,151,3,'0',0),(604,151,4,'+2',0),
(605,152,1,'Protons + Neutrons',1),(606,152,2,'Protons + Electrons',0),(607,152,3,'Neutrons + Electrons',0),(608,152,4,'Protons only',0),
(609,153,1,'Outermost shell electrons',1),(610,153,2,'Innermost shell electrons',0),(611,153,3,'Total electrons',0),(612,153,4,'Total protons',0),
(613,154,1,'Noble gases',1),(614,154,2,'Halogens',0),(615,154,3,'Alkali metals',0),(616,154,4,'Alkaline earth metals',0),
(617,155,1,'6.022 x 10^23',1),(618,155,2,'3.14 x 10^8',0),(619,155,3,'9.81 x 10^0',0),(620,155,4,'1.602 x 10^-19',0),
(621,156,1,'Charged atom',1),(622,156,2,'Neutral atom',0),(623,156,3,'Group of atoms',0),(624,156,4,'Isotope',0);

-- Q157-168: Exam 14 (Chem Bonding)
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(625,157,1,'Covalent',1),(626,157,2,'Ionic',0),(627,157,3,'Metallic',0),(628,157,4,'Hydrogen',0),
(629,158,1,'Ionic',1),(630,158,2,'Covalent',0),(631,158,3,'Metallic',0),(632,158,4,'Hydrogen',0),
(633,159,1,'Polar Covalent',1),(634,159,2,'Ionic',0),(635,159,3,'Nonpolar Covalent',0),(636,159,4,'Metallic',0),
(637,160,1,'Ionic',1),(638,160,2,'Covalent',0),(639,160,3,'Metallic',0),(640,160,4,'Hydrogen',0),
(641,161,1,'Metallic',1),(642,161,2,'Ionic',0),(643,161,3,'Covalent',0),(644,161,4,'Hydrogen',0),
(645,162,1,'Atom\'s pull on electrons',1),(646,162,2,'Atom\'s size',0),(647,162,3,'Atom\'s mass',0),(648,162,4,'Atom\'s charge',0),
(649,163,1,'8 valence electrons',1),(650,163,2,'2 valence electrons',0),(651,163,3,'No valence electrons',0),(652,163,4,'8 total electrons',0),
(653,164,1,'Molecular shape',1),(654,164,2,'Atomic mass',0),(655,164,3,'Bond energy',0),(656,164,4,'Reaction speed',0),
(657,165,1,'Intermolecular force',1),(658,165,2,'Intramolecular bond',0),(659,165,3,'Ionic bond',0),(660,165,4,'Covalent bond',0),
(661,166,1,'O2',1),(662,166,2,'H2O',0),(663,166,3,'NaCl',0),(664,166,4,'Fe',0),
(665,167,1,'Unequal sharing of electrons',1),(666,167,2,'Equal sharing of electrons',0),(667,167,3,'Transfer of electrons',0),(668,167,4,'No electrons involved',0),
(669,168,1,'Valence electrons',1),(670,168,2,'Total electrons',0),(671,168,3,'Protons and neutrons',0),(672,168,4,'Molecular orbitals',0);

-- Q169-180: Exam 15 (Microeconomics)
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(673,169,1,'Price up, quantity down',1),(674,169,2,'Price up, quantity up',0),(675,169,3,'Price down, quantity down',0),(676,169,4,'No relation',0),
(677,170,1,'Price up, quantity up',1),(678,170,2,'Price up, quantity down',0),(679,170,3,'Price down, quantity up',0),(680,170,4,'No relation',0),
(681,171,1,'Supply equals demand',1),(682,171,2,'Supply is zero',0),(683,171,3,'Demand is zero',0),(684,171,4,'Price is zero',0),
(685,172,1,'Responsiveness to price change',1),(686,172,2,'Total cost',0),(687,172,3,'Total profit',0),(688,172,4,'Total supply',0),
(689,173,1,'Next best alternative foregone',1),(690,173,2,'Total money spent',0),(691,173,3,'Actual cost',0),(692,173,4,'Variable cost',0),
(693,174,1,'One seller',1),(694,174,2,'Few sellers',0),(695,174,3,'Many sellers',0),(696,174,4,'One buyer',0),
(697,175,1,'Few sellers',1),(698,175,2,'One seller',0),(699,175,3,'Many sellers',0),(700,175,4,'One buyer',0),
(701,176,1,'Many sellers, identical products',1),(702,176,2,'One seller',0),(703,176,3,'Few sellers',0),(704,176,4,'Many sellers, different products',0),
(705,177,1,'Satisfaction',1),(706,177,2,'Price',0),(707,177,3,'Cost',0),(708,177,4,'Quantity',0),
(709,178,1,'Limited resources, unlimited wants',1),(710,178,2,'Unlimited resources',0),(711,178,3,'Limited wants',0),(712,178,4,'Low prices',0),
(713,179,1,'Man-made goods for production',1),(714,179,2,'Money',0),(715,179,3,'Labor',0),(716,179,4,'Land',0),
(717,180,1,'Adding input yields less output',1),(718,180,2,'Adding input yields more output',0),(719,180,3,'Adding input yields constant output',0),(720,180,4,'No inputs',0);

-- Q181-192: Exam 16 (Macroeconomics)
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(721,181,1,'Gross Domestic Product',1),(722,181,2,'General Domestic Price',0),(723,181,3,'Gross Domestic Price',0),(724,181,4,'General Domestic Product',0),
(725,182,1,'General price level rise',1),(726,182,2,'General price level fall',0),(727,182,3,'GDP rise',0),(728,182,4,'GDP fall',0),
(729,183,1,'General price level fall',1),(730,183,2,'General price level rise',0),(731,183,3,'GDP rise',0),(732,183,4,'GDP fall',0),
(733,184,1,'Money supply',1),(734,184,2,'Government spending',0),(735,184,3,'Taxes',0),(736,184,4,'All businesses',0),
(737,185,1,'Central bank actions (money supply)',1),(738,185,2,'Government spending/tax',0),(739,185,3,'International trade rules',0),(740,185,4,'Stock market rules',0),
(741,186,1,'Government spending/tax',1),(742,186,2,'Central bank actions (money supply)',0),(743,186,3,'International trade rules',0),(744,186,4,'Stock market rules',0),
(745,187,1,'% of labor force jobless',1),(746,187,2,'% of population jobless',0),(747,187,3,'Total people jobless',0),(748,187,4,'Total people working',0),
(749,188,1,'GDP decline (2 quarters)',1),(750,188,2,'GDP rise',0),(751,188,3,'Inflation rise',0),(752,188,4,'Stock market crash',0),
(753,189,1,'Price of one currency vs another',1),(754,189,2,'Interest rate',0),(755,189,3,'Tax rate',0),(756,189,4,'Inflation rate',0),
(757,190,1,'Aggregate demand',1),(758,190,2,'Aggregate supply',0),(759,190,3,'Lower taxes',0),(760,190,4,'Free markets only',0),
(761,191,1,'Tax on imports',1),(762,191,2,'Tax on exports',0),(763,191,3,'Limit on imports',0),(764,191,4,'Ban on imports',0),
(765,192,1,'Aggregate supply',1),(766,192,2,'Aggregate demand',0),(767,192,3,'Government spending',0),(768,192,4,'Money supply',0);

-- Q193-204: Exam 17 (Ancient History)
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(769,193,1,'Tigris and Euphrates',1),(770,193,2,'Nile and Congo',0),(771,193,3,'Indus and Ganges',0),(772,193,4,'Yellow and Yangtze',0),
(773,194,1,'Hieroglyphics',1),(774,194,2,'Cuneiform',0),(775,194,3,'Alphabet',0),(776,194,4,'Sanskrit',0),
(777,195,1,'Augustus (Octavian)',1),(778,195,2,'Julius Caesar',0),(779,195,3,'Alexander the Great',0),(780,195,4,'Pericles',0),
(781,196,1,'Athens, Greece',1),(782,196,2,'Rome, Italy',0),(783,196,3,'Sparta, Greece',0),(784,196,4,'Egypt',0),
(785,197,1,'A legal code',1),(786,197,2,'An epic poem',0),(787,197,3,'A religious text',0),(788,197,4,'A pyramid design',0),
(789,198,1,'Athens and Sparta',1),(790,198,2,'Rome and Carthage',0),(791,198,3,'Greece and Persia',0),(792,198,4,'Egypt and Hittites',0),
(793,199,1,'Tombs for Pharaohs',1),(794,199,2,'Temples',0),(795,199,3,'Palaces',0),(796,199,4,'Fortresses',0),
(797,200,1,'Aristotle',1),(798,200,2,'Plato',0),(799,200,3,'Socrates',0),(800,200,4,'Homer',0),
(801,201,1,'Modern Pakistan/India',1),(802,201,2,'Modern China',0),(803,201,3,'Modern
Egypt',0),(804,201,4,'Modern
Peru',0),
(805,202,1,'Defense',1),(806,202,2,'Trade route',0),(807,202,3,'Religious symbol',0),(808,202,4,'Flood control',0),
(809,203,1,'Augustus',1),(810,203,2,'Julius Caesar',0),(811,203,3,'Nero',0),(812,203,4,'Constantine',0),
(813,204,1,'476 AD',1),(814,204,2,'1453 AD',0),(815,204,3,'1066 AD',0),(816,204,4,'30 BC',0);

-- Q205-216: Exam 18 (Modern History)
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(817,205,1,'Rebirth',1),(818,205,2,'Revolt',0),(819,205,3,'Reform',0),(820,205,4,'Return',0),
(821,206,1,'Martin Luther',1),(822,206,2,'Henry VIII',0),(823,206,3,'John Calvin',0),(824,206,4,'The Pope',0),
(825,207,1,'Great Britain',1),(826,207,2,'France',0),(827,207,3,'Germany',0),(828,207,4,'USA',0),
(829,208,1,'1914',1),(830,208,2,'1918',0),(831,208,3,'1905',0),(832,208,4,'1920',0),
(833,209,1,'1939',1),(834,209,2,'1945',0),(835,209,3,'1936',0),(836,209,4,'1941',0),
(837,210,1,'USA and Soviet Union',1),(838,210,2,'USA and China',0),(839,210,3,'UK and Germany',0),(840,210,4,'France and Russia',0),
(841,211,1,'Liberty, Equality, Fraternity',1),(842,211,2,'Life, Liberty, Pursuit of Happiness',0),(843,211,3,'No taxation without representation',0),(844,211,4,'Workers of the world, unite!',0),
(845,212,1,'1776',1),(846,212,2,'1789',0),(847,212,3,'1812',0),(848,212,4,'1765',0),
(849,213,1,'Gutenberg',1),(850,213,2,'Da Vinci',0),(851,213,3,'Martin Luther',0),(852,213,4,'Columbus',0),
(853,214,1,'1989',1),(854,214,2,'1991',0),(855,214,3,'1961',0),(856,214,4,'1945',0),
(857,215,1,'South Africa',1),(858,215,2,'India',0),(859,215,3,'Soviet Union',0),(860,215,4,'USA',0),
(861,216,1,'United Nations',1),(862,216,2,'NATO',0),(863,216,3,'Warsaw Pact',0),(864,216,4,'European Union',0);

-- Q217-228: Exam 19 (AI Search)
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(865,217,1,'Breadth-First Search',1),(866,217,2,'Depth-First Search',0),(867,217,3,'Best-First Search',0),(868,217,4,'Binary-First Search',0),
(869,218,1,'Depth-First Search',1),(870,218,2,'Breadth-First Search',0),(871,218,3,'Data-First Search',0),(872,218,4,'Dijkstra-First Search',0),
(873,219,1,'BFS (unweighted) / Dijkstra (weighted)',1),(874,219,2,'DFS',0),(875,219,3,'Hill Climbing',0),(876,219,4,'Greedy Best-First',0),
(877,220,1,'BFS',1),(878,220,2,'DFS',0),(879,220,3,'A*',0),(880,220,4,'Hill Climbing',0),
(881,221,1,'DFS',1),(882,221,2,'BFS',0),(883,221,3,'A*',0),(884,221,4,'Dijkstra',0),
(885,222,1,'g(n) + h(n)',1),(886,222,2,'h(n) only',0),(887,222,3,'g(n) only',0),(888,222,4,'random()',0),
(889,223,1,'Cost to goal',1),(890,223,2,'Cost from start',0),(891,223,3,'Exact cost',0),(892,223,4,'Node depth',0),
(893,224,1,'No info on goal distance',1),(894,224,2,'Uses heuristic',0),(895,224,3,'Always optimal',0),(896,224,4,'Very fast',0),
(897,225,1,'Uses heuristic (info on goal)',1),(898,225,2,'No info on goal distance',0),(899,225,3,'Always complete',0),(900,225,4,'Very slow',0),
(901,226,1,'Shortest path (weighted graph)',1),(902,226,2,'Longest path',0),(903,226,3,'Any path',0),(904,226,4,'MST',0),
(905,227,1,'Local optimum',1),(906,227,2,'Global optimum',0),(907,227,3,'Start node',0),(908,227,4,'End node',0),
(909,228,1,'Two-player games',1),(910,228,2,'Pathfinding',0),(911,228,3,'Sorting',0),(912,228,4,'Clustering',0);

-- Q229-240: Exam 20 (AI ML Intro)
INSERT INTO Choices (ChoiceID, QuestionID, ChoiceNo, ChoiceText, IsCorrect) VALUES
(913,229,1,'Machine Learning',1),(914,229,2,'Mainframe Logic',0),(915,229,3,'Meta Learning',0),(916,229,4,'Maximum Logic',0),
(917,230,1,'Labeled data',1),(918,230,2,'Unlabeled data',0),(919,230,3,'No data',0),(920,230,4,'Rewards',0),
(921,231,1,'Patterns in unlabeled data',1),(922,231,2,'Predictions from labeled data',0),(923,231,3,'Rewards from actions',0),(924,231,4,'Correct answers',0),
(925,232,1,'Spam vs Not Spam',1),(926,232,2,'Predicting house price',0),(927,232,3,'Grouping customers',0),(928,232,4,'Playing chess',0),
(929,233,1,'Predicting house price',1),(930,233,2,'Spam vs Not Spam',0),(931,233,3,'Grouping customers',0),(932,233,4,'Playing chess',0),
(933,234,1,'Clustering (Unsupervised)',1),(934,234,2,'Classification (Supervised)',0),(935,234,3,'Regression (Supervised)',0),(936,234,4,'Reinforcement',0),
(937,235,1,'Supervised learning model',1),(938,235,2,'Unsupervised learning model',0),(939,235,3,'Reinforcement model',0),(940,235,4,'A database',0),
(941,236,1,'Human brain',1),(942,236,2,'Computer circuits',0),(943,236,3,'Decision trees',0),(944,236,4,'Physics',0),
(945,237,1,'Model too complex, fits noise',1),(946,237,2,'Model too simple',0),(947,237,3,'Model is perfect',0),(948,237,4,'Not enough data',0),
(949,238,1,'Training the model',1),(950,238,2,'Evaluating the model',0),(951,238,3,'Validating hyperparameters',0),(952,238,4,'Final deployment',0),
(953,239,1,'Evaluating model performance',1),(954,239,2,'Training the model',0),(955,239,3,'Finding patterns',0),(956,239,4,'Gathering data',0),
(957,240,1,'Rewards and punishments',1),(958,240,2,'Labeled data',0),(959,240,3,'Unlabeled data',0),(960,240,4,'No data',0);

-- -------------------------------
-- ExamAttempts (14)
-- -------------------------------
DELETE FROM ExamAttempts;
INSERT INTO ExamAttempts (AttemptID, ExamID, StudentID, Status, Score, TotalPoints, Percentage, SubmitTime, CreatedAt) VALUES
(1,1,11,'submitted',10,12,83.33,'2025-10-15 09:10:00',NOW()),
(2,1,12,'submitted',12,12,100.00,'2025-10-15 09:30:00',NOW()),
(3,2,13,'submitted',8,12,66.67,'2025-10-16 10:20:00',NOW()),
(4,3,11,'submitted',9,12,75.00,'2025-10-17 11:05:00',NOW()),
(5,5,12,'submitted',11,12,91.67,'2025-10-18 14:15:00',NOW()),
(6,9,13,'submitted',7,12,58.33,'2025-10-19 15:30:00',NOW()),
(7,10,11,'submitted',10,12,83.33,'2025-10-20 16:00:00',NOW()),
(8,6,12,'submitted',12,12,100.00,'2025-10-21 10:00:00',NOW()),
(9,11,11,'submitted',10,12,83.33,'2025-10-22 09:00:00',NOW()),
(10,13,12,'submitted',12,12,100.00,'2025-10-22 10:00:00',NOW()),
(11,15,13,'submitted',8,12,66.67,'2025-10-23 11:00:00',NOW()),
(12,17,11,'submitted',9,12,75.00,'2025-10-23 14:00:00',NOW()),
(13,19,12,'submitted',11,12,91.67,'2025-10-24 15:00:00',NOW()),
(14,20,13,'submitted',10,12,83.33,'2025-10-25 10:00:00',NOW());

-- -------------------------------
-- StudentAnswers (168)
-- -------------------------------
DELETE FROM StudentAnswers;
-- ... (ส่วน StudentAnswers ทั้งหมด เหมือนเดิม ไม่มีการเปลี่ยนแปลง) ...
-- Attempt 1: Exam 1, Student 11, Score 10/12 (Q1-12)
INSERT INTO StudentAnswers (AnswerID, AttemptID, QuestionID, ChoiceID, AnswerText, IsCorrect, PointsEarned) VALUES
(1,1,1,1,NULL,1,1),(2,1,2,5,NULL,1,1),(3,1,3,9,NULL,1,1),(4,1,4,13,NULL,1,1),
(5,1,5,17,NULL,1,1),(6,1,6,22,NULL,0,0),(7,1,7,25,NULL,1,1),(8,1,8,29,NULL,1,1),
(9,1,9,33,NULL,1,1),(10,1,10,37,NULL,1,1),(11,1,11,42,NULL,0,0),(12,1,12,45,NULL,1,1);

-- Attempt 2: Exam 1, Student 12, Score 12/12 (Q1-12)
INSERT INTO StudentAnswers (AnswerID, AttemptID, QuestionID, ChoiceID, AnswerText, IsCorrect, PointsEarned) VALUES
(13,2,1,1,NULL,1,1),(14,2,2,5,NULL,1,1),(15,2,3,9,NULL,1,1),(16,2,4,13,NULL,1,1),
(17,2,5,17,NULL,1,1),(18,2,6,21,NULL,1,1),(19,2,7,25,NULL,1,1),(20,2,8,29,NULL,1,1),
(21,2,9,33,NULL,1,1),(22,2,10,37,NULL,1,1),(23,2,11,41,NULL,1,1),(24,2,12,45,NULL,1,1);

-- Attempt 3: Exam 2, Student 13, Score 8/12 (Q13-24)
INSERT INTO StudentAnswers (AnswerID, AttemptID, QuestionID, ChoiceID, AnswerText, IsCorrect, PointsEarned) VALUES
(25,3,13,49,NULL,1,1),(26,3,14,54,NULL,0,0),(27,3,15,57,NULL,1,1),(28,3,16,61,NULL,1,1),
(29,3,17,65,NULL,1,1),(30,3,18,70,NULL,0,0),(31,3,19,73,NULL,1,1),(32,3,20,78,NULL,0,0),
(33,3,21,81,NULL,1,1),(34,3,22,85,NULL,1,1),(35,3,23,90,NULL,0,0),(36,3,24,93,NULL,1,1);

-- Attempt 4: Exam 3, Student 11, Score 9/12 (Q25-36)
INSERT INTO StudentAnswers (AnswerID, AttemptID, QuestionID, ChoiceID, AnswerText, IsCorrect, PointsEarned) VALUES
(37,4,25,97,NULL,1,1),(38,4,26,101,NULL,1,1),(39,4,27,106,NULL,0,0),(40,4,28,109,NULL,1,1),
(41,4,29,113,NULL,1,1),(42,4,30,117,NULL,1,1),(43,4,31,122,NULL,0,0),(44,4,32,125,NULL,1,1),
(45,4,33,129,NULL,1,1),(46,4,34,133,NULL,1,1),(47,4,35,138,NULL,0,0),(48,4,36,141,NULL,1,1);

-- Attempt 5: Exam 5, Student 12, Score 11/12 (Q49-60)
INSERT INTO StudentAnswers (AnswerID, AttemptID, QuestionID, ChoiceID, AnswerText, IsCorrect, PointsEarned) VALUES
(49,5,49,193,NULL,1,1),(50,5,50,197,NULL,1,1),(51,5,51,201,NULL,1,1),(52,5,52,205,NULL,1,1),
(53,5,53,209,NULL,1,1),(54,5,54,213,NULL,1,1),(55,5,55,217,NULL,1,1),(56,5,56,221,NULL,1,1),
(57,5,57,225,NULL,1,1),(58,5,58,229,NULL,1,1),(59,5,59,234,NULL,0,0),(60,5,60,237,NULL,1,1);

-- Attempt 6: Exam 9, Student 13, Score 7/12 (Q97-108)
INSERT INTO StudentAnswers (AnswerID, AttemptID, QuestionID, ChoiceID, AnswerText, IsCorrect, PointsEarned) VALUES
(61,6,97,385,NULL,1,1),(62,6,98,390,NULL,0,0),(63,6,99,393,NULL,1,1),(64,6,100,398,NULL,0,0),
(65,6,101,401,NULL,1,1),(66,6,102,406,NULL,0,0),(67,6,103,409,NULL,1,1),(68,6,104,413,NULL,1,1),
(69,6,105,418,NULL,0,0),(70,6,106,421,NULL,1,1),(71,6,107,426,NULL,0,0),(72,6,108,429,NULL,1,1);

-- Attempt 7: Exam 10, Student 11, Score 10/12 (Q109-120)
INSERT INTO StudentAnswers (AnswerID, AttemptID, QuestionID, ChoiceID, AnswerText, IsCorrect, PointsEarned) VALUES
(73,7,109,433,NULL,1,1),(74,7,110,437,NULL,1,1),(75,7,111,441,NULL,1,1),(76,7,112,445,NULL,1,1),
(77,7,113,449,NULL,1,1),(78,7,114,453,NULL,1,1),(79,7,115,458,NULL,0,0),(80,7,116,461,NULL,1,1),
(81,7,117,465,NULL,1,1),(82,7,118,469,NULL,1,1),(83,7,119,474,NULL,0,0),(84,7,120,477,NULL,1,1);

-- Attempt 8: Exam 6, Student 12, Score 12/12 (Q61-72)
INSERT INTO StudentAnswers (AnswerID, AttemptID, QuestionID, ChoiceID, AnswerText, IsCorrect, PointsEarned) VALUES
(85,8,61,241,NULL,1,1),(86,8,62,245,NULL,1,1),(87,8,63,249,NULL,1,1),(88,8,64,253,NULL,1,1),
(89,8,65,257,NULL,1,1),(90,8,66,261,NULL,1,1),(91,8,67,265,NULL,1,1),(92,8,68,269,NULL,1,1),
(93,8,69,273,NULL,1,1),(94,8,70,277,NULL,1,1),(95,8,71,281,NULL,1,1),(96,8,72,285,NULL,1,1);

-- Attempt 9: Exam 11 (Physics), Student 11, Score 10/12 (Q121-132)
INSERT INTO StudentAnswers (AnswerID, AttemptID, QuestionID, ChoiceID, AnswerText, IsCorrect, PointsEarned) VALUES
(97,9,121,481,NULL,1,1),(98,9,122,485,NULL,1,1),(99,9,123,489,NULL,1,1),(100,9,124,493,NULL,1,1),
(101,9,125,497,NULL,1,1),(102,9,126,502,NULL,0,0),(103,9,127,505,NULL,1,1),(104,9,128,509,NULL,1,1),
(105,9,129,513,NULL,1,1),(106,9,130,517,NULL,1,1),(107,9,131,522,NULL,0,0),(108,9,132,525,NULL,1,1);

-- Attempt 10: Exam 13 (Chem Atoms), Student 12, Score 12/12 (Q145-156)
INSERT INTO StudentAnswers (AnswerID, AttemptID, QuestionID, ChoiceID, AnswerText, IsCorrect, PointsEarned) VALUES
(109,10,145,577,NULL,1,1),(110,10,146,581,NULL,1,1),(111,10,147,585,NULL,1,1),(112,10,148,589,NULL,1,1),
(113,10,149,593,NULL,1,1),(114,10,150,597,NULL,1,1),(115,10,151,601,NULL,1,1),(116,10,152,605,NULL,1,1),
(117,10,153,609,NULL,1,1),(118,10,154,613,NULL,1,1),(119,10,155,617,NULL,1,1),(120,10,156,621,NULL,1,1);

-- Attempt 11: Exam 15 (Microecon), Student 13, Score 8/12 (Q169-180)
INSERT INTO StudentAnswers (AnswerID, AttemptID, QuestionID, ChoiceID, AnswerText, IsCorrect, PointsEarned) VALUES
(121,11,169,673,NULL,1,1),(122,11,170,678,NULL,0,0),(123,11,171,681,NULL,1,1),(124,11,172,685,NULL,1,1),
(125,11,173,689,NULL,1,1),(126,11,174,694,NULL,0,0),(127,11,175,697,NULL,1,1),(128,11,176,701,NULL,1,1),
(129,11,177,706,NULL,0,0),(130,11,178,709,NULL,1,1),(131,11,179,713,NULL,1,1),(132,11,180,718,NULL,0,0);

-- Attempt 12: Exam 17 (Ancient History), Student 11, Score 9/12 (Q193-204)
INSERT INTO StudentAnswers (AnswerID, AttemptID, QuestionID, ChoiceID, AnswerText, IsCorrect, PointsEarned) VALUES
(133,12,193,769,NULL,1,1),(134,12,194,773,NULL,1,1),(135,12,195,778,NULL,0,0),(136,12,196,781,NULL,1,1),
(137,12,197,785,NULL,1,1),(138,12,198,789,NULL,1,1),(139,12,199,793,NULL,1,1),(140,12,200,798,NULL,0,0),
(141,12,201,801,NULL,1,1),(142,12,202,805,NULL,1,1),(143,12,203,809,NULL,1,1),(144,12,204,814,NULL,0,0);

-- Attempt 13: Exam 19 (AI Search), Student 12, Score 11/12 (Q217-228)
INSERT INTO StudentAnswers (AnswerID, AttemptID, QuestionID, ChoiceID, AnswerText, IsCorrect, PointsEarned) VALUES
(145,13,217,865,NULL,1,1),(146,13,218,869,NULL,1,1),(147,13,219,873,NULL,1,1),(148,13,220,877,NULL,1,1),
(149,13,221,881,NULL,1,1),(150,13,222,885,NULL,1,1),(151,13,223,889,NULL,1,1),(152,13,224,893,NULL,1,1),
(153,13,225,897,NULL,1,1),(154,13,226,901,NULL,1,1),(155,13,227,906,NULL,0,0),(156,13,228,909,NULL,1,1);

-- Attempt 14: Exam 20 (AI ML Intro), Student 13, Score 10/12 (Q229-240)
INSERT INTO StudentAnswers (AnswerID, AttemptID, QuestionID, ChoiceID, AnswerText, IsCorrect, PointsEarned) VALUES
(157,14,229,913,NULL,1,1),(158,14,230,917,NULL,1,1),(159,14,231,921,NULL,1,1),(160,14,232,925,NULL,1,1),
(161,14,233,929,NULL,1,1),(162,14,234,934,NULL,0,0),(163,14,235,937,NULL,1,1),(164,14,236,941,NULL,1,1),
(165,14,237,946,NULL,0,0),(166,14,238,949,NULL,1,1),(167,14,239,953,NULL,1,1),(168,14,240,957,NULL,1,1);


SET FOREIGN_KEY_CHECKS = 1;

-- ================================================================
-- Login Credentials Summary:
-- ================================================================
-- Username: admin     | Password: password123 | Role: instructor
-- Username: teacher   | Password: password123 | Role: instructor
-- Username: student1  | Password: password123 | Role: student
-- Username: student2  | Password: password123 | Role: student
-- Username: student3  | Password: password123 | Role: student
-- ================================================================