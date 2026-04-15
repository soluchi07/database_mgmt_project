-- Grade Book Database Schema (MySQL 8+)
-- Task 2: Create tables

DROP DATABASE IF EXISTS grade_book_db;
CREATE DATABASE grade_book_db;
USE grade_book_db;

CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    department VARCHAR(10) NOT NULL,
    course_number VARCHAR(10) NOT NULL,
    course_name VARCHAR(120) NOT NULL,
    semester ENUM('Spring', 'Summer', 'Fall', 'Winter') NOT NULL,
    year YEAR NOT NULL,
    UNIQUE KEY uk_course_term (department, course_number, semester, year)
);

CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120) NOT NULL,
    UNIQUE KEY uk_student_email (email)
);

CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    student_id INT NOT NULL,
    enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_enroll_course
        FOREIGN KEY (course_id) REFERENCES courses (course_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_enroll_student
        FOREIGN KEY (student_id) REFERENCES students (student_id)
        ON DELETE CASCADE,
    UNIQUE KEY uk_course_student (course_id, student_id)
);

CREATE TABLE grade_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    category_name VARCHAR(50) NOT NULL,
    weight_percent DECIMAL(5,2) NOT NULL,
    CONSTRAINT fk_category_course
        FOREIGN KEY (course_id) REFERENCES courses (course_id)
        ON DELETE CASCADE,
    CONSTRAINT chk_category_weight
        CHECK (weight_percent >= 0 AND weight_percent <= 100),
    UNIQUE KEY uk_course_category (course_id, category_name),
    UNIQUE KEY uk_category_course_pair (category_id, course_id)
);

CREATE TABLE assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    category_id INT NOT NULL,
    assignment_name VARCHAR(100) NOT NULL,
    points_possible DECIMAL(6,2) NOT NULL DEFAULT 100.00,
    due_date DATE NULL,
    CONSTRAINT fk_assignment_course
        FOREIGN KEY (course_id) REFERENCES courses (course_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_assignment_category
        FOREIGN KEY (category_id) REFERENCES grade_categories (category_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_assignment_category_course
        FOREIGN KEY (category_id, course_id)
        REFERENCES grade_categories (category_id, course_id)
        ON DELETE CASCADE,
    CONSTRAINT chk_points_possible
        CHECK (points_possible > 0),
    UNIQUE KEY uk_assignment_name_per_course (course_id, assignment_name)
);

CREATE TABLE student_assignment_scores (
    score_id INT AUTO_INCREMENT PRIMARY KEY,
    assignment_id INT NOT NULL,
    enrollment_id INT NOT NULL,
    raw_score DECIMAL(6,2) NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_score_assignment
        FOREIGN KEY (assignment_id) REFERENCES assignments (assignment_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_score_enrollment
        FOREIGN KEY (enrollment_id) REFERENCES enrollments (enrollment_id)
        ON DELETE CASCADE,
    CONSTRAINT chk_raw_score_nonnegative
        CHECK (raw_score >= 0),
    UNIQUE KEY uk_assignment_enrollment (assignment_id, enrollment_id)
);
