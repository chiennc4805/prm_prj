/* School management database - SQL Server 2019+ (development reset script) */

IF DB_ID('myfs') IS NULL CREATE DATABASE myfs;
GO
USE myfs;
GO

-- Detach the previous development schema regardless of its FK layout.
DECLARE @dropForeignKeys NVARCHAR(MAX) = N'';
SELECT @dropForeignKeys += N'ALTER TABLE '
    + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + N'.' + QUOTENAME(OBJECT_NAME(parent_object_id))
    + N' DROP CONSTRAINT ' + QUOTENAME(name) + N';' + CHAR(13)
FROM sys.foreign_keys;
IF LEN(@dropForeignKeys) > 0 EXEC sys.sp_executesql @dropForeignKeys;

DROP TABLE IF EXISTS dbo.club;
DROP TABLE IF EXISTS dbo.event;
DROP TABLE IF EXISTS dbo.notification;
DROP TABLE IF EXISTS dbo.student_evaluation;
DROP TABLE IF EXISTS dbo.leave_request;
DROP TABLE IF EXISTS dbo.attendance;
DROP TABLE IF EXISTS dbo.grade;
DROP TABLE IF EXISTS dbo.schedule;
DROP TABLE IF EXISTS dbo.teacher_assignment;
-- Cleanup if the previous development schema (many-to-many guardians) was used.
DROP TABLE IF EXISTS dbo.parent_student;
DROP TABLE IF EXISTS dbo.student;
DROP TABLE IF EXISTS dbo.school_class;
DROP TABLE IF EXISTS dbo.subject;
DROP TABLE IF EXISTS dbo.semester;
DROP TABLE IF EXISTS dbo.app_user;
GO

CREATE TABLE dbo.app_user (
    id            INT IDENTITY(1,1) PRIMARY KEY,
    phone         VARCHAR(15)   NOT NULL UNIQUE,
    password      VARCHAR(100)  NOT NULL,
    full_name     NVARCHAR(100) NOT NULL,
    role          VARCHAR(10)   NOT NULL,
    email         VARCHAR(100)  NULL UNIQUE,
    avatar_url    VARCHAR(255)  NULL,
    is_active     BIT           NOT NULL DEFAULT 1,
    created_at    DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    updated_at    DATETIME2     NULL,
    CONSTRAINT CK_app_user_role CHECK (role IN ('ADMIN','TEACHER','PARENT','STUDENT'))
);

CREATE TABLE dbo.semester (
    id            INT IDENTITY(1,1) PRIMARY KEY,
    name          NVARCHAR(50) NOT NULL,
    academic_year VARCHAR(20)  NOT NULL,
    start_date    DATE         NOT NULL,
    end_date      DATE         NOT NULL,
    is_active     BIT          NOT NULL DEFAULT 0,
    CONSTRAINT UQ_semester UNIQUE (name, academic_year),
    CONSTRAINT CK_semester_dates CHECK (start_date <= end_date)
);

CREATE TABLE dbo.subject (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    code        VARCHAR(20)   NOT NULL UNIQUE,
    name        NVARCHAR(100) NOT NULL UNIQUE,
    description NVARCHAR(500) NULL,
    is_active   BIT           NOT NULL DEFAULT 1
);

CREATE TABLE dbo.school_class (
    id                  INT IDENTITY(1,1) PRIMARY KEY,
    name                NVARCHAR(50) NOT NULL,
    academic_year       VARCHAR(20)  NOT NULL,
    homeroom_teacher_id INT          NULL,
    CONSTRAINT UQ_school_class UNIQUE (name, academic_year),
    CONSTRAINT FK_class_homeroom_teacher FOREIGN KEY (homeroom_teacher_id)
        REFERENCES dbo.app_user(id)
);

