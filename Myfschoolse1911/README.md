# FPT Schools

Dự án ứng dụng quản lý trường học dành cho Sinh viên, Phụ huynh và Giáo viên.

## 1. Hướng dẫn chạy

### Bước 1: Khởi tạo Database
Mở **SQL Server** (chạy tại `localhost:1433`, user `sa`, pass `123` - có thể đổi trong `backend/src/main/resources/application.yaml`).
Mở CMD/PowerShell tại thư mục gốc của dự án và chạy lệnh sau để nạp bảng & dữ liệu mẫu (nhớ dùng UTF-8 để không lỗi tiếng Việt):
```bash
sqlcmd -f 65001 -S localhost -U sa -P 123 -i backend\src\main\resources\create_table.sql
```

### Bước 2: Chạy Backend (Spring Boot)
```bash
cd backend
.\mvnw spring-boot:run
```
Backend sẽ chạy tại `http://localhost:8080`.

### Bước 3: Chạy Frontend (Flutter)
```bash
flutter pub get
flutter run
```


## 2. Tài khoản Demo

Tất cả tài khoản đều có mật khẩu chung là: `123456`

| Vai trò | Số điện thoại | Người dùng |
|--------|---------------|------------|
|Học sinh| `0999111111` | Đặng Minh Hiếu |
|Phụ huynh| `0988111111` | Đặng Xuân Thành |
|Đa Vai Trò| `0988000001` | Cô Lê Thị Vân |
