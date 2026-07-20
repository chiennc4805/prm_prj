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
DROP TABLE IF EXISTS dbo.grade_item;
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
    academic_year VARCHAR(20) NOT NULL,
    created_at  DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_teacher_assignment UNIQUE (teacher_id, class_id, subject_id, academic_year),
    CONSTRAINT FK_assignment_teacher FOREIGN KEY (teacher_id) REFERENCES dbo.app_user(id),
    CONSTRAINT FK_assignment_class FOREIGN KEY (class_id) REFERENCES dbo.school_class(id),
    CONSTRAINT FK_assignment_subject FOREIGN KEY (subject_id) REFERENCES dbo.subject(id)
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
    semester_id           INT           NOT NULL,
    average_score         DECIMAL(4,2)  NULL,
    created_at            DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    updated_at            DATETIME2     NULL,
    CONSTRAINT UQ_grade_student_assignment_semester UNIQUE (student_id, teacher_assignment_id, semester_id),
    CONSTRAINT CK_grade_average CHECK (average_score IS NULL OR average_score BETWEEN 0 AND 10),
    CONSTRAINT FK_grade_student FOREIGN KEY (student_id) REFERENCES dbo.student(id),
    CONSTRAINT FK_grade_assignment FOREIGN KEY (teacher_assignment_id)
        REFERENCES dbo.teacher_assignment(id),
    CONSTRAINT FK_grade_semester FOREIGN KEY (semester_id) REFERENCES dbo.semester(id)
);