CREATE TABLE dbo.student (
    id                 INT IDENTITY(1,1) PRIMARY KEY,
    student_code       VARCHAR(20)   NOT NULL UNIQUE,
    full_name          NVARCHAR(100) NOT NULL,
    date_of_birth      DATE          NULL,
    gender             VARCHAR(10)   NULL,
    class_id           INT           NULL,
    parent_id          INT           NULL,
    student_account_id INT           NULL UNIQUE,
    CONSTRAINT CK_student_gender CHECK (gender IS NULL OR gender IN ('MALE','FEMALE','OTHER')),
    CONSTRAINT FK_student_class FOREIGN KEY (class_id) REFERENCES dbo.school_class(id),
    CONSTRAINT FK_student_parent FOREIGN KEY (parent_id) REFERENCES dbo.app_user(id),
    CONSTRAINT FK_student_account FOREIGN KEY (student_account_id) REFERENCES dbo.app_user(id)
);

-- Subject-teacher permission boundary. Homeroom permission comes from school_class.
CREATE TABLE dbo.teacher_assignment (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    teacher_id  INT NOT NULL,
    class_id    INT NOT NULL,
    subject_id  INT NOT NULL,
    semester_id INT NOT NULL,
    created_at  DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_teacher_assignment UNIQUE (teacher_id, class_id, subject_id, semester_id),
    CONSTRAINT FK_assignment_teacher FOREIGN KEY (teacher_id) REFERENCES dbo.app_user(id),
    CONSTRAINT FK_assignment_class FOREIGN KEY (class_id) REFERENCES dbo.school_class(id),
    CONSTRAINT FK_assignment_subject FOREIGN KEY (subject_id) REFERENCES dbo.subject(id),
    CONSTRAINT FK_assignment_semester FOREIGN KEY (semester_id) REFERENCES dbo.semester(id)
);

CREATE TABLE dbo.schedule (
    id                    INT IDENTITY(1,1) PRIMARY KEY,
    teacher_assignment_id INT          NOT NULL,
    day_order             TINYINT      NOT NULL,
    period                TINYINT      NOT NULL,
    room                  NVARCHAR(50) NULL,
    start_time            TIME(0)      NOT NULL,
    end_time              TIME(0)      NOT NULL,
    CONSTRAINT UQ_schedule_class_slot UNIQUE (teacher_assignment_id, day_order, period),
    CONSTRAINT CK_schedule_day CHECK (day_order BETWEEN 2 AND 8),
    CONSTRAINT CK_schedule_period CHECK (period > 0),
    CONSTRAINT CK_schedule_time CHECK (start_time < end_time),
    CONSTRAINT FK_schedule_assignment FOREIGN KEY (teacher_assignment_id)
        REFERENCES dbo.teacher_assignment(id)
);

CREATE TABLE dbo.grade (
    id                    INT IDENTITY(1,1) PRIMARY KEY,
    student_id            INT           NOT NULL,
    teacher_assignment_id INT           NOT NULL,
    regular_scores        VARCHAR(100)  NULL,
    midterm_score         DECIMAL(4,2)  NULL,
    final_score           DECIMAL(4,2)  NULL,
    average_score         DECIMAL(4,2)  NULL,
    created_at            DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    updated_at            DATETIME2     NULL,
    CONSTRAINT UQ_grade_student_assignment UNIQUE (student_id, teacher_assignment_id),
    CONSTRAINT CK_grade_midterm CHECK (midterm_score IS NULL OR midterm_score BETWEEN 0 AND 10),
    CONSTRAINT CK_grade_final CHECK (final_score IS NULL OR final_score BETWEEN 0 AND 10),
    CONSTRAINT CK_grade_average CHECK (average_score IS NULL OR average_score BETWEEN 0 AND 10),
    CONSTRAINT FK_grade_student FOREIGN KEY (student_id) REFERENCES dbo.student(id),
    CONSTRAINT FK_grade_assignment FOREIGN KEY (teacher_assignment_id)
        REFERENCES dbo.teacher_assignment(id)
);

