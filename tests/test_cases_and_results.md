# Test Cases and Results

Use this document to record the test run outputs required by the assignment submission.

## Environment

- DBMS: MySQL 8.0+
- Database: grade_book_db

## Setup Validation

1. Run [sql/01_schema.sql](sql/01_schema.sql)
2. Run [sql/02_seed_data.sql](sql/02_seed_data.sql)
3. Confirm category weights sum to 100 per course:

```sql
SELECT * FROM v_category_weight_check;
```

Expected:
- one row per course
- total_weight_percent = 100.00

Status:
- [x] passed

## Task 3 - Show Inserted Table Contents

Commands:

```sql
SELECT * FROM courses;
SELECT * FROM students;
SELECT * FROM enrollments;
SELECT * FROM grade_categories;
SELECT * FROM assignments;
SELECT * FROM student_assignment_scores;
```

Result summary:
- [x] passed

## Task 4 - Assignment Average/Highest/Lowest

Command:

```sql
SELECT
    a.assignment_id,
    a.assignment_name,
    ROUND(AVG(sas.raw_score), 2) AS average_score,
    MAX(sas.raw_score) AS highest_score,
    MIN(sas.raw_score) AS lowest_score
FROM assignments a
JOIN student_assignment_scores sas ON sas.assignment_id = a.assignment_id
WHERE a.assignment_id = 1
GROUP BY a.assignment_id, a.assignment_name;
```

Result summary:
- [x] passed

## Task 5 - Students In A Given Course

Command:

```sql
SELECT
    c.course_id,
    c.department,
    c.course_number,
    c.course_name,
    s.student_id,
    s.first_name,
    s.last_name,
    s.email
FROM courses c
JOIN enrollments e ON e.course_id = c.course_id
JOIN students s ON s.student_id = e.student_id
WHERE c.course_id = 1
ORDER BY s.last_name, s.first_name;
```

Result summary:
- [x] passed

## Task 6 - Students In Course With Every Assignment Score

Command:

```sql
SELECT
    c.course_id,
    CONCAT(c.department, ' ', c.course_number) AS course_code,
    s.student_id,
    s.first_name,
    s.last_name,
    gc.category_name,
    a.assignment_name,
    a.points_possible,
    sas.raw_score
FROM courses c
JOIN enrollments e ON e.course_id = c.course_id
JOIN students s ON s.student_id = e.student_id
JOIN assignments a ON a.course_id = c.course_id
JOIN grade_categories gc ON gc.category_id = a.category_id
LEFT JOIN student_assignment_scores sas
    ON sas.assignment_id = a.assignment_id
   AND sas.enrollment_id = e.enrollment_id
WHERE c.course_id = 1
ORDER BY s.last_name, s.first_name, gc.category_name, a.assignment_name;
```

Result summary:
- [x] passed

## Task 7 - Add Assignment

Command:

```sql
INSERT INTO assignments (course_id, category_id, assignment_name, points_possible, due_date)
SELECT
    c.course_id,
    gc.category_id,
    'HW4',
    100.00,
    '2025-10-22'
FROM courses c
JOIN grade_categories gc ON gc.course_id = c.course_id
WHERE c.department = 'CS'
  AND c.course_number = '101'
  AND c.semester = 'Fall'
  AND c.year = 2025
  AND gc.category_name = 'Homework';
```

Verification:

```sql
SELECT * FROM assignments WHERE assignment_name = 'HW4';
```

Result summary:
- [x] passed

## Task 8 - Change Category Percentages

Command:

```sql
UPDATE grade_categories gc
JOIN courses c ON c.course_id = gc.course_id
SET gc.weight_percent = CASE gc.category_name
    WHEN 'Participation' THEN 10.00
    WHEN 'Homework' THEN 25.00
    WHEN 'Tests' THEN 45.00
    WHEN 'Projects' THEN 20.00
    ELSE gc.weight_percent
END
WHERE c.department = 'CS'
  AND c.course_number = '101'
  AND c.semester = 'Fall'
  AND c.year = 2025;
```

Verification:

```sql
SELECT c.course_id, gc.category_name, gc.weight_percent
FROM courses c
JOIN grade_categories gc ON gc.course_id = c.course_id
WHERE c.department = 'CS'
  AND c.course_number = '101'
ORDER BY gc.category_name;
```

