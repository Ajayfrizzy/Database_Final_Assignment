## Question 1

# Student Records System - Database Project

## Project Title
**University Student Records Management System**

## Description
This project is a comprehensive MySQL database system designed to manage university student records, including:

- Department information
- Lecturer details
- Course offerings
- Student enrollment
- Academic history and grades

The system maintains relationships between students, courses, lecturers, and departments while enforcing data integrity through constraints and foreign key relationships. It's suitable for educational institutions needing to track student progress, course offerings, and faculty information.

## Features
- Tracks student enrollment in courses by semester
- Records completed courses with grades
- Manages department and lecturer information
- Enforces data integrity with constraints
- Provides sample data for immediate testing

## Setup Instructions

### Prerequisites
- MySQL Server (version 5.7 or higher recommended)
- MySQL client or administration tool (MySQL Workbench etc.)

### Installation Steps

1. **Create the database:**
   - Save the provided SQL script as `student_records.sql`
   - Run the script in your MySQL client:
     ```sql
     mysql -u username -p < student_records.sql
     ```
     or import it through your MySQL administration tool

2. **Verify the installation:**
   - Connect to your MySQL server:
     ```bash
     mysql -u username -p
     ```
   - Select the database:
     ```sql
     USE student_records_system;
     ```
   - Check the tables:
     ```sql
     SHOW TABLES;
     ```

3. **Test with sample queries:**
   ```sql
   -- View all students
   SELECT * FROM students;
   
   -- View courses by department
   SELECT d.department_name, c.course_code, c.course_name 
   FROM courses c
   JOIN departments d ON c.department_id = d.department_id;
   
   -- View student enrollments
   SELECT s.first_name, s.last_name, c.course_name, e.semester
   FROM enrollments e
   JOIN students s ON e.student_id = s.student_id
   JOIN courses c ON e.course_id = c.course_id;
   ```

## Sample Data
The database comes pre-loaded with:
- 4 academic departments
- 9 possible grades
- 5 lecturers
- 5 courses
- 5 students (2 graduated, 3 current)
- Enrollment records
- Academic history records




## Question 2

# Student Portal Database - README

## Project Title
Student Portal Database System

## Description
This project provides a relational database structure for managing student information, courses, and enrollments in an educational institution. The database allows for:

- Storing student personal information (name, email, date of birth)
- Maintaining course catalog with details like credit hours and department
- Tracking student enrollments in courses with grade recording
- Ensuring data integrity through proper relationships and constraints

Key features:
- Unique student emails to prevent duplicates
- Unique course codes for proper identification
- Prevention of duplicate enrollments
- Automatic timestamping of record creation
- Cascading deletes for maintaining referential integrity

## Setup Instructions

### Prerequisites
- MySQL Server (version 5.7 or higher recommended)
- MySQL client or administration tool (MySQL Workbench etc.)

### Installation Steps

1. **Create the database**:
   ```sql
   CREATE DATABASE student_portal;
   USE student_portal;
   ```

2. **Import the SQL schema**:
   - Method 1: Execute the provided SQL file directly:
     ```bash
     mysql -u [username] -p student_portal < task_manager.sql
     ```
   - Method 2: Copy and paste the SQL contents into your MySQL client

3. **Verify the installation**:
   ```sql
   SHOW TABLES;
   ```
   You should see three tables: `students`, `courses`, and `enrollments`.

### Sample Data Insertion (Optional)

To populate the database with sample data:

```sql
-- Insert sample students
INSERT INTO students (first_name, last_name, email, date_of_birth) VALUES
('John', 'Doe', 'john.doe@example.com', '2000-05-15'),
('Jane', 'Smith', 'jane.smith@example.com', '1999-11-22');

-- Insert sample courses
INSERT INTO courses (course_name, course_code, credit_hours, department) VALUES
('Introduction to Computer Science', 'CS101', 3, 'Computer Science'),
('Calculus I', 'MATH101', 4, 'Mathematics');

-- Insert sample enrollments
INSERT INTO enrollments (student_id, course_id, grade) VALUES
(1, 1, 'A'),
(1, 2, 'B+'),
(2, 1, 'A-');
```

## Usage Examples

1. **Find all courses a student is enrolled in**:
   ```sql
   SELECT c.course_name, e.grade 
   FROM enrollments e
   JOIN courses c ON e.course_id = c.course_id
   WHERE e.student_id = 1;
   ```

2. **Find all students in a particular course**:
   ```sql
   SELECT s.first_name, s.last_name, e.grade
   FROM enrollments e
   JOIN students s ON e.student_id = s.student_id
   WHERE e.course_id = 1;
   ```

3. **Add a new student**:
   ```sql
   INSERT INTO students (first_name, last_name, email, date_of_birth)
   VALUES ('Alice', 'Johnson', 'alice.j@example.com', '2001-03-10');
   ```