-- Attendance is recorded for a concrete scheduled lesson.
CREATE TABLE dbo.attendance (
    id             INT IDENTITY(1,1) PRIMARY KEY,
    student_id     INT           NOT NULL,
    schedule_id    INT           NOT NULL,
    attendance_date DATE         NOT NULL,
    status         VARCHAR(10)   NOT NULL,
    note           NVARCHAR(255) NULL,
    recorded_by_id INT           NOT NULL,
    created_at     DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    updated_at     DATETIME2     NULL,
    CONSTRAINT UQ_attendance_lesson UNIQUE (student_id, schedule_id, attendance_date),
    CONSTRAINT CK_attendance_status CHECK (status IN ('PRESENT','ABSENT','LATE','EXCUSED')),
    CONSTRAINT FK_attendance_student FOREIGN KEY (student_id) REFERENCES dbo.student(id),
    CONSTRAINT FK_attendance_schedule FOREIGN KEY (schedule_id) REFERENCES dbo.schedule(id),
    CONSTRAINT FK_attendance_recorder FOREIGN KEY (recorded_by_id) REFERENCES dbo.app_user(id)
);

-- The system has exactly one request type: school absence.
CREATE TABLE dbo.leave_request (
    id               INT IDENTITY(1,1) PRIMARY KEY,
    student_id       INT            NOT NULL,
    created_by_id    INT            NOT NULL,
    from_date        DATE           NOT NULL,
    to_date          DATE           NOT NULL,
    reason           NVARCHAR(500)  NOT NULL,
    status           VARCHAR(10)    NOT NULL DEFAULT 'PENDING',
    reviewed_by_id   INT            NULL,
    reviewed_at      DATETIME2      NULL,
    rejection_reason NVARCHAR(500)  NULL,
    created_at       DATETIME2      NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT CK_leave_dates CHECK (from_date <= to_date),
    CONSTRAINT CK_leave_status CHECK (status IN ('PENDING','APPROVED','REJECTED')),
    CONSTRAINT FK_leave_student FOREIGN KEY (student_id) REFERENCES dbo.student(id),
    CONSTRAINT FK_leave_creator FOREIGN KEY (created_by_id) REFERENCES dbo.app_user(id),
    CONSTRAINT FK_leave_reviewer FOREIGN KEY (reviewed_by_id) REFERENCES dbo.app_user(id)
);

CREATE TABLE dbo.student_evaluation (
    id                  INT IDENTITY(1,1) PRIMARY KEY,
    student_id          INT            NOT NULL,
    class_id            INT            NOT NULL,
    semester_id         INT            NOT NULL,
    homeroom_teacher_id INT            NOT NULL,
    conduct_rating      VARCHAR(20)    NOT NULL,
    academic_rating     VARCHAR(20)    NULL,
    comment             NVARCHAR(1000) NULL,
    evaluated_at        DATETIME2      NOT NULL DEFAULT SYSDATETIME(),
    updated_at          DATETIME2      NULL,
    CONSTRAINT UQ_student_evaluation UNIQUE (student_id, semester_id),
    CONSTRAINT CK_conduct_rating CHECK (conduct_rating IN ('EXCELLENT','GOOD','AVERAGE','WEAK')),
    CONSTRAINT CK_academic_rating CHECK (academic_rating IS NULL OR academic_rating IN ('EXCELLENT','GOOD','AVERAGE','WEAK')),
    CONSTRAINT FK_evaluation_student FOREIGN KEY (student_id) REFERENCES dbo.student(id),
    CONSTRAINT FK_evaluation_class FOREIGN KEY (class_id) REFERENCES dbo.school_class(id),
    CONSTRAINT FK_evaluation_semester FOREIGN KEY (semester_id) REFERENCES dbo.semester(id),
    CONSTRAINT FK_evaluation_teacher FOREIGN KEY (homeroom_teacher_id) REFERENCES dbo.app_user(id)
);

CREATE TABLE dbo.notification (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    title       NVARCHAR(200) NOT NULL,
    content     NVARCHAR(MAX) NOT NULL,
    sender_id   INT           NOT NULL,
    class_id    INT           NULL,
    created_at  DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_notification_sender FOREIGN KEY (sender_id) REFERENCES dbo.app_user(id),
    CONSTRAINT FK_notification_class FOREIGN KEY (class_id) REFERENCES dbo.school_class(id)
);