Result summary:
- [x] passed

## Task 9 - Add 2 Points To Everyone On Assignment

Command:

```sql
UPDATE student_assignment_scores sas
JOIN assignments a ON a.assignment_id = sas.assignment_id
SET sas.raw_score = LEAST(a.points_possible, sas.raw_score + 2)
WHERE sas.assignment_id = 1;
```

Result summary:
- [x] passed

## Task 10 - Add 2 Points Where Last Name Contains Q

Command:

```sql
UPDATE student_assignment_scores sas
JOIN enrollments e ON e.enrollment_id = sas.enrollment_id
JOIN students s ON s.student_id = e.student_id
JOIN assignments a ON a.assignment_id = sas.assignment_id
SET sas.raw_score = LEAST(a.points_possible, sas.raw_score + 2)
WHERE sas.assignment_id = 1
  AND UPPER(s.last_name) LIKE '%Q%';
```

Result summary:
- [x] passed

## Task 11 - Compute Grade For A Student

Command:

```sql
WITH assignment_counts AS (
    SELECT
        a.course_id,
        a.category_id,
        COUNT(*) AS num_assignments
    FROM assignments a
    GROUP BY a.course_id, a.category_id
)
SELECT
    c.course_id,
    s.student_id,
    s.first_name,
    s.last_name,
    ROUND(SUM((sas.raw_score / a.points_possible) * (gc.weight_percent / ac.num_assignments)), 2) AS final_grade
FROM courses c
JOIN enrollments e ON e.course_id = c.course_id
JOIN students s ON s.student_id = e.student_id
JOIN student_assignment_scores sas ON sas.enrollment_id = e.enrollment_id
JOIN assignments a ON a.assignment_id = sas.assignment_id
JOIN grade_categories gc ON gc.category_id = a.category_id
JOIN assignment_counts ac
    ON ac.course_id = a.course_id
   AND ac.category_id = a.category_id
WHERE c.course_id = 1
  AND s.student_id = 2
GROUP BY c.course_id, s.student_id, s.first_name, s.last_name;
```

Result summary:
- [x] passed

## Task 12 - Compute Grade Dropping Lowest Category Score

Command:

```sql
WITH score_details AS (
    SELECT
        c.course_id,
        s.student_id,
        s.first_name,
        s.last_name,
        gc.category_id,
        gc.category_name,
        gc.weight_percent,
        a.assignment_id,
        a.points_possible,
        sas.raw_score,
        (sas.raw_score / a.points_possible) * 100 AS percent_score,
        COUNT(*) OVER (PARTITION BY c.course_id, s.student_id, gc.category_id) AS category_assignment_count,
        ROW_NUMBER() OVER (
            PARTITION BY c.course_id, s.student_id, gc.category_id
            ORDER BY (sas.raw_score / a.points_possible) ASC, a.assignment_id
        ) AS rn_lowest
    FROM courses c
    JOIN enrollments e ON e.course_id = c.course_id
    JOIN students s ON s.student_id = e.student_id
    JOIN student_assignment_scores sas ON sas.enrollment_id = e.enrollment_id
    JOIN assignments a ON a.assignment_id = sas.assignment_id
    JOIN grade_categories gc ON gc.category_id = a.category_id
    WHERE c.course_id = 1
      AND s.student_id = 2
),
scored_after_drop AS (
    SELECT
        course_id,
        student_id,
        first_name,
        last_name,
        category_id,
        category_name,
        weight_percent,
        assignment_id,
        percent_score,
        category_assignment_count,
        CASE
            WHEN category_assignment_count > 1 AND rn_lowest = 1 THEN 1
            ELSE 0
        END AS is_dropped
    FROM score_details
)
SELECT
    course_id,
    student_id,
    first_name,
    last_name,
    ROUND(SUM(
        CASE
            WHEN is_dropped = 1 THEN 0
            ELSE (percent_score / 100) * (
                weight_percent / CASE
                    WHEN category_assignment_count > 1 THEN category_assignment_count - 1
                    ELSE category_assignment_count
                END
            )
        END
    ), 2) AS final_grade_drop_lowest
FROM scored_after_drop
GROUP BY course_id, student_id, first_name, last_name;
```

Result summary:
- [x] passed
