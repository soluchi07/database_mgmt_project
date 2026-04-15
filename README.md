# Database Management Project - Grade Book (MySQL)

This project implements the grade book database described in [instructions.txt](instructions.txt).

## Contents

- [sql/01_schema.sql](sql/01_schema.sql): create database, tables, constraints, and helper view
- [sql/02_seed_data.sql](sql/02_seed_data.sql): insert sample data
- [sql/03_tasks.sql](sql/03_tasks.sql): commands for assignment tasks 3-12
- [docs/ERD.md](docs/ERD.md): ER diagram with PK/FK and relationship details
- [tests/test_cases_and_results.md](tests/test_cases_and_results.md): test cases and recorded results template

## Requirements

- MySQL 8.0+ (window functions and CTEs are used)
- .NET 6.0+ (for building the SQL project)

## How To Compile

Build the database project:

```bash
dotnet build "database proj/database proj.sqlproj"
```

## How To Execute

Run from the project root using MySQL CLI:

```bash
mysql -u <username> -p < sql/01_schema.sql
mysql -u <username> -p < sql/02_seed_data.sql
mysql -u <username> -p < sql/03_tasks.sql
```

Or if you are already in a MySQL shell:

```sql
SOURCE sql/01_schema.sql;
SOURCE sql/02_seed_data.sql;
SOURCE sql/03_tasks.sql;
```

## Notes

- Task 7-10 statements in [sql/03_tasks.sql](sql/03_tasks.sql) mutate data.
- Re-run [sql/01_schema.sql](sql/01_schema.sql) and [sql/02_seed_data.sql](sql/02_seed_data.sql) to reset to a clean state before re-testing.
- Task 12 is implemented as "drop the single lowest score in each category" for the selected student and course. Categories with only one assignment are not dropped.

## ER Diagram Image

- The ER diagram is in [docs/ERD.png](docs/ERD.png).

## Table Images

- The images of the tables after creation are image.png through 5image.png