CREATE TABLE dbo.event (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    title       NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX) NULL,
    location    NVARCHAR(150) NULL,
    event_date  DATE          NOT NULL,
    event_time  TIME(0)       NULL,
    created_at  DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);

CREATE TABLE dbo.club (
    id           INT IDENTITY(1,1) PRIMARY KEY,
    name         NVARCHAR(150) NOT NULL UNIQUE,
    description  NVARCHAR(MAX) NULL,
    category     NVARCHAR(50)  NULL,
    meeting_time NVARCHAR(100) NULL,
    location     NVARCHAR(150) NULL,
    contact      NVARCHAR(100) NULL,
    member_count INT           NOT NULL DEFAULT 0,
    CONSTRAINT CK_club_member_count CHECK (member_count >= 0)
);

CREATE INDEX IX_student_class ON dbo.student(class_id);
CREATE INDEX IX_student_parent ON dbo.student(parent_id);
CREATE INDEX IX_assignment_teacher ON dbo.teacher_assignment(teacher_id, semester_id);
CREATE INDEX IX_assignment_class ON dbo.teacher_assignment(class_id, semester_id);
CREATE INDEX IX_leave_student_status ON dbo.leave_request(student_id, status);
CREATE INDEX IX_notification_class ON dbo.notification(class_id, created_at DESC);
GO

-- Development seed (password is intentionally plain until authentication refactor).
SET IDENTITY_INSERT dbo.app_user ON;
INSERT dbo.app_user (id, phone, password, full_name, role, email) VALUES
 (1, '0900000001', '123456', N'Quản trị hệ thống', 'ADMIN',   'admin@myfs.local'),
 (2, '0900000002', '123456', N'Nguyễn Thu Hà',     'TEACHER', 'ha.nt@myfs.local'),
 (3, '0900000003', '123456', N'Trần Minh Nam',     'TEACHER', 'nam.tm@myfs.local'),
 (4, '0900000004', '123456', N'Lê Văn Bình',       'PARENT',  'binh.lv@myfs.local'),
 (5, '0900000005', '123456', N'Lê Minh An',        'STUDENT', 'an.lm@myfs.local');
SET IDENTITY_INSERT dbo.app_user OFF;

INSERT dbo.semester (name, academic_year, start_date, end_date, is_active)
VALUES (N'Học kỳ 1', '2026-2027', '2026-08-15', '2026-12-31', 1);

INSERT dbo.subject (code, name) VALUES
 ('MATH', N'Toán'), ('LITERATURE', N'Ngữ văn'), ('ENGLISH', N'Tiếng Anh');

INSERT dbo.school_class (name, academic_year, homeroom_teacher_id)
VALUES (N'10A1', '2026-2027', 2);

INSERT dbo.student (student_code, full_name, date_of_birth, gender, class_id, parent_id, student_account_id)
VALUES ('HS001', N'Lê Minh An', '2010-04-10', 'MALE', 1, 4, 5);

INSERT dbo.teacher_assignment (teacher_id, class_id, subject_id, semester_id) VALUES
 (2, 1, 1, 1),
 (3, 1, 3, 1);

INSERT dbo.schedule (teacher_assignment_id, day_order, period, room, start_time, end_time) VALUES
 (1, 2, 1, N'P101', '07:00', '07:45'),
 (2, 3, 2, N'P101', '07:50', '08:35');

INSERT dbo.grade (student_id, teacher_assignment_id, regular_scores, midterm_score)
VALUES (1, 1, '8.0,9.0', 8.50);

INSERT dbo.attendance (student_id, schedule_id, attendance_date, status, recorded_by_id)
VALUES (1, 1, '2026-08-17', 'PRESENT', 2);

INSERT dbo.leave_request (student_id, created_by_id, from_date, to_date, reason)
VALUES (1, 4, '2026-09-15', '2026-09-16', N'Gia đình có việc riêng.');

INSERT dbo.notification (title, content, sender_id, class_id)
VALUES (N'Lịch kiểm tra Toán', N'Lớp kiểm tra vào tiết 1 thứ Hai.', 2, 1);
GO
