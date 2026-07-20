# REST API tối giản

Backend không dùng JWT, access token, session hoặc header `Authorization`.

`POST /api/auth/login` nhận `phone` và `password`. Nếu đúng, API trả về `user`, `role` và dữ liệu liên kết cơ bản. Client lưu user trong bộ nhớ/local storage và điều hướng giao diện theo `role`.

## Admin

- `GET|POST /api/admin/users`
- `PUT|DELETE /api/admin/users/{id}`
- `GET|POST /api/admin/students`
- `PUT|DELETE /api/admin/students/{id}`
- `GET|POST /api/admin/classes`
- `PUT|DELETE /api/admin/classes/{id}`
- `GET|POST /api/admin/subjects`
- `PUT|DELETE /api/admin/subjects/{id}`
- `GET|POST /api/admin/semesters`
- `GET|POST /api/admin/assignments`
- `DELETE /api/admin/assignments/{id}`
- `GET|POST /api/admin/schedules`
- `PUT|DELETE /api/admin/schedules/{id}`

## Teacher

Các API giáo viên nhận `teacherId` dưới dạng query parameter và vẫn kiểm tra giáo viên có đúng assignment/GVCN hay không.

- `GET /api/teacher/assignments?teacherId={id}`
- `GET /api/teacher/schedule?teacherId={id}`
- `GET /api/teacher/assignments/{id}/students?teacherId={id}`
- `GET /api/teacher/assignments/{id}/grades?teacherId={id}`
- `PUT /api/teacher/assignments/{id}/students/{studentId}/grade?teacherId={id}`
- `GET|PUT /api/teacher/schedules/{scheduleId}/attendance?teacherId={id}&date=yyyy-MM-dd`
- `POST /api/teacher/classes/{classId}/notifications?teacherId={id}`
- Các API `/api/teacher/homeroom/**` cũng nhận `teacherId` và kiểm tra đúng GVCN.

## Parent và Student mobile

- `GET /api/portal/students/{studentId}/schedule`
- `GET /api/portal/students/{studentId}/grades`
- `GET /api/portal/students/{studentId}/attendance`
- `GET /api/portal/students/{studentId}/notifications`
- `GET /api/portal/students/{studentId}/leaves`
- `GET /api/clubs`
- `GET /api/events`

Tạo đơn xin nghỉ:

- `POST /api/portal/students/{studentId}/leaves`
- Body phải có `createdById` đúng bằng `student.parentId`.
- Không có endpoint riêng cho học sinh và không có loại đơn khác.

Đây là cơ chế tối giản phục vụ development/demo, không phải mô hình bảo mật production.
