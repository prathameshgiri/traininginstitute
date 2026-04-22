-- ============================================================
-- TRAINING INSTITUTE PORTAL - COMPLETE DATABASE SCHEMA
-- Designed and compiled by Dr. Geeta Mete
-- ============================================================

DROP DATABASE IF EXISTS training_institute_db;
CREATE DATABASE training_institute_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE training_institute_db;

-- ============================================================
-- 1. USERS TABLE - Authentication & Role Management
-- ============================================================
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('ADMIN','STUDENT') NOT NULL,
    is_logged_in BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_role (role)
);

-- ============================================================
-- 2. STUDENTS TABLE - Student Profile & Academic Info
-- ============================================================
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNIQUE NOT NULL,
    course VARCHAR(100) NOT NULL,
    cgpa DECIMAL(3,2) NOT NULL CHECK (cgpa BETWEEN 0.00 AND 10.00),
    phone VARCHAR(15) UNIQUE,
    address TEXT,
    profile_pic VARCHAR(255),
    skills TEXT,
    resume_path VARCHAR(255),
    enrollment_number VARCHAR(50) UNIQUE,
    batch_year INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_cgpa (cgpa),
    INDEX idx_course (course)
);

-- ============================================================
-- 3. COMPANIES TABLE
-- ============================================================
CREATE TABLE companies (
    company_id INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(150) NOT NULL,
    location VARCHAR(100) NOT NULL,
    industry VARCHAR(100),
    website VARCHAR(255),
    contact_email VARCHAR(100),
    contact_person VARCHAR(100),
    description TEXT,
    eligibility_cgpa DECIMAL(3,2) NOT NULL CHECK (eligibility_cgpa BETWEEN 0.00 AND 10.00),
    logo_path VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_eligibility (eligibility_cgpa)
);

-- ============================================================
-- 4. INTERNSHIPS TABLE
-- ============================================================
CREATE TABLE internships (
    internship_id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    role VARCHAR(100) NOT NULL,
    description TEXT,
    stipend DECIMAL(10,2) CHECK (stipend >= 0),
    duration_months INT CHECK (duration_months > 0),
    deadline DATE NOT NULL,
    seats INT DEFAULT 1 CHECK (seats > 0),
    location VARCHAR(100),
    skills_required TEXT,
    eligibility_cgpa DECIMAL(3,2) CHECK (eligibility_cgpa BETWEEN 0.00 AND 10.00),
    status ENUM('OPEN','CLOSED','ARCHIVED') DEFAULT 'OPEN',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(company_id) ON DELETE CASCADE,
    INDEX idx_deadline (deadline),
    INDEX idx_status (status)
);

-- ============================================================
-- 5. APPLICATIONS TABLE
-- ============================================================
CREATE TABLE applications (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    internship_id INT NOT NULL,
    status ENUM('APPLIED','SHORTLISTED','REJECTED','SELECTED','CONFIRMED') DEFAULT 'APPLIED',
    cover_letter TEXT,
    applied_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_date TIMESTAMP NULL,
    reviewed_by INT NULL,
    remarks TEXT,
    UNIQUE KEY uq_student_internship (student_id, internship_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (internship_id) REFERENCES internships(internship_id) ON DELETE CASCADE,
    FOREIGN KEY (reviewed_by) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_status (status),
    INDEX idx_student (student_id),
    INDEX idx_internship (internship_id)
);

-- ============================================================
-- 6. APPLICATION_LOGS TABLE
-- ============================================================
CREATE TABLE application_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    action VARCHAR(100) NOT NULL,
    performed_by INT,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    remarks TEXT,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (application_id) REFERENCES applications(application_id) ON DELETE CASCADE,
    FOREIGN KEY (performed_by) REFERENCES users(user_id) ON DELETE SET NULL
);

