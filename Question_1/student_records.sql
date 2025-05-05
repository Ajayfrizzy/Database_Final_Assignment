-- MySQL Student Records System

-- Create database
DROP DATABASE IF EXISTS student_records_system;
CREATE DATABASE student_records_system;
USE student_records_system;

-- Departments table
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    department_code VARCHAR(10) NOT NULL UNIQUE,
    lecture_building VARCHAR(50) NOT NULL,
    budget DECIMAL(12,2) NOT NULL,
    established_date DATE NOT NULL,
    CONSTRAINT chk_budget_positive CHECK (budget > 0)
);

-- Grades lookup table
CREATE TABLE grades (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    grade_symbol VARCHAR(2) NOT NULL UNIQUE,
    grade_points DECIMAL(2,1) NOT NULL,
    description VARCHAR(50) NOT NULL,
    CONSTRAINT chk_grade_points_range CHECK (grade_points BETWEEN 0 AND 4.0)
);

-- Lecturers  table
CREATE TABLE lecturers (
    lecturer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    department_id INT NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_instructor_department FOREIGN KEY (department_id)
        REFERENCES departments(department_id),
    CONSTRAINT chk_salary_positive CHECK (salary > 0),
    CONSTRAINT chk_valid_email CHECK (email LIKE '%@%.%')
);

-- Courses table
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    course_name VARCHAR(100) NOT NULL,
    credits TINYINT NOT NULL,
    department_id INT NOT NULL,
    description TEXT,
    CONSTRAINT fk_course_department FOREIGN KEY (department_id)
        REFERENCES departments(department_id),
    CONSTRAINT chk_credits_positive CHECK (credits > 0)
);

-- Students table
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    admission_date DATE NOT NULL,
    graduation_date DATE,
    department_id INT NOT NULL,
    CONSTRAINT fk_student_department FOREIGN KEY (department_id)
        REFERENCES departments(department_id),
    CONSTRAINT chk_valid_student_email CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_admission_before_graduation CHECK (
        graduation_date IS NULL OR graduation_date >= admission_date
    )
);

-- Enrollments table (M-M relationship between students and courses)
-- This table tracks which students are enrolled in which courses
-- along with the semester and instructor for each enrollment.
CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    semester VARCHAR(20) NOT NULL,
    enrollment_date DATE NOT NULL,
    lecturer_id INT NOT NULL,
    CONSTRAINT fk_enrollment_student FOREIGN KEY (student_id)
        REFERENCES students(student_id),
    CONSTRAINT fk_enrollment_course FOREIGN KEY (course_id)
        REFERENCES courses(course_id),
    CONSTRAINT fk_enrollment_lecturer FOREIGN KEY (lecturer_id)
        REFERENCES lecturers(lecturer_id),
    CONSTRAINT uk_student_course_semester UNIQUE (student_id, course_id, semester)
);

-- Student academic history
-- This table tracks the academic history of students, including the courses they have completed,
-- the grades they received, and the instructors who taught those courses.
CREATE TABLE student_academic_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    semester_completed VARCHAR(20) NOT NULL,
    grade_id INT NOT NULL,
    completion_date DATE NOT NULL,
    lecturer_id INT NOT NULL,
    CONSTRAINT fk_history_student FOREIGN KEY (student_id)
        REFERENCES students(student_id),
    CONSTRAINT fk_history_course FOREIGN KEY (course_id)
        REFERENCES courses(course_id),
    CONSTRAINT fk_history_grade FOREIGN KEY (grade_id)
        REFERENCES grades(grade_id),
    CONSTRAINT fk_history_lecturer FOREIGN KEY (lecturer_id)
        REFERENCES lecturers(lecturer_id),
    CONSTRAINT uk_student_course_semester_completed UNIQUE (student_id, course_id, semester_completed)
);