CREATE TABLE dbo.grade_item (
    id       INT IDENTITY(1,1) PRIMARY KEY,
    grade_id INT           NOT NULL,
    name     NVARCHAR(100) NOT NULL,
    score    DECIMAL(4,2)  NOT NULL,
    weight   DECIMAL(5,2)  NOT NULL,
    CONSTRAINT CK_grade_item_score CHECK (score BETWEEN 0 AND 10),
    CONSTRAINT CK_grade_item_weight CHECK (weight > 0),
    CONSTRAINT FK_grade_item_grade FOREIGN KEY (grade_id) REFERENCES dbo.grade(id) ON DELETE CASCADE
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
CREATE INDEX IX_assignment_teacher ON dbo.teacher_assignment(teacher_id, academic_year);
CREATE INDEX IX_assignment_class ON dbo.teacher_assignment(class_id, academic_year);
CREATE INDEX IX_grade_item_grade ON dbo.grade_item(grade_id);
CREATE INDEX IX_leave_student_status ON dbo.leave_request(student_id, status);
CREATE INDEX IX_notification_class ON dbo.notification(class_id, created_at DESC);
GO

-- Development seed. All demo accounts use password 123456.
SET IDENTITY_INSERT dbo.app_user ON;
INSERT dbo.app_user (id, phone, password, full_name, role, email) VALUES
 (1,  '0900000001', '123456', N'Quản trị FPT Schools', 'ADMIN',   'admin@fptschools.local'),
 (2,  '0900000002', '123456', N'Nguyễn Thu Hà',        'TEACHER', 'ha.nt@fptschools.local'),
 (3,  '0900000003', '123456', N'Trần Minh Nam',        'TEACHER', 'nam.tm@fptschools.local'),
 (4,  '0900000004', '123456', N'Phạm Hoàng Lan',       'TEACHER', 'lan.ph@fptschools.local'),
 (5,  '0900000005', '123456', N'Vũ Đức Anh',           'TEACHER', 'anh.vd@fptschools.local'),
 (6,  '0900000006', '123456', N'Đỗ Mai Phương',        'TEACHER', 'phuong.dm@fptschools.local'),
 (7,  '0910000001', '123456', N'Lê Văn Bình',          'PARENT',  'binh.lv@fptschools.local'),
 (8,  '0910000002', '123456', N'Nguyễn Thị Hoa',       'PARENT',  'hoa.nt@fptschools.local'),
 (9,  '0910000003', '123456', N'Phan Quốc Tuấn',       'PARENT',  'tuan.pq@fptschools.local'),
 (10, '0920000001', '123456', N'Lê Minh An',           'STUDENT', 'an.lm@fptschools.local'),
 (11, '0920000002', '123456', N'Lê Ngọc Mai',          'STUDENT', 'mai.ln@fptschools.local'),
 (12, '0920000003', '123456', N'Nguyễn Gia Huy',       'STUDENT', 'huy.ng@fptschools.local'),
 (13, '0920000004', '123456', N'Nguyễn Khánh Linh',    'STUDENT', 'linh.nk@fptschools.local'),
 (14, '0920000005', '123456', N'Phan Minh Khang',      'STUDENT', 'khang.pm@fptschools.local'),
 (15, '0920000006', '123456', N'Phan Thu Trang',       'STUDENT', 'trang.pt@fptschools.local');
SET IDENTITY_INSERT dbo.app_user OFF;

INSERT dbo.semester (name, academic_year, start_date, end_date, is_active) VALUES
 (N'Học kỳ 1', '2026-2027', '2026-08-15', '2026-12-31', 1),
 (N'Học kỳ 2', '2026-2027', '2027-01-10', '2027-05-31', 0);

INSERT dbo.subject (code, name, description) VALUES
 ('MATH',       N'Toán',       N'Đại số và hình học'),
 ('LITERATURE', N'Ngữ văn',    N'Ngôn ngữ và văn học Việt Nam'),
 ('ENGLISH',    N'Tiếng Anh',  N'Ngoại ngữ tiếng Anh'),
 ('PHYSICS',    N'Vật lý',     N'Khoa học vật lý'),
 ('CHEMISTRY',  N'Hóa học',    N'Khoa học hóa học'),
 ('BIOLOGY',    N'Sinh học',   N'Khoa học sự sống'),
 ('HISTORY',    N'Lịch sử',    N'Lịch sử Việt Nam và thế giới'),
 ('GEOGRAPHY',  N'Địa lý',     N'Địa lý tự nhiên và kinh tế'),
 ('INFORMATICS',N'Tin học',    N'Công nghệ thông tin cơ bản'),
 ('PE',         N'Thể dục',    N'Giáo dục thể chất');

INSERT dbo.school_class (name, academic_year, homeroom_teacher_id) VALUES
 (N'10A1', '2026-2027', 2),
 (N'10A2', '2026-2027', 4),
 (N'11A1', '2026-2027', 6);

INSERT dbo.student (student_code, full_name, date_of_birth, gender, class_id, parent_id, student_account_id) VALUES
 ('HS001', N'Lê Minh An',        '2010-04-10', 'MALE',   1, 7, 10),
 ('HS002', N'Lê Ngọc Mai',       '2010-09-22', 'FEMALE', 1, 7, 11),
 ('HS003', N'Nguyễn Gia Huy',    '2010-01-15', 'MALE',   2, 8, 12),
 ('HS004', N'Nguyễn Khánh Linh', '2010-11-03', 'FEMALE', 2, 8, 13),
 ('HS005', N'Phan Minh Khang',   '2009-06-18', 'MALE',   3, 9, 14),
 ('HS006', N'Phan Thu Trang',    '2009-12-01', 'FEMALE', 3, 9, 15);

-- Phân công áp dụng cho cả năm học, không phụ thuộc học kỳ.
INSERT dbo.teacher_assignment (teacher_id, class_id, subject_id, academic_year) VALUES
 (2,1,1,'2026-2027'), (4,1,2,'2026-2027'), (3,1,3,'2026-2027'),
 (5,1,4,'2026-2027'), (6,1,5,'2026-2027'), (6,1,6,'2026-2027'),
 (2,2,1,'2026-2027'), (4,2,2,'2026-2027'), (3,2,3,'2026-2027'),
 (5,2,4,'2026-2027'), (6,2,7,'2026-2027'), (5,2,9,'2026-2027'),
 (2,3,1,'2026-2027'), (4,3,2,'2026-2027'), (3,3,3,'2026-2027'),
 (5,3,4,'2026-2027'), (6,3,5,'2026-2027'), (6,3,8,'2026-2027');

INSERT dbo.schedule (teacher_assignment_id, day_order, period, room, start_time, end_time) VALUES
 (1,2,1,N'P101','07:00','07:45'), (2,2,2,N'P101','07:50','08:35'),
 (3,3,1,N'P101','07:00','07:45'), (4,3,2,N'P101','07:50','08:35'),
 (5,4,1,N'P101','07:00','07:45'), (6,5,2,N'P101','07:50','08:35'),
 (7,2,2,N'P102','07:50','08:35'), (8,3,3,N'P102','08:40','09:25'),
 (9,4,2,N'P102','07:50','08:35'), (10,5,1,N'P102','07:00','07:45'),
 (11,6,2,N'P102','07:50','08:35'), (12,7,3,N'LAB-01','08:40','09:25'),
 (13,2,3,N'P201','08:40','09:25'), (14,3,1,N'P201','07:00','07:45'),
 (15,4,3,N'P201','08:40','09:25'), (16,5,2,N'P201','07:50','08:35'),
 (17,6,1,N'LAB-02','07:00','07:45'), (18,7,2,N'P201','07:50','08:35');

-- Một grade là kết quả một môn/học kỳ; mỗi grade_item là đúng một đầu điểm.
INSERT dbo.grade (student_id, teacher_assignment_id, semester_id, average_score) VALUES
 (1,1,1,8.67), (1,2,1,8.17), (1,3,1,8.58), (1,4,1,7.67),
 (1,5,1,8.25), (1,6,1,8.83), (2,1,1,7.25), (2,2,1,7.83),
 (3,7,1,8.83), (3,8,1,7.92), (5,13,1,9.09), (5,14,1,8.25);

INSERT dbo.grade_item (grade_id,name,score,weight) VALUES
 (1,N'Kiểm tra 15 phút',8.00,1),(1,N'Giữa kỳ',8.50,2),(1,N'Cuối kỳ',9.00,3),
 (2,N'Kiểm tra 15 phút',7.50,1),(2,N'Giữa kỳ',8.00,2),(2,N'Cuối kỳ',8.50,3),
 (3,N'Kiểm tra 15 phút',8.50,1),(3,N'Giữa kỳ',8.00,2),(3,N'Cuối kỳ',9.00,3),
 (4,N'Kiểm tra 15 phút',7.00,1),(4,N'Giữa kỳ',7.50,2),(4,N'Cuối kỳ',8.00,3),
 (5,N'Kiểm tra 15 phút',8.00,1),(5,N'Giữa kỳ',8.00,2),(5,N'Cuối kỳ',8.50,3),
 (6,N'Kiểm tra 15 phút',9.00,1),(6,N'Giữa kỳ',8.50,2),(6,N'Cuối kỳ',9.00,3),
 (7,N'Kiểm tra 15 phút',7.00,1),(7,N'Giữa kỳ',7.00,2),(7,N'Cuối kỳ',7.50,3),
 (8,N'Kiểm tra 15 phút',8.00,1),(8,N'Giữa kỳ',7.50,2),(8,N'Cuối kỳ',8.00,3),
 (9,N'Kiểm tra 15 phút',9.00,1),(9,N'Giữa kỳ',8.50,2),(9,N'Cuối kỳ',9.00,3),
 (10,N'Kiểm tra 15 phút',7.50,1),(10,N'Giữa kỳ',8.00,2),(10,N'Cuối kỳ',8.00,3),
 (11,N'Kiểm tra 15 phút',9.00,1),(11,N'Giữa kỳ',9.00,2),(11,N'Cuối kỳ',9.17,3),
 (12,N'Kiểm tra 15 phút',8.00,1),(12,N'Giữa kỳ',8.00,2),(12,N'Cuối kỳ',8.50,3);

INSERT dbo.leave_request (student_id, created_by_id, from_date, to_date, reason, status, reviewed_by_id, reviewed_at, rejection_reason) VALUES
 (1,7,'2026-09-15','2026-09-16',N'Gia đình có việc riêng.','PENDING',NULL,NULL,NULL),
 (2,7,'2026-08-25','2026-08-25',N'Khám sức khỏe định kỳ.','APPROVED',2,'2026-08-24T15:00:00',NULL),
 (4,8,'2026-09-05','2026-09-07',N'Về quê cùng gia đình.','REJECTED',4,'2026-09-04T16:30:00',N'Trùng lịch kiểm tra giữa kỳ.'),
 (6,9,'2026-08-17','2026-08-17',N'Học sinh bị sốt.','APPROVED',6,'2026-08-16T20:00:00',NULL);

INSERT dbo.student_evaluation (student_id,class_id,semester_id,homeroom_teacher_id,conduct_rating,academic_rating,comment) VALUES
 (1,1,1,2,'EXCELLENT','GOOD',N'Chăm chỉ, tích cực tham gia hoạt động lớp.'),
 (2,1,1,2,'GOOD','GOOD',N'Có tinh thần học tập tốt.'),
 (3,2,1,4,'EXCELLENT','EXCELLENT',N'Kết quả học tập nổi bật.'),
 (5,3,1,6,'GOOD','EXCELLENT',N'Cần duy trì sự chủ động trong học tập.');

INSERT dbo.notification (title, content, sender_id, class_id) VALUES
 (N'Lịch kiểm tra Toán',N'Lớp 10A1 kiểm tra 45 phút vào tiết 1 thứ Hai.',2,1),
 (N'Nhắc nộp bài Ngữ văn',N'Học sinh hoàn thành bài nghị luận trước thứ Sáu.',4,1),
 (N'Thực hành Tin học',N'Lớp 10A2 học tại phòng LAB-01 và mang theo tài khoản cá nhân.',5,2),
 (N'Ôn tập giữa kỳ',N'Lớp 11A1 xem lại nội dung các chương đã học.',6,3),
 (N'Thông báo toàn trường',N'Nhà trường tổ chức sinh hoạt dưới cờ lúc 07:00 thứ Hai.',1,NULL);

INSERT dbo.event (title,description,location,event_date,event_time) VALUES
 (N'Ngày hội câu lạc bộ',N'Giới thiệu và tuyển thành viên cho các câu lạc bộ học sinh.',N'Sân trường','2026-09-05','08:00'),
 (N'Giải bóng đá học sinh',N'Vòng bảng giải bóng đá FPT Schools năm học 2026-2027.',N'Sân thể thao','2026-09-20','15:30'),
 (N'Hội thảo định hướng nghề nghiệp',N'Giao lưu cùng chuyên gia công nghệ và cựu học sinh.',N'Hội trường A','2026-10-10','09:00'),
 (N'Ngày Nhà giáo Việt Nam',N'Chương trình văn nghệ chào mừng ngày 20/11.',N'Hội trường lớn','2026-11-20','07:30');

INSERT dbo.club (name,description,category,meeting_time,location,contact,member_count) VALUES
 (N'Câu lạc bộ Lập trình',N'Rèn luyện tư duy thuật toán và xây dựng sản phẩm phần mềm.',N'Học thuật',N'15:30 thứ Sáu',N'LAB-02','clb.laptrinh@fptschools.local',32),
 (N'Câu lạc bộ Tiếng Anh',N'Giao tiếp tiếng Anh qua trò chơi, thuyết trình và tranh biện.',N'Ngoại ngữ',N'16:00 thứ Tư',N'P203','clb.english@fptschools.local',28),
 (N'Câu lạc bộ Bóng đá',N'Tập luyện kỹ thuật và tham gia giải đấu học sinh.',N'Thể thao',N'16:30 thứ Ba, thứ Năm',N'Sân thể thao','0909000001',40),
 (N'Câu lạc bộ Âm nhạc',N'Không gian luyện tập thanh nhạc và nhạc cụ.',N'Nghệ thuật',N'15:30 thứ Bảy',N'Phòng âm nhạc','clb.amnhac@fptschools.local',24),
 (N'Câu lạc bộ Truyền thông',N'Sáng tạo nội dung, nhiếp ảnh và truyền thông sự kiện.',N'Kỹ năng',N'16:00 thứ Hai',N'P105','clb.media@fptschools.local',20);
GO