-- ============================================================
-- 7. EXAMS TABLE
-- ============================================================
CREATE TABLE exams (
    exam_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_name VARCHAR(150) NOT NULL,
    description TEXT,
    duration INT NOT NULL CHECK (duration > 0),   -- in minutes
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    total_marks INT CHECK (total_marks > 0),
    passing_marks INT CHECK (passing_marks > 0),
    internship_id INT,
    status ENUM('SCHEDULED','ACTIVE','COMPLETED','CANCELLED') DEFAULT 'SCHEDULED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT,
    FOREIGN KEY (internship_id) REFERENCES internships(internship_id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL
);

-- ============================================================
-- 8. QUESTIONS TABLE
-- ============================================================
CREATE TABLE questions (
    question_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_id INT NOT NULL,
    question_text TEXT NOT NULL,
    type ENUM('MCQ','SUBJECTIVE') NOT NULL,
    marks INT NOT NULL CHECK (marks > 0),
    difficulty ENUM('EASY','MEDIUM','HARD') DEFAULT 'MEDIUM',
    sequence_no INT,
    image_path VARCHAR(255),
    FOREIGN KEY (exam_id) REFERENCES exams(exam_id) ON DELETE CASCADE,
    INDEX idx_exam_id (exam_id),
    INDEX idx_type (type)
);

-- ============================================================
-- 9. OPTIONS TABLE (For MCQ)
-- ============================================================
CREATE TABLE options (
    option_id INT PRIMARY KEY AUTO_INCREMENT,
    question_id INT NOT NULL,
    option_text VARCHAR(255) NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    option_label CHAR(1),   -- A, B, C, D
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE,
    INDEX idx_question_id (question_id)
);

-- ============================================================
-- 10. EXAM_ATTEMPTS TABLE
-- ============================================================
CREATE TABLE exam_attempts (
    attempt_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    exam_id INT NOT NULL,
    application_id INT,
    start_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    end_time DATETIME NULL,
    submit_time DATETIME NULL,
    status ENUM('IN_PROGRESS','SUBMITTED','AUTO_SUBMITTED','ABANDONED') DEFAULT 'IN_PROGRESS',
    total_score DECIMAL(6,2) DEFAULT 0,
    mcq_score DECIMAL(6,2) DEFAULT 0,
    subjective_score DECIMAL(6,2) DEFAULT 0,
    is_passed BOOLEAN DEFAULT FALSE,
    ip_address VARCHAR(50),
    tab_switch_count INT DEFAULT 0,
    resume_token VARCHAR(100),
    evaluated BOOLEAN DEFAULT FALSE,
    UNIQUE KEY uq_user_exam (user_id, exam_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (exam_id) REFERENCES exams(exam_id) ON DELETE CASCADE,
    FOREIGN KEY (application_id) REFERENCES applications(application_id) ON DELETE SET NULL,
    INDEX idx_status (status)
);

-- ============================================================
-- 11. ANSWERS TABLE
-- ============================================================
CREATE TABLE answers (
    answer_id INT PRIMARY KEY AUTO_INCREMENT,
    attempt_id INT NOT NULL,
    question_id INT NOT NULL,
    selected_option INT NULL,
    descriptive_answer TEXT NULL,
    is_marked_review BOOLEAN DEFAULT FALSE,
    is_skipped BOOLEAN DEFAULT FALSE,
    marks_awarded DECIMAL(5,2) DEFAULT 0,
    evaluated_by INT NULL,
    evaluated_at TIMESTAMP NULL,
    answer_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_attempt_question (attempt_id, question_id),
    FOREIGN KEY (attempt_id) REFERENCES exam_attempts(attempt_id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE,
    FOREIGN KEY (selected_option) REFERENCES options(option_id) ON DELETE SET NULL,
    FOREIGN KEY (evaluated_by) REFERENCES users(user_id) ON DELETE SET NULL
);

-- ============================================================
-- 12. AUDIT_LOGS TABLE - Security & Suspicious Activity
-- ============================================================
CREATE TABLE audit_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NULL,
    action VARCHAR(255) NOT NULL,
    action_type ENUM('LOGIN','LOGOUT','TAB_SWITCH','EXAM_START','EXAM_SUBMIT',
                     'APPLICATION','PROFILE_UPDATE','ADMIN_ACTION','SECURITY_ALERT','OTHER') DEFAULT 'OTHER',
    ip_address VARCHAR(50),
    user_agent VARCHAR(500),
    session_id VARCHAR(150),
    additional_data TEXT,
    severity ENUM('INFO','WARNING','CRITICAL') DEFAULT 'INFO',
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_action_type (action_type),
    INDEX idx_log_time (log_time),
    INDEX idx_severity (severity)
);

-- ============================================================
-- 13. SESSION_TRACKING TABLE - Advanced Security
-- ============================================================
CREATE TABLE session_tracking (
    session_id VARCHAR(150) PRIMARY KEY,
    user_id INT UNIQUE NOT NULL,
    ip_address VARCHAR(50),
    user_agent VARCHAR(500),
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_active (is_active)
);

-- ============================================================
-- SAMPLE DATA INSERTION
-- ============================================================

-- Default Admin User (password: Admin@123)
INSERT INTO users (name, email, password, role) VALUES
('Administrator', 'admin@traininginstitute.com', '$2a$10$fPHyIeAPoeRd5OWtO/jyneyTExBr4eN4fx4mKQNPUGnCnsd336JxO', 'ADMIN'),
('Dr. Geeta Mete', 'geeta.mete@traininginstitute.com', '$2a$10$fPHyIeAPoeRd5OWtO/jyneyTExBr4eN4fx4mKQNPUGnCnsd336JxO', 'ADMIN');

-- Sample Students (password: Student@123)
INSERT INTO users (name, email, password, role) VALUES
('Aarvi Kulkarni', 'aarvi.kulkarni@student.com', '$2a$10$Q0AQwpDsgqmdz3jYHimuOuAmn9c1EZTK8CypSC4EDHo0/lg.gApHO', 'STUDENT'),
('Rahul Sharma', 'rahul.sharma@student.com', '$2a$10$Q0AQwpDsgqmdz3jYHimuOuAmn9c1EZTK8CypSC4EDHo0/lg.gApHO', 'STUDENT'),
('Priya Patel', 'priya.patel@student.com', '$2a$10$Q0AQwpDsgqmdz3jYHimuOuAmn9c1EZTK8CypSC4EDHo0/lg.gApHO', 'STUDENT'),
('Amit Desai', 'amit.desai@student.com', '$2a$10$Q0AQwpDsgqmdz3jYHimuOuAmn9c1EZTK8CypSC4EDHo0/lg.gApHO', 'STUDENT'),
('Sneha Joshi', 'sneha.joshi@student.com', '$2a$10$Q0AQwpDsgqmdz3jYHimuOuAmn9c1EZTK8CypSC4EDHo0/lg.gApHO', 'STUDENT');

INSERT INTO students (user_id, course, cgpa, phone, enrollment_number, batch_year) VALUES
(3, 'B.Tech Computer Science', 8.75, '9876543210', 'EN2024001', 2024),
(4, 'B.Tech Information Technology', 7.90, '9876543211', 'EN2024002', 2024),
(5, 'MCA', 9.10, '9876543212', 'EN2024003', 2024),
(6, 'B.Tech Electronics', 6.80, '9876543213', 'EN2024004', 2024),
(7, 'B.Sc Computer Science', 8.20, '9876543214', 'EN2024005', 2024);

-- Sample Companies
INSERT INTO companies (company_name, location, industry, website, contact_email, contact_person, eligibility_cgpa) VALUES
('TechVision Solutions Pvt. Ltd.', 'Pune, Maharashtra', 'Software Development', 'www.techvision.com', 'hr@techvision.com', 'Ms. Kavita Sharma', 7.50),
('InnovateTech India', 'Bangalore, Karnataka', 'Artificial Intelligence', 'www.innovatetech.in', 'careers@innovatetech.in', 'Mr. Rajesh Kumar', 8.00),
('DataAxis Analytics', 'Mumbai, Maharashtra', 'Data Analytics', 'www.dataaxis.com', 'internships@dataaxis.com', 'Mr. Vinod Patil', 7.00),
('CloudSky Technologies', 'Hyderabad, Telangana', 'Cloud Computing', 'www.cloudsky.io', 'hr@cloudsky.io', 'Ms. Anita Reddy', 8.50),
('CyberShield Systems', 'Chennai, Tamil Nadu', 'Cybersecurity', 'www.cybershield.com', 'talent@cybershield.com', 'Mr. Suresh Nair', 7.50);

-- Sample Internships
INSERT INTO internships (company_id, role, description, stipend, duration_months, deadline, seats, location, skills_required, eligibility_cgpa) VALUES
(1, 'Full Stack Developer Intern', 'Work on enterprise web applications using Java and React', 15000.00, 6, '2026-05-30', 5, 'Pune', 'Java, React, MySQL, Spring Boot', 7.50),
(2, 'Machine Learning Intern', 'Develop ML models for NLP and Computer Vision projects', 20000.00, 3, '2026-05-15', 3, 'Bangalore', 'Python, TensorFlow, ML Algorithms', 8.00),
(3, 'Data Analyst Intern', 'Analyze large datasets and create business intelligence reports', 12000.00, 4, '2026-06-15', 4, 'Mumbai', 'SQL, Python, Tableau, Excel', 7.00),
(4, 'Cloud Engineer Intern', 'Deploy and manage cloud infrastructure on AWS/Azure', 18000.00, 6, '2026-05-20', 2, 'Hyderabad', 'AWS, Docker, Linux, Networking', 8.50),
(5, 'Security Analyst Intern', 'Perform vulnerability assessments and penetration testing', 16000.00, 3, '2026-06-01', 3, 'Chennai', 'Network Security, Python, Kali Linux', 7.50);

-- Sample Exam
INSERT INTO exams (exam_name, description, duration, start_time, end_time, total_marks, passing_marks, internship_id, status, created_by) VALUES
('Full Stack Developer Certification Exam', 'Technical assessment for Full Stack Developer internship at TechVision Solutions', 90, '2026-05-10 10:00:00', '2026-05-10 11:30:00', 100, 60, 1, 'SCHEDULED', 1),
('ML Engineer Certification Exam', 'Technical assessment covering Python, ML algorithms and model deployment', 60, '2026-05-12 14:00:00', '2026-05-12 15:00:00', 50, 30, 2, 'SCHEDULED', 1);

-- Sample Questions for Exam 1
INSERT INTO questions (exam_id, question_text, type, marks, difficulty, sequence_no) VALUES
(1, 'Which of the following is NOT a valid HTTP method?', 'MCQ', 2, 'EASY', 1),
(1, 'In Java, which keyword is used to prevent method overriding?', 'MCQ', 2, 'EASY', 2),
(1, 'What does ACID stand for in database transactions?', 'MCQ', 3, 'MEDIUM', 3),
(1, 'Which SQL clause is used to filter results after GROUP BY?', 'MCQ', 2, 'MEDIUM', 4),
(1, 'Explain the difference between REST and SOAP web services. Include key characteristics and use cases.', 'SUBJECTIVE', 10, 'MEDIUM', 5),
(1, 'What is the time complexity of binary search?', 'MCQ', 2, 'EASY', 6),
(1, 'Which design pattern is used in Servlet MVC architecture?', 'MCQ', 3, 'MEDIUM', 7),
(1, 'What is a foreign key constraint?', 'MCQ', 2, 'EASY', 8),
(1, 'Describe the complete lifecycle of a Servlet from initialization to destruction.', 'SUBJECTIVE', 10, 'HARD', 9),
(1, 'Which of the following is true about JavaScript closures?', 'MCQ', 2, 'HARD', 10);

-- Sample Options for MCQ Questions
INSERT INTO options (question_id, option_text, is_correct, option_label) VALUES
-- Q1: HTTP Methods
(1, 'GET', FALSE, 'A'), (1, 'POST', FALSE, 'B'), (1, 'FETCH', TRUE, 'C'), (1, 'DELETE', FALSE, 'D'),
-- Q2: Java keyword
(2, 'static', FALSE, 'A'), (2, 'final', TRUE, 'B'), (2, 'abstract', FALSE, 'C'), (2, 'synchronized', FALSE, 'D'),
-- Q3: ACID
(3, 'Atomicity, Consistency, Isolation, Durability', TRUE, 'A'),
(3, 'Accuracy, Consistency, Integrity, Durability', FALSE, 'B'),
(3, 'Atomicity, Correctness, Isolation, Distribution', FALSE, 'C'),
(3, 'Atomicity, Consistency, Integration, Database', FALSE, 'D'),
-- Q4: SQL Clause
(4, 'WHERE', FALSE, 'A'), (4, 'HAVING', TRUE, 'B'), (4, 'FILTER', FALSE, 'C'), (4, 'LIMIT', FALSE, 'D'),
-- Q6: Binary Search
(6, 'O(n)', FALSE, 'A'), (6, 'O(n²)', FALSE, 'B'), (6, 'O(log n)', TRUE, 'C'), (6, 'O(1)', FALSE, 'D'),
-- Q7: Design Pattern
(7, 'Singleton Pattern', FALSE, 'A'), (7, 'Factory Pattern', FALSE, 'B'), (7, 'Front Controller Pattern', TRUE, 'C'), (7, 'Observer Pattern', FALSE, 'D'),
-- Q8: Foreign Key
(8, 'Uniquely identifies each row in a table', FALSE, 'A'),
(8, 'Creates a link between two tables', TRUE, 'B'),
(8, 'Prevents null values in a column', FALSE, 'C'),
(8, 'Automatically increments values', FALSE, 'D'),
-- Q10: JavaScript Closures
(10, 'Closures can only access variables declared with var', FALSE, 'A'),
(10, 'A closure has access to the outer function scope even after the outer function has returned', TRUE, 'B'),
(10, 'Closures are only created in arrow functions', FALSE, 'C'),
(10, 'Closures prevent garbage collection of all variables', FALSE, 'D');

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

DELIMITER $$

-- Procedure: Apply for Internship (with transaction)
CREATE PROCEDURE sp_apply_internship(
    IN p_student_id INT,
    IN p_internship_id INT,
    IN p_cover_letter TEXT,
    OUT p_result VARCHAR(100)
)
BEGIN
    DECLARE v_deadline DATE;
    DECLARE v_student_cgpa DECIMAL(3,2);
    DECLARE v_min_cgpa DECIMAL(3,2);
    DECLARE v_existing INT DEFAULT 0;
    DECLARE v_app_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'ERROR: Database error occurred';
    END;

    START TRANSACTION;

    -- Check if already applied
    SELECT COUNT(*) INTO v_existing FROM applications
    WHERE student_id = p_student_id AND internship_id = p_internship_id;

    IF v_existing > 0 THEN
        SET p_result = 'DUPLICATE: Already applied';
        ROLLBACK;
    ELSE
        -- Check deadline
        SELECT deadline INTO v_deadline FROM internships WHERE internship_id = p_internship_id;

        IF CURDATE() > v_deadline THEN
            SET p_result = 'EXPIRED: Deadline passed';
            ROLLBACK;
        ELSE
            -- Check CGPA eligibility
            SELECT s.cgpa INTO v_student_cgpa FROM students s WHERE s.student_id = p_student_id;
            SELECT i.eligibility_cgpa INTO v_min_cgpa FROM internships i WHERE i.internship_id = p_internship_id;

            IF v_student_cgpa < v_min_cgpa THEN
                SET p_result = 'INELIGIBLE: CGPA below requirement';
                ROLLBACK;
            ELSE
                -- Insert application
                INSERT INTO applications (student_id, internship_id, cover_letter)
                VALUES (p_student_id, p_internship_id, p_cover_letter);

                SET v_app_id = LAST_INSERT_ID();

                -- Insert application log
                INSERT INTO application_logs (application_id, action, old_status, new_status)
                VALUES (v_app_id, 'Application Submitted', NULL, 'APPLIED');

                COMMIT;
                SET p_result = CONCAT('SUCCESS:', v_app_id);
            END IF;
        END IF;
    END IF;
END$$

-- Procedure: Update Application Status
CREATE PROCEDURE sp_update_application_status(
    IN p_application_id INT,
    IN p_new_status VARCHAR(50),
    IN p_admin_id INT,
    IN p_remarks TEXT
)
BEGIN
    DECLARE v_old_status VARCHAR(50);

    START TRANSACTION;

    SELECT status INTO v_old_status FROM applications WHERE application_id = p_application_id;

    UPDATE applications
    SET status = p_new_status, reviewed_date = NOW(), reviewed_by = p_admin_id, remarks = p_remarks
    WHERE application_id = p_application_id;

    INSERT INTO application_logs (application_id, action, performed_by, old_status, new_status, remarks)
    VALUES (p_application_id, CONCAT('Status changed to ', p_new_status), p_admin_id, v_old_status, p_new_status, p_remarks);

    COMMIT;
END$$

-- Procedure: Calculate and Submit Exam
CREATE PROCEDURE sp_submit_exam(
    IN p_attempt_id INT,
    IN p_submit_type VARCHAR(20)
)
BEGIN
    DECLARE v_mcq_score DECIMAL(6,2) DEFAULT 0;
    DECLARE v_total_marks INT;
    DECLARE v_passing_marks INT;
    DECLARE v_is_passed BOOLEAN DEFAULT FALSE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- Auto-evaluate MCQ answers
    UPDATE answers a
    JOIN options o ON a.selected_option = o.option_id
    JOIN questions q ON a.question_id = q.question_id
    SET a.marks_awarded = CASE WHEN o.is_correct = TRUE THEN q.marks ELSE 0 END
    WHERE a.attempt_id = p_attempt_id
    AND q.type = 'MCQ';

    -- Calculate MCQ score
    SELECT COALESCE(SUM(marks_awarded), 0) INTO v_mcq_score
    FROM answers WHERE attempt_id = p_attempt_id;

    -- Get exam pass criteria
    SELECT e.total_marks, e.passing_marks INTO v_total_marks, v_passing_marks
    FROM exam_attempts ea
    JOIN exams e ON ea.exam_id = e.exam_id
    WHERE ea.attempt_id = p_attempt_id;

    IF v_mcq_score >= v_passing_marks THEN
        SET v_is_passed = TRUE;
    END IF;

    -- Update attempt
    UPDATE exam_attempts
    SET status = p_submit_type,
        end_time = NOW(),
        submit_time = NOW(),
        total_score = v_mcq_score,
        mcq_score = v_mcq_score,
        is_passed = v_is_passed
    WHERE attempt_id = p_attempt_id;

    COMMIT;
END$$

DELIMITER ;

-- ============================================================
-- VIEWS FOR REPORTS
-- ============================================================

-- Report 1: Students selected per company
CREATE VIEW v_selected_students_per_company AS
SELECT
    c.company_name,
    c.location,
    i.role AS internship_role,
    COUNT(a.application_id) AS selected_count,
    GROUP_CONCAT(u.name ORDER BY u.name SEPARATOR ', ') AS selected_students
FROM companies c
JOIN internships i ON c.company_id = i.company_id
JOIN applications a ON i.internship_id = a.internship_id
JOIN students s ON a.student_id = s.student_id
JOIN users u ON s.user_id = u.user_id
WHERE a.status = 'SELECTED'
GROUP BY c.company_id, c.company_name, c.location, i.role;

-- Report 2: Internship-wise application count
CREATE VIEW v_internship_application_counts AS
SELECT
    i.internship_id,
    c.company_name,
    i.role,
    i.deadline,
    i.seats,
    COUNT(a.application_id) AS total_applications,
    SUM(CASE WHEN a.status = 'APPLIED' THEN 1 ELSE 0 END) AS applied_count,
    SUM(CASE WHEN a.status = 'SHORTLISTED' THEN 1 ELSE 0 END) AS shortlisted_count,
    SUM(CASE WHEN a.status = 'SELECTED' THEN 1 ELSE 0 END) AS selected_count,
    SUM(CASE WHEN a.status = 'REJECTED' THEN 1 ELSE 0 END) AS rejected_count
FROM internships i
JOIN companies c ON i.company_id = c.company_id
LEFT JOIN applications a ON i.internship_id = a.internship_id
GROUP BY i.internship_id, c.company_name, i.role, i.deadline, i.seats;

-- Report 3: Exam Rank List
CREATE VIEW v_exam_rank_list AS
SELECT
    ea.exam_id,
    e.exam_name,
    u.name AS student_name,
    s.course,
    s.cgpa,
    ea.total_score,
    ea.mcq_score,
    ea.subjective_score,
    ea.is_passed,
    ea.tab_switch_count,
    ea.submit_time,
    RANK() OVER (PARTITION BY ea.exam_id ORDER BY ea.total_score DESC) AS rank_position
FROM exam_attempts ea
JOIN exams e ON ea.exam_id = e.exam_id
JOIN users u ON ea.user_id = u.user_id
JOIN students s ON u.user_id = s.user_id
WHERE ea.status IN ('SUBMITTED', 'AUTO_SUBMITTED');

-- Report 4: Question-wise performance analysis
CREATE VIEW v_question_performance AS
SELECT
    q.exam_id,
    e.exam_name,
    q.question_id,
    q.question_text,
    q.type,
    q.marks,
    q.difficulty,
    COUNT(a.answer_id) AS total_attempts,
    SUM(CASE WHEN a.marks_awarded = q.marks THEN 1 ELSE 0 END) AS correct_count,
    ROUND(AVG(a.marks_awarded), 2) AS avg_marks_scored,
    ROUND((SUM(CASE WHEN a.marks_awarded = q.marks THEN 1 ELSE 0 END) / COUNT(a.answer_id)) * 100, 2) AS success_rate
FROM questions q
JOIN exams e ON q.exam_id = e.exam_id
LEFT JOIN answers a ON q.question_id = a.question_id
GROUP BY q.question_id, e.exam_name;

-- Report 5: Suspicious activity logs
CREATE VIEW v_suspicious_activities AS
SELECT
    al.log_id,
    u.name AS user_name,
    u.email,
    al.action,
    al.action_type,
    al.severity,
    al.ip_address,
    al.session_id,
    al.additional_data,
    al.log_time
FROM audit_logs al
LEFT JOIN users u ON al.user_id = u.user_id
WHERE al.severity IN ('WARNING', 'CRITICAL')
   OR al.action_type IN ('TAB_SWITCH', 'SECURITY_ALERT')
ORDER BY al.log_time DESC;