-- Sample data for departments
INSERT INTO departments (department_name, department_code, lecture_building, budget, established_date) VALUES
('Computer Science', 'CS', 'Engineering Building', 1500000.00, '1990-05-15'),
('Mathematics', 'MATH', 'Science Building', 800000.00, '1985-08-20'),
('Physics', 'PHYS', 'Science Building', 950000.00, '1987-03-10'),
('English Literature', 'ENGL', 'Humanities Building', 600000.00, '1982-11-05');

-- Sample data for grades
INSERT INTO grades (grade_symbol, grade_points, description) VALUES
('A', 4.0, 'Excellent'),
('A-', 3.7, 'Very Good'),
('B+', 3.3, 'Good'),
('B', 3.0, 'Above Average'),
('B-', 2.7, 'Average'),
('C+', 2.3, 'Below Average'),
('C', 2.0, 'Satisfactory'),
('D', 1.0, 'Poor'),
('F', 0.0, 'Fail');

-- Sample data for lecturers
INSERT INTO lecturers (first_name, last_name, email, phone, department_id, hire_date, salary) VALUES
('John', 'Smithie', 'jsmithie@university.edu', '555-1234', 1, '2010-08-15', 85000.00),
('Sarah', 'Otesanya', 'sotesanya@university.edu', '555-5678', 1, '2015-03-22', 75000.00),
('Michael', 'Williams', 'mwilliams@university.edu', '555-9012', 2, '2008-01-10', 90000.00),
('Emily', 'Brown', 'ebrown@university.edu', '555-3456', 3, '2012-09-05', 82000.00),
('Gerald', 'Jones', 'gjones@university.edu', '555-7890', 4, '2018-07-30', 89000.00);

-- Sample data for courses
INSERT INTO courses (course_code, course_name, credits, department_id, description) VALUES
('PY101', 'Introduction to Programming', 4, 1, 'Fundamentals of programming using Python'),
('CS201', 'Data Structures', 4, 1, 'Advanced programming concepts and data structures'),
('MATH202', 'Calculus II', 3, 2, 'Integration techniques and applications'),
('PHYS101', 'General Physics', 4, 3, 'Fundamentals of mechanics and thermodynamics'),
('ENGL205', 'Modern Literature', 3, 4, 'Survey of 20th century literature');

-- Sample data for students
INSERT INTO students (first_name, last_name, date_of_birth, email, phone, admission_date, graduation_date, department_id) VALUES
('Keliba', 'Johnson', '2000-05-12', 'kjohnson@student.edu', '555-1111', '2019-08-25', NULL, 1),
('Bob', 'Williams', '1999-11-30', 'bwilliams@student.edu', '555-2222', '2018-08-20', '2022-05-15', 1),
('Oluwaseun', 'Davis', '2001-03-15', 'odavis@student.edu', '555-3333', '2020-08-28', NULL, 2),
('David', 'Millere', '2000-07-22', 'dmiller@student.edu', '555-4444', '2019-08-25', NULL, 3),
('Eve', 'Wilson', '1999-12-05', 'ewilson@student.edu', '555-5555', '2018-08-20', '2022-05-15', 4);

-- Sample data for enrollments
INSERT INTO enrollments (student_id, course_id, semester, enrollment_date, lecturer_id) VALUES
(1, 1, 'Fall 2023', '2023-08-15', 1),
(1, 2, 'Spring 2024', '2024-01-10', 2),
(2, 1, 'Fall 2021', '2021-08-15', 1),
(2, 3, 'Spring 2022', '2022-01-10', 3),
(3, 4, 'Fall 2023', '2023-08-15', 4),
(4, 5, 'Spring 2024', '2024-01-10', 5),
(5, 1, 'Fall 2020', '2020-08-15', 1);

-- Sample data for student academic history
INSERT INTO student_academic_history (student_id, course_id, semester_completed, grade_id, completion_date, lecturer_id) VALUES
(2, 1, 'Fall 2021', 1, '2021-12-15', 1),
(2, 3, 'Spring 2022', 3, '2022-05-10', 3),
(5, 1, 'Fall 2020', 2, '2020-12-18', 1);