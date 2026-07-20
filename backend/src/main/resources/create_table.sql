-- ============================================================
-- FPT Student Life – Database schema (SQL Server 2019)
-- Luồng theo sơ đồ: Login/ResetPass → HomePage →
--   ListDiemHK · LichHoc · SuKien · DonTu · CLB
--
-- 10 bảng: app_user, school_class, student, grade, attendance,
--          leave_request, notification, schedule, event, club
-- Có sẵn dữ liệu mẫu + tài khoản đăng nhập (Sinh viên / Phụ huynh / Giáo viên)
-- ============================================================

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'myfs')
BEGIN
    CREATE DATABASE myfs;
END
--GO

USE myfs;
--GO

-- ── Xóa bảng cũ theo đúng thứ tự phụ thuộc khóa ngoại ───────────────
IF OBJECT_ID('dbo.club',          'U') IS NOT NULL DROP TABLE dbo.club;
IF OBJECT_ID('dbo.event',         'U') IS NOT NULL DROP TABLE dbo.event;
IF OBJECT_ID('dbo.schedule',      'U') IS NOT NULL DROP TABLE dbo.schedule;
IF OBJECT_ID('dbo.notification',  'U') IS NOT NULL DROP TABLE dbo.notification;
IF OBJECT_ID('dbo.leave_request', 'U') IS NOT NULL DROP TABLE dbo.leave_request;
IF OBJECT_ID('dbo.attendance',    'U') IS NOT NULL DROP TABLE dbo.attendance;
IF OBJECT_ID('dbo.grade',         'U') IS NOT NULL DROP TABLE dbo.grade;
IF OBJECT_ID('dbo.Grade',         'U') IS NOT NULL DROP TABLE dbo.Grade;  -- bảng cũ
IF OBJECT_ID('dbo.student',       'U') IS NOT NULL DROP TABLE dbo.student;
IF OBJECT_ID('dbo.school_class',  'U') IS NOT NULL DROP TABLE dbo.school_class;
IF OBJECT_ID('dbo.app_user',      'U') IS NOT NULL DROP TABLE dbo.app_user;
--GO

-- ============================================================
-- 1. app_user – tài khoản đăng nhập
--    role: 'STUDENT' | 'PARENT' | 'TEACHER'
--    student_id: gắn tài khoản với 1 học sinh (dùng cho STUDENT/PARENT)
-- ============================================================
CREATE TABLE dbo.app_user (
    id          INT           IDENTITY(1,1) PRIMARY KEY,
    phone       VARCHAR(15)   NOT NULL UNIQUE,
    password    VARCHAR(100)  NOT NULL,                 -- demo: lưu thẳng
    full_name   NVARCHAR(100) NOT NULL,
    role        VARCHAR(10)   NOT NULL,
    email       VARCHAR(100)  NULL,
    avatar_url  VARCHAR(255)  NULL,
    student_id  INT           NULL,                     -- liên kết học sinh
    created_at  DATETIME      NOT NULL DEFAULT GETDATE()
);
--GO

-- ============================================================
-- 2. school_class – lớp học
-- ============================================================
CREATE TABLE dbo.school_class (
    id                  INT           IDENTITY(1,1) PRIMARY KEY,
    name                NVARCHAR(50)  NOT NULL,
    academic_year       VARCHAR(20)   NOT NULL,
    homeroom_teacher_id INT           NULL,
    CONSTRAINT FK_class_teacher FOREIGN KEY (homeroom_teacher_id)
        REFERENCES dbo.app_user(id)
);
--GO

-- ============================================================
-- 3. student – học sinh / sinh viên
-- ============================================================
CREATE TABLE dbo.student (
    id            INT           IDENTITY(1,1) PRIMARY KEY,
    student_code  VARCHAR(20)   NOT NULL UNIQUE,
    full_name     NVARCHAR(100) NOT NULL,
    date_of_birth DATE          NULL,
    gender        NVARCHAR(10)  NULL,
    class_id      INT           NULL,
    parent_id     INT           NULL,
    CONSTRAINT FK_student_class  FOREIGN KEY (class_id)  REFERENCES dbo.school_class(id),
    CONSTRAINT FK_student_parent FOREIGN KEY (parent_id) REFERENCES dbo.app_user(id)
);
--GO

