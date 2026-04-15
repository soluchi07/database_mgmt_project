-- Grade Book Seed Data (MySQL 8+)
-- Task 2: Insert values

USE grade_book_db;

INSERT INTO courses (department, course_number, course_name, semester, year) VALUES
('CS', '101', 'Introduction to Databases', 'Fall', 2025),
('MATH', '220', 'Discrete Mathematics', 'Spring', 2026);

INSERT INTO students (first_name, last_name, email) VALUES
('Liam', 'Nguyen', 'liam.nguyen@example.edu'),
('Olivia', 'Quinn', 'olivia.quinn@example.edu'),
('Noah', 'Patel', 'noah.patel@example.edu'),
('Emma', 'Ramirez', 'emma.ramirez@example.edu'),
('Ava', 'Chen', 'ava.chen@example.edu'),
('Ethan', 'Qureshi', 'ethan.qureshi@example.edu'),
('Mia', 'Johnson', 'mia.johnson@example.edu'),
('Lucas', 'Smith', 'lucas.smith@example.edu'),
('Sophia', 'Baker', 'sophia.baker@example.edu'),
('James', 'Quincy', 'james.quincy@example.edu');

-- Enroll 8 students in CS101
INSERT INTO enrollments (course_id, student_id)
SELECT c.course_id, s.student_id
FROM courses c
JOIN students s ON s.email IN (
    'liam.nguyen@example.edu',
    'olivia.quinn@example.edu',
    'noah.patel@example.edu',
    'emma.ramirez@example.edu',
    'ava.chen@example.edu',
    'ethan.qureshi@example.edu',
    'mia.johnson@example.edu',
    'lucas.smith@example.edu'
)
WHERE c.department = 'CS' AND c.course_number = '101' AND c.semester = 'Fall' AND c.year = 2025;

-- Enroll 7 students in MATH220
INSERT INTO enrollments (course_id, student_id)
SELECT c.course_id, s.student_id
FROM courses c
JOIN students s ON s.email IN (
    'olivia.quinn@example.edu',
    'noah.patel@example.edu',
    'ava.chen@example.edu',
    'ethan.qureshi@example.edu',
    'mia.johnson@example.edu',
    'sophia.baker@example.edu',
    'james.quincy@example.edu'
)
WHERE c.department = 'MATH' AND c.course_number = '220' AND c.semester = 'Spring' AND c.year = 2026;

-- Categories for CS101: 10/20/50/20
INSERT INTO grade_categories (course_id, category_name, weight_percent)
SELECT c.course_id, x.category_name, x.weight_percent
FROM courses c
JOIN (
    SELECT 'Participation' AS category_name, 10.00 AS weight_percent
    UNION ALL SELECT 'Homework', 20.00
    UNION ALL SELECT 'Tests', 50.00
    UNION ALL SELECT 'Projects', 20.00
) x
WHERE c.department = 'CS' AND c.course_number = '101' AND c.semester = 'Fall' AND c.year = 2025;

-- Categories for MATH220: 10/30/40/20
INSERT INTO grade_categories (course_id, category_name, weight_percent)
SELECT c.course_id, x.category_name, x.weight_percent
FROM courses c
JOIN (
    SELECT 'Participation' AS category_name, 10.00 AS weight_percent
    UNION ALL SELECT 'Homework', 30.00
    UNION ALL SELECT 'Exams', 40.00
    UNION ALL SELECT 'Projects', 20.00
) x
WHERE c.department = 'MATH' AND c.course_number = '220' AND c.semester = 'Spring' AND c.year = 2026;

-- Assignments for CS101 (variable assignment counts per category)
INSERT INTO assignments (course_id, category_id, assignment_name, points_possible, due_date)
SELECT gc.course_id, gc.category_id, 'Participation Log', 100.00, '2025-12-01'
FROM grade_categories gc
JOIN courses c ON c.course_id = gc.course_id
WHERE c.department = 'CS' AND c.course_number = '101' AND gc.category_name = 'Participation';

