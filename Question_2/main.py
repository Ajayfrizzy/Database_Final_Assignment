from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, EmailStr
from typing import Optional, List
import mysql.connector
from datetime import date
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = FastAPI(
    title="Student Portal API",
    description="A CRUD API for managing students, courses, and enrollments",
    version="1.0.0"
)

# Database connection
def get_db_connection():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_NAME")
    )

# Pydantic models for request/response validation
class StudentBase(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    date_of_birth: Optional[date] = None

class StudentCreate(StudentBase):
    pass

class StudentResponse(StudentBase):
    student_id: int
    created_at: str

    class Config:
        from_attributes = True

class CourseBase(BaseModel):
    course_name: str
    course_code: str
    credit_hours: int
    department: Optional[str] = None

class CourseCreate(CourseBase):
    pass

class CourseResponse(CourseBase):
    course_id: int

    class Config:
        from_attributes = True

class EnrollmentBase(BaseModel):
    student_id: int
    course_id: int
    grade: Optional[str] = None

class EnrollmentCreate(EnrollmentBase):
    pass

class EnrollmentResponse(EnrollmentBase):
    enrollment_id: int
    enrollment_date: str

    class Config:
        from_attributes = True

# Students CRUD Operations
@app.post("/students/", response_model=StudentResponse, status_code=status.HTTP_201_CREATED)
def create_student(student: StudentCreate):
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    try:
        cursor.execute(
            "INSERT INTO students (first_name, last_name, email, date_of_birth) VALUES (%s, %s, %s, %s)",
            (student.first_name, student.last_name, student.email, student.date_of_birth)
        )
        db.commit()
        student_id = cursor.lastrowid
        cursor.execute("SELECT * FROM students WHERE student_id = %s", (student_id,))
        new_student = cursor.fetchone()
    except mysql.connector.IntegrityError as e:
        raise HTTPException(status_code=400, detail="Email already exists")
    finally:
        cursor.close()
        db.close()
    
    return new_student

@app.get("/students/", response_model=List[StudentResponse])
def read_students(skip: int = 0, limit: int = 100):
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    cursor.execute("SELECT * FROM students LIMIT %s OFFSET %s", (limit, skip))
    students = cursor.fetchall()
    
    cursor.close()
    db.close()
    return students

@app.get("/students/{student_id}", response_model=StudentResponse)
def read_student(student_id: int):
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    cursor.execute("SELECT * FROM students WHERE student_id = %s", (student_id,))
    student = cursor.fetchone()
    
    cursor.close()
    db.close()
    
    if student is None:
        raise HTTPException(status_code=404, detail="Student not found")
    return student

@app.put("/students/{student_id}", response_model=StudentResponse)
def update_student(student_id: int, student: StudentCreate):
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    cursor.execute(
        "UPDATE students SET first_name = %s, last_name = %s, email = %s, date_of_birth = %s WHERE student_id = %s",
        (student.first_name, student.last_name, student.email, student.date_of_birth, student_id)
    )
    db.commit()
    
    cursor.execute("SELECT * FROM students WHERE student_id = %s", (student_id,))
    updated_student = cursor.fetchone()
    
    cursor.close()
    db.close()
    
    if updated_student is None:
        raise HTTPException(status_code=404, detail="Student not found")
    return updated_student

@app.delete("/students/{student_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_student(student_id: int):
    db = get_db_connection()
    cursor = db.cursor()
    
    cursor.execute("DELETE FROM students WHERE student_id = %s", (student_id,))
    db.commit()
    
    if cursor.rowcount == 0:
        cursor.close()
        db.close()
        raise HTTPException(status_code=404, detail="Student not found")
    
    cursor.close()
    db.close()
    return {"ok": True}

# Courses CRUD Operations (similar pattern)
@app.post("/courses/", response_model=CourseResponse, status_code=status.HTTP_201_CREATED)
def create_course(course: CourseCreate):
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    try:
        cursor.execute(
            "INSERT INTO courses (course_name, course_code, credit_hours, department) VALUES (%s, %s, %s, %s)",
            (course.course_name, course.course_code, course.credit_hours, course.department)
        )
        db.commit()
        course_id = cursor.lastrowid
        cursor.execute("SELECT * FROM courses WHERE course_id = %s", (course_id,))
        new_course = cursor.fetchone()
    except mysql.connector.IntegrityError as e:
        raise HTTPException(status_code=400, detail="Course code already exists")
    finally:
        cursor.close()
        db.close()
    
    return new_course

@app.get("/courses/", response_model=List[CourseResponse])
def read_courses(skip: int = 0, limit: int = 100):
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    cursor.execute("SELECT * FROM courses LIMIT %s OFFSET %s", (limit, skip))
    courses = cursor.fetchall()
    
    cursor.close()
    db.close()
    return courses

# Enrollment CRUD Operations
@app.post("/enrollments/", response_model=EnrollmentResponse, status_code=status.HTTP_201_CREATED)
def create_enrollment(enrollment: EnrollmentCreate):
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    # Check if student and course exist
    cursor.execute("SELECT 1 FROM students WHERE student_id = %s", (enrollment.student_id,))
    if not cursor.fetchone():
        cursor.close()
        db.close()
        raise HTTPException(status_code=404, detail="Student not found")
    
    cursor.execute("SELECT 1 FROM courses WHERE course_id = %s", (enrollment.course_id,))
    if not cursor.fetchone():
        cursor.close()
        db.close()
        raise HTTPException(status_code=404, detail="Course not found")
    
    try:
        cursor.execute(
            "INSERT INTO enrollments (student_id, course_id, grade) VALUES (%s, %s, %s)",
            (enrollment.student_id, enrollment.course_id, enrollment.grade)
        )
        db.commit()
        enrollment_id = cursor.lastrowid
        cursor.execute("SELECT * FROM enrollments WHERE enrollment_id = %s", (enrollment_id,))
        new_enrollment = cursor.fetchone()
    except mysql.connector.IntegrityError as e:
        raise HTTPException(status_code=400, detail="Student already enrolled in this course")
    finally:
        cursor.close()
        db.close()
    
    return new_enrollment

@app.get("/enrollments/", response_model=List[EnrollmentResponse])
def read_enrollments(skip: int = 0, limit: int = 100):
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    cursor.execute("SELECT * FROM enrollments LIMIT %s OFFSET %s", (limit, skip))
    enrollments = cursor.fetchall()
    
    cursor.close()
    db.close()
    return enrollments

# Additional useful endpoints
@app.get("/students/{student_id}/courses", response_model=List[CourseResponse])
def get_student_courses(student_id: int):
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT c.* FROM courses c
        JOIN enrollments e ON c.course_id = e.course_id
        WHERE e.student_id = %s
    """, (student_id,))
    courses = cursor.fetchall()
    
    cursor.close()
    db.close()
    return courses

@app.get("/courses/{course_id}/students", response_model=List[StudentResponse])
def get_course_students(course_id: int):
    db = get_db_connection()
    cursor = db.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT s.* FROM students s
        JOIN enrollments e ON s.student_id = e.student_id
        WHERE e.course_id = %s
    """, (course_id,))
    students = cursor.fetchall()
    
    cursor.close()
    db.close()
    return students