-- ============================================================
-- 4. grade – điểm học kỳ (ListDiemHK)
-- ============================================================
CREATE TABLE dbo.grade (
    id            INT           IDENTITY(1,1) PRIMARY KEY,
    student_id    INT           NOT NULL,
    student_code  VARCHAR(20)   NOT NULL,
    student_name  NVARCHAR(100) NOT NULL,
    subject        NVARCHAR(100) NOT NULL,
    regular_scores VARCHAR(50)   NULL,
    midterm_score  DECIMAL(5,2)  NULL CHECK (midterm_score >= 0 AND midterm_score <= 100),
    final_score    DECIMAL(5,2)  NULL CHECK (final_score >= 0 AND final_score <= 100),
    average_score  DECIMAL(5,2)  NULL CHECK (average_score >= 0 AND average_score <= 100),
    grade_letter   VARCHAR(5)    NULL,
    semester       VARCHAR(20)   NOT NULL,
    academic_year VARCHAR(20)   NOT NULL,
    teacher_name  NVARCHAR(100) NOT NULL,
    created_at    DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_grade_student FOREIGN KEY (student_id) REFERENCES dbo.student(id)
);
--GO

-- ============================================================
-- 5. attendance – điểm danh / chuyên cần
-- ============================================================
CREATE TABLE dbo.attendance (
    id              INT           IDENTITY(1,1) PRIMARY KEY,
    student_id      INT           NOT NULL,
    student_code    VARCHAR(20)   NOT NULL,
    student_name    NVARCHAR(100) NOT NULL,
    att_date        DATE          NOT NULL,
    status          VARCHAR(10)   NOT NULL,
    note            NVARCHAR(255) NULL,
    recorded_by_id  INT           NULL,
    created_at      DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_att_student FOREIGN KEY (student_id) REFERENCES dbo.student(id)
);
--GO

-- ============================================================
-- 6. leave_request – đơn từ / xin nghỉ (DonTu)
-- ============================================================
CREATE TABLE dbo.leave_request (
    id              INT           IDENTITY(1,1) PRIMARY KEY,
    student_id      INT           NOT NULL,
    student_code    VARCHAR(20)   NOT NULL,
    student_name    NVARCHAR(100) NOT NULL,
    class_name      NVARCHAR(50)  NULL,
    leave_type      VARCHAR(20)   NOT NULL DEFAULT 'ABSENT',
    title           NVARCHAR(200) NULL,
    from_date       DATE          NOT NULL,
    to_date         DATE          NOT NULL,
    time_value      VARCHAR(10)   NULL,
    reason          NVARCHAR(500) NOT NULL,
    status          VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
    created_by_id   INT           NULL,
    reviewed_by_id  INT           NULL,
    created_at      DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_leave_student FOREIGN KEY (student_id) REFERENCES dbo.student(id)
);
--GO

-- ============================================================
-- 7. notification – thông báo
-- ============================================================
CREATE TABLE dbo.notification (
    id          INT           IDENTITY(1,1) PRIMARY KEY,
    title       NVARCHAR(200) NOT NULL,
    content     NVARCHAR(MAX) NOT NULL,
    sender_id   INT           NULL,
    sender_name NVARCHAR(100) NULL,
    class_id    INT           NULL,
    class_name  NVARCHAR(50)  NULL,
    created_at  DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_noti_sender FOREIGN KEY (sender_id) REFERENCES dbo.app_user(id)
);
--GO

-- ============================================================
-- 8. schedule – lịch học / thời khóa biểu (LichHoc)
-- ============================================================
CREATE TABLE dbo.schedule (
    id           INT           IDENTITY(1,1) PRIMARY KEY,
    class_id     INT           NOT NULL,
    day_order    INT           NOT NULL,          -- 2=Thứ 2 ... 7=Thứ 7, 8=CN
    period       INT           NOT NULL,          -- tiết trong ngày
    subject      NVARCHAR(100) NOT NULL,
    room         NVARCHAR(50)  NULL,
    teacher_name NVARCHAR(100) NULL,
    start_time   VARCHAR(10)   NULL,              -- "07:00"
    end_time     VARCHAR(10)   NULL,
    CONSTRAINT FK_schedule_class FOREIGN KEY (class_id) REFERENCES dbo.school_class(id)
);
--GO