INSERT INTO assignments (course_id, category_id, assignment_name, points_possible, due_date)
SELECT gc.course_id, gc.category_id, x.assignment_name, 100.00, x.due_date
FROM grade_categories gc
JOIN courses c ON c.course_id = gc.course_id
JOIN (
    SELECT 'HW1' AS assignment_name, '2025-09-10' AS due_date
    UNION ALL SELECT 'HW2', '2025-09-24'
    UNION ALL SELECT 'HW3', '2025-10-08'
) x
WHERE c.department = 'CS' AND c.course_number = '101' AND gc.category_name = 'Homework';

INSERT INTO assignments (course_id, category_id, assignment_name, points_possible, due_date)
SELECT gc.course_id, gc.category_id, x.assignment_name, 100.00, x.due_date
FROM grade_categories gc
JOIN courses c ON c.course_id = gc.course_id
JOIN (
    SELECT 'Midterm' AS assignment_name, '2025-10-20' AS due_date
    UNION ALL SELECT 'Final', '2025-12-10'
) x
WHERE c.department = 'CS' AND c.course_number = '101' AND gc.category_name = 'Tests';

INSERT INTO assignments (course_id, category_id, assignment_name, points_possible, due_date)
SELECT gc.course_id, gc.category_id, x.assignment_name, 100.00, x.due_date
FROM grade_categories gc
JOIN courses c ON c.course_id = gc.course_id
JOIN (
    SELECT 'Project 1' AS assignment_name, '2025-11-01' AS due_date
    UNION ALL SELECT 'Project 2', '2025-11-25'
) x
WHERE c.department = 'CS' AND c.course_number = '101' AND gc.category_name = 'Projects';

-- Assignments for MATH220
INSERT INTO assignments (course_id, category_id, assignment_name, points_possible, due_date)
SELECT gc.course_id, gc.category_id, 'Participation Log', 100.00, '2026-05-01'
FROM grade_categories gc
JOIN courses c ON c.course_id = gc.course_id
WHERE c.department = 'MATH' AND c.course_number = '220' AND gc.category_name = 'Participation';

INSERT INTO assignments (course_id, category_id, assignment_name, points_possible, due_date)
SELECT gc.course_id, gc.category_id, x.assignment_name, 100.00, x.due_date
FROM grade_categories gc
JOIN courses c ON c.course_id = gc.course_id
JOIN (
    SELECT 'HW1' AS assignment_name, '2026-02-05' AS due_date
    UNION ALL SELECT 'HW2', '2026-02-19'
    UNION ALL SELECT 'HW3', '2026-03-05'
    UNION ALL SELECT 'HW4', '2026-03-19'
) x
WHERE c.department = 'MATH' AND c.course_number = '220' AND gc.category_name = 'Homework';

INSERT INTO assignments (course_id, category_id, assignment_name, points_possible, due_date)
SELECT gc.course_id, gc.category_id, x.assignment_name, 100.00, x.due_date
FROM grade_categories gc
JOIN courses c ON c.course_id = gc.course_id
JOIN (
    SELECT 'Exam 1' AS assignment_name, '2026-03-28' AS due_date
    UNION ALL SELECT 'Final Exam', '2026-05-07'
) x
WHERE c.department = 'MATH' AND c.course_number = '220' AND gc.category_name = 'Exams';

INSERT INTO assignments (course_id, category_id, assignment_name, points_possible, due_date)
SELECT gc.course_id, gc.category_id, 'Graph Project', 100.00, '2026-04-20'
FROM grade_categories gc
JOIN courses c ON c.course_id = gc.course_id
WHERE c.department = 'MATH' AND c.course_number = '220' AND gc.category_name = 'Projects';

-- Insert one score per (enrolled student, assignment) pair in each course.
-- The formula creates stable demo scores in a realistic range.
INSERT INTO student_assignment_scores (assignment_id, enrollment_id, raw_score)
SELECT
    a.assignment_id,
    e.enrollment_id,
    LEAST(a.points_possible, GREATEST(0, 65 + ((e.enrollment_id * 7 + a.assignment_id * 3) % 36))) AS raw_score
FROM assignments a
JOIN enrollments e ON e.course_id = a.course_id;