-- ============================================================
-- 9. event – sự kiện (SuKien)
-- ============================================================
CREATE TABLE dbo.event (
    id          INT           IDENTITY(1,1) PRIMARY KEY,
    title       NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX) NULL,
    location    NVARCHAR(150) NULL,
    event_date  DATE          NOT NULL,
    event_time  VARCHAR(20)   NULL,
    created_at  DATETIME      NOT NULL DEFAULT GETDATE()
);
--GO

-- ============================================================
-- 10. club – câu lạc bộ (CLB)
-- ============================================================
CREATE TABLE dbo.club (
    id           INT           IDENTITY(1,1) PRIMARY KEY,
    name         NVARCHAR(150) NOT NULL,
    description  NVARCHAR(MAX) NULL,
    category     NVARCHAR(50)  NULL,              -- Học thuật / Thể thao / Nghệ thuật...
    meeting_time NVARCHAR(100) NULL,
    location     NVARCHAR(150) NULL,
    contact      NVARCHAR(100) NULL,
    member_count INT           NOT NULL DEFAULT 0
);
--GO

-- ============================================================
--  DỮ LIỆU MẪU (seed)
-- ============================================================

-- ── Tài khoản (mật khẩu demo: 123456) ───────────────────────────────
SET IDENTITY_INSERT dbo.app_user ON;
INSERT INTO dbo.app_user (id, phone, password, full_name, role, email, student_id) VALUES
    (1, '0988000001', '123456', N'Lê Thị Vân',       'TEACHER', 'van.lt@fschool.edu.vn', NULL),
    (2, '0988111111', '123456', N'Đặng Xuân Thành',  'PARENT',  NULL, 1),
    (3, '0988222222', '123456', N'Trương Đình Lộc',  'PARENT',  NULL, 2),
    (4, '0988333333', '123456', N'Lý Cẩm Tú',        'PARENT',  NULL, 3),
    (5, '0988444444', '123456', N'Phan Quyết Thắng', 'PARENT',  NULL, 4),
    (6, '0988555555', '123456', N'Vũ Quỳnh Nga',     'PARENT',  NULL, 5),
    (7, '0999111111', '123456', N'Đặng Minh Hiếu',   'STUDENT', 'hieu.dm@fschool.edu.vn', 1),
    (8, '0999222222', '123456', N'Trương Diệu Linh', 'STUDENT', 'linh.td@fschool.edu.vn', 2);
SET IDENTITY_INSERT dbo.app_user OFF;
--GO

-- ── Lớp 10A1, GVCN = Lê Thị Vân (id=1) ────────────────────────────
SET IDENTITY_INSERT dbo.school_class ON;
INSERT INTO dbo.school_class (id, name, academic_year, homeroom_teacher_id) VALUES
    (1, N'10A1', '2025-2026', 1);
SET IDENTITY_INSERT dbo.school_class OFF;
--GO

-- ── Học sinh ────────────────────────────────────────────────────────
SET IDENTITY_INSERT dbo.student ON;
INSERT INTO dbo.student (id, student_code, full_name, date_of_birth, gender, class_id, parent_id) VALUES
    (1, 'HS001', N'Đặng Minh Hiếu',   '2009-04-10', N'Nam', 1, 2),
    (2, 'HS002', N'Trương Diệu Linh', '2009-08-20', N'Nữ',  1, 3),
    (3, 'HS003', N'Nguyễn Tuấn Kiệt', '2009-02-14', N'Nam', 1, 1), -- Cô Lê Thị Vân (id=1) vừa là GVCN vừa là phụ huynh bé này
    (4, 'HS004', N'Phan Thùy Châu',   '2009-12-05', N'Nữ',  1, 5),
    (5, 'HS005', N'Vũ Hải Đăng',      '2009-06-22', N'Nam', 1, 6),
    (6, 'HS006', N'Đặng Quỳnh Anh',   '2009-04-10', N'Nữ',  1, 2);
SET IDENTITY_INSERT dbo.student OFF;
--GO

-- ── Điểm (ListDiemHK) ───────────────────────────────────────────────
INSERT INTO dbo.grade (student_id, student_code, student_name, subject, regular_scores, midterm_score, final_score, average_score, grade_letter, semester, academic_year, teacher_name) VALUES
    (1, 'HS001', N'Đặng Minh Hiếu', N'Toán',     '8.5,9.0', 9.5, 9.5, 9.3, 'A',  'HK1', '2025-2026', N'Lê Thị Vân'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Văn',      '7.5,8.0', 8.5, 8.5, 8.4, 'B+', 'HK1', '2025-2026', N'Phạm Thanh Thủy'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Anh',      '8.0,9.0', 8.5, 9.0, 8.8, 'B+', 'HK1', '2025-2026', N'Lê Thị Vân'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Vật lý',   '8.0,8.5', 8.0, 8.5, 8.3, 'B+', 'HK1', '2025-2026', N'Đinh Trọng Quý'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Hóa học',  '7.0,8.0', 8.5, 8.0, 8.0, 'B+', 'HK1', '2025-2026', N'Trần Minh Hoàng'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Sinh học', '9.0,9.0', 9.0, 8.5, 8.8, 'A',  'HK1', '2025-2026', N'Hoàng Thu Phương'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Lịch sử',  '8.5,8.5', 8.0, 8.5, 8.4, 'B+', 'HK1', '2025-2026', N'Phạm Thanh Thủy'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Địa lý',   '9.0,8.0', 8.5, 8.5, 8.5, 'A',  'HK1', '2025-2026', N'Đinh Trọng Quý'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'GDCD',     '9.0,10',  9.5, 9.5, 9.5, 'A',  'HK1', '2025-2026', N'Lê Thị Vân'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Tin học',  '8.0,8.5', 9.0, 8.5, 8.6, 'A',  'HK1', '2025-2026', N'Trần Minh Hoàng'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Công nghệ','8.5,8.5', 8.5, 8.5, 8.5, 'A',  'HK1', '2025-2026', N'Hoàng Thu Phương'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Thể dục',  '10,10',   10,  10,  10,  'A',  'HK1', '2025-2026', N'Đinh Trọng Quý'),

    (1, 'HS001', N'Đặng Minh Hiếu', N'Toán',     '9.0,9.0', 9.0, NULL, NULL, NULL,  'HK2', '2025-2026', N'Lê Thị Vân'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Văn',      '8.0,8.5', NULL, NULL, NULL, NULL,  'HK2', '2025-2026', N'Phạm Thanh Thủy'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Anh',      '8.5,9.0', 8.5, NULL, NULL, NULL,  'HK2', '2025-2026', N'Lê Thị Vân'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Vật lý',   NULL, NULL, NULL, NULL, NULL,  'HK2', '2025-2026', N'Đinh Trọng Quý'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Hóa học',  NULL, NULL, NULL, NULL, NULL,  'HK2', '2025-2026', N'Trần Minh Hoàng'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Sinh học', NULL, NULL, NULL, NULL, NULL,  'HK2', '2025-2026', N'Hoàng Thu Phương'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Lịch sử',  NULL, NULL, NULL, NULL, NULL,  'HK2', '2025-2026', N'Phạm Thanh Thủy'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Địa lý',   NULL, NULL, NULL, NULL, NULL,  'HK2', '2025-2026', N'Đinh Trọng Quý'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'GDCD',     NULL, NULL, NULL, NULL, NULL,  'HK2', '2025-2026', N'Lê Thị Vân'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Tin học',  NULL, NULL, NULL, NULL, NULL,  'HK2', '2025-2026', N'Trần Minh Hoàng'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Công nghệ',NULL, NULL, NULL, NULL, NULL,  'HK2', '2025-2026', N'Hoàng Thu Phương'),
    (1, 'HS001', N'Đặng Minh Hiếu', N'Thể dục',  NULL, NULL, NULL, NULL, NULL,  'HK2', '2025-2026', N'Đinh Trọng Quý'),

    (2, 'HS002', N'Trương Diệu Linh', N'Toán', '8.0,9.0', 8.0, 8.5, 8.5, 'B+', 'HK1', '2025-2026', N'Lê Thị Vân'),
    (2, 'HS002', N'Trương Diệu Linh', N'Vật lý','7.0,8.0', 8.0, 8.0, 7.9, 'B',  'HK1', '2025-2026', N'Đinh Trọng Quý'),
    (2, 'HS002', N'Trương Diệu Linh', N'Hóa học','8.0,8.0', 8.0, 8.5, 8.1, 'B+', 'HK2', '2025-2026', N'Trần Minh Hoàng'),
    
    (6, 'HS006', N'Đặng Quỳnh Anh', N'Toán', '7.0,8.0', 7.5, 8.0, 7.6, 'B',  'HK1', '2025-2026', N'Lê Thị Vân'),
    (6, 'HS006', N'Đặng Quỳnh Anh', N'Văn',  '9.0,9.0', 9.0, 9.5, 9.1, 'A',  'HK1', '2025-2026', N'Phạm Thanh Thủy');
--GO

-- ── Điểm danh ───────────────────────────────────────────────────────
INSERT INTO dbo.attendance (student_id, student_code, student_name, att_date, status, note, recorded_by_id) VALUES
    (1, 'HS001', N'Đặng Minh Hiếu', '2026-06-24', 'PRESENT', NULL,             1),
    (1, 'HS001', N'Đặng Minh Hiếu', '2026-06-25', 'LATE',    N'Đi muộn 10p',   1),
    (2, 'HS002', N'Trương Diệu Linh', '2026-06-25', 'ABSENT',  N'Nghỉ không phép',1);
--GO

-- ── Đơn từ / xin nghỉ (DonTu) ───────────────────────────────────────
INSERT INTO dbo.leave_request (student_id, student_code, student_name, class_name, leave_type, title, from_date, to_date, time_value, reason, status, created_by_id) VALUES
    (1, 'HS001', N'Đặng Minh Hiếu', N'10A1', 'ABSENT', NULL, '2026-09-15', '2026-09-16', NULL, N'Gia đình có việc hiếu hỉ ở quê, xin phép cho cháu nghỉ 2 ngày.', 'APPROVED', 7),
    (1, 'HS001', N'Đặng Minh Hiếu', N'10A1', 'EARLY', NULL, '2026-09-20', '2026-09-20', '15:00', N'Cháu có lịch khám nha khoa định kỳ vào buổi chiều.', 'PENDING_TEACHER', 7),
    (1, 'HS001', N'Đặng Minh Hiếu', N'10A1', 'OTHER', N'Xin cấp lại thẻ gửi xe', '2026-09-25', '2026-09-25', NULL, N'Cháu làm mất thẻ gửi xe tháng, xin nhà trường cấp lại.', 'PENDING_SCHOOL', 7);
--GO

-- ── Thông báo ───────────────────────────────────────────────────────
INSERT INTO dbo.notification (title, content, sender_id, sender_name, class_id, class_name) VALUES
    (N'Thông báo lịch kiểm tra định kỳ giữa học kỳ I', N'Kính gửi Quý phụ huynh và các em học sinh lớp 10A1,
Tuần tới (từ ngày 10/10 đến 15/10/2026) nhà trường sẽ tổ chức kỳ thi đánh giá năng lực giữa kỳ I cho tất cả các môn học.
Đề nghị các em học sinh tập trung ôn tập, hệ thống lại kiến thức đã học. Quý phụ huynh vui lòng đôn đốc, nhắc nhở các em phân bổ thời gian hợp lý để đạt được kết quả cao nhất.
Lịch thi chi tiết từng môn đã được dán tại bảng tin của lớp và cập nhật trên hệ thống. Trân trọng!', 1, N'Lê Thị Vân', 1, N'10A1'),
    (N'Chương trình dã ngoại ngoại khóa tháng 11', N'Ban giám hiệu trường THPT FSchool trân trọng thông báo về chương trình dã ngoại ngoại khóa "Khám phá thiên nhiên - Rèn luyện kỹ năng sinh tồn".
Thời gian: Ngày 15-16 tháng 11 năm 2026 (Thứ Bảy và Chủ Nhật).
Địa điểm: Khu du lịch sinh thái Vườn Quốc gia Ba Vì.
Hoạt động: Teambuilding, thi cắm trại, nấu ăn và giao lưu văn nghệ lửa trại.
Kinh phí dự kiến: 500.000 VNĐ / học sinh (Bao gồm xe di chuyển, vé vào cửa, các bữa ăn và bảo hiểm).
Phụ huynh vui lòng điền phiếu xác nhận và đóng kinh phí cho giáo viên chủ nhiệm trước ngày 05/11. Rất mong các em tham gia đầy đủ để tăng cường tình đoàn kết!', 1, N'Lê Thị Vân', NULL, NULL);
--GO

-- ── Lịch học / TKB lớp 10A1 (LichHoc) ───────────────────────────────
INSERT INTO dbo.schedule (class_id, day_order, period, subject, room, teacher_name, start_time, end_time) VALUES
-- Thứ 2
    (1, 2, 1, N'Toán học',   N'P.201', N'Lê Thị Vân',        '07:00', '07:45'),
    (1, 2, 2, N'Ngữ văn',    N'P.201', N'Phạm Thanh Thủy',   '07:50', '08:35'),
    (1, 2, 3, N'Ngữ văn',    N'P.201', N'Phạm Thanh Thủy',   '08:45', '09:30'),
    (1, 2, 4, N'Tiếng Anh',  N'P.201', N'Lê Thị Vân',        '09:35', '10:20'),
    (1, 2, 5, N'Vật lý',     N'P.202', N'Đinh Trọng Quý',    '10:25', '11:10'),
    (1, 2, 6, N'Tin học',    N'Lab 1', N'Lê Đức Cường',      '13:30', '14:15'),
    (1, 2, 7, N'Sinh học',   N'P.203', N'Trịnh Thanh Hà',    '14:20', '15:05'),
-- Thứ 3
    (1, 3, 1, N'Hóa học',    N'P.202', N'Trần Minh Hoàng',   '07:00', '07:45'),
    (1, 3, 2, N'Hóa học',    N'P.202', N'Trần Minh Hoàng',   '07:50', '08:35'),
    (1, 3, 3, N'Toán học',   N'P.201', N'Lê Thị Vân',        '08:45', '09:30'),
    (1, 3, 4, N'Thể dục',    N'Sân TĐ',N'Trần Văn Sơn',      '09:35', '10:20'),
    (1, 3, 5, N'GDCD',       N'P.205', N'Vũ Minh Đức',       '10:25', '11:10'),
    (1, 3, 6, N'Lịch sử',    N'P.204', N'Nguyễn Thu Trang',  '13:30', '14:15'),
    (1, 3, 7, N'Lịch sử',    N'P.204', N'Nguyễn Thu Trang',  '14:20', '15:05'),
    (1, 3, 8, N'Tiếng Anh',  N'P.201', N'Lê Thị Vân',        '15:15', '16:00'),
-- Thứ 4
    (1, 4, 1, N'Ngữ văn',    N'P.201', N'Phạm Thanh Thủy',   '07:00', '07:45'),
    (1, 4, 2, N'Toán học',   N'P.201', N'Lê Thị Vân',        '07:50', '08:35'),
    (1, 4, 3, N'Vật lý',     N'P.202', N'Đinh Trọng Quý',    '08:45', '09:30'),
    (1, 4, 4, N'Sinh học',   N'P.203', N'Trịnh Thanh Hà',    '09:35', '10:20'),
    (1, 4, 5, N'Sinh học',   N'P.203', N'Trịnh Thanh Hà',    '10:25', '11:10'),
    (1, 4, 6, N'Thể dục',    N'Sân TĐ',N'Trần Văn Sơn',      '13:30', '14:15'),
    (1, 4, 7, N'Địa lý',     N'P.205', N'Vũ Minh Đức',       '14:20', '15:05'),
    (1, 4, 8, N'Tin học',    N'Lab 1', N'Lê Đức Cường',      '15:15', '16:00'),
-- Thứ 5
    (1, 5, 1, N'Tiếng Anh',  N'P.201', N'Lê Thị Vân',        '07:00', '07:45'),
    (1, 5, 2, N'Tiếng Anh',  N'P.201', N'Lê Thị Vân',        '07:50', '08:35'),
    (1, 5, 3, N'Ngữ văn',    N'P.201', N'Phạm Thanh Thủy',   '08:45', '09:30'),
    (1, 5, 4, N'Hóa học',    N'P.202', N'Trần Minh Hoàng',   '09:35', '10:20'),
    (1, 5, 5, N'Hóa học',    N'P.202', N'Trần Minh Hoàng',   '10:25', '11:10'),
    (1, 5, 6, N'Toán học',   N'P.201', N'Lê Thị Vân',        '13:30', '14:15'),
    (1, 5, 7, N'Toán học',   N'P.201', N'Lê Thị Vân',        '14:20', '15:05'),
-- Thứ 6
    (1, 6, 1, N'Vật lý',     N'P.202', N'Đinh Trọng Quý',    '07:00', '07:45'),
    (1, 6, 2, N'Vật lý',     N'P.202', N'Đinh Trọng Quý',    '07:50', '08:35'),
    (1, 6, 3, N'Địa lý',     N'P.205', N'Vũ Minh Đức',       '08:45', '09:30'),
    (1, 6, 4, N'Ngữ văn',    N'P.201', N'Phạm Thanh Thủy',   '09:35', '10:20'),
    (1, 6, 5, N'Toán học',   N'P.201', N'Lê Thị Vân',        '10:25', '11:10'),
    (1, 6, 6, N'Tiếng Anh',  N'P.201', N'Lê Thị Vân',        '13:30', '14:15'),
    (1, 6, 7, N'GDCD',       N'P.205', N'Vũ Minh Đức',       '14:20', '15:05'),
    (1, 6, 8, N'Sinh hoạt',  N'P.201', N'Lê Thị Vân',        '15:15', '16:00');
--GO

-- ── Sự kiện (SuKien) ────────────────────────────────────────────────
INSERT INTO dbo.event (title, description, location, event_date, event_time) VALUES
    (N'Lễ hội Khoa học Công nghệ (STEM Day)', N'Ngày hội trưng bày và trình diễn các sản phẩm khoa học kỹ thuật do chính tay các học sinh trong trường chế tạo. Sẽ có các gian hàng trải nghiệm công nghệ thực tế ảo (VR), đua xe mô hình tự chế, và cuộc thi bắn tên lửa nước. Mọi học sinh đều được hoan nghênh tham gia và bình chọn cho dự án mình yêu thích nhất.', N'Sân trường', '2026-10-25', N'08:00'),
    (N'Cuộc thi "Giọng hát vàng FSchool"', N'Vòng chung kết cuộc thi tìm kiếm tài năng âm nhạc quy mô toàn trường. 10 thí sinh xuất sắc nhất từ vòng loại sẽ tranh tài với những tiết mục được đầu tư vô cùng công phu. Khán giả hãy chuẩn bị sẵn tinh thần để bùng nổ cùng các màn trình diễn đỉnh cao và đừng quên mang theo lightstick để cổ vũ cho thần tượng của mình.', N'Hội trường lớn', '2026-11-20', N'19:00'),
    (N'Hội chợ từ thiện Mùa Đông Ấm', N'Một sự kiện vô cùng ý nghĩa nhằm gây quỹ quyên góp quần áo, sách vở và tiền mặt ủng hộ trẻ em vùng cao trước khi mùa đông tới. Các lớp sẽ tổ chức các gian hàng bán đồ ăn vặt, đồ handmade, đồ cũ tái chế. Toàn bộ lợi nhuận sẽ được đóng góp trực tiếp vào quỹ của nhà trường. Hãy cùng lan tỏa yêu thương nhé!', N'Sân bóng rổ', '2026-12-15', N'15:00');
--GO

-- ── Câu lạc bộ (CLB) ────────────────────────────────────────────────
INSERT INTO dbo.club (name, description, category, meeting_time, location, contact, member_count) VALUES
    (N'CLB Nhiếp ảnh (Lens Art)', N'Học kỹ thuật chụp ảnh, chỉnh sửa ảnh, thường xuyên đi thực tế tác nghiệp tại các danh lam thắng cảnh.', N'Nghệ thuật', N'Sáng Chủ Nhật', N'Phòng Media', N'lensart@fschool.edu.vn', 35),
    (N'CLB Khởi nghiệp Trẻ (StartUp Club)', N'Bồi dưỡng tư duy kinh doanh, lập kế hoạch dự án khởi nghiệp, thi đấu gọi vốn giả định.', N'Học thuật', N'Chiều Thứ 5', N'Phòng họp số 2', N'startup@fschool.edu.vn', 40),
    (N'CLB Cờ Vua & Cờ Tướng', N'Nơi quy tụ những bộ óc chiến thuật xuất sắc, thường xuyên tổ chức giải đấu giao lưu với các trường bạn.', N'Thể thao trí tuệ', N'Chiều Thứ 4', N'Thư viện', N'chess@fschool.edu.vn', 25),
    (N'CLB Tình nguyện Xanh', N'Tổ chức các chiến dịch dọn dẹp môi trường, tái chế rác thải và trồng cây xanh xung quanh khu vực.', N'Tình nguyện', N'Sáng Thứ 7', N'Sân trường', N'greenlife@fschool.edu.vn', 80);
--GO

PRINT 'Seed data created successfully!';
--GO
