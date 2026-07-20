# Thiết kế Database theo phân quyền

## Quyết định chính

- `app_user.role` chỉ chứa vai trò đăng nhập: `ADMIN`, `TEACHER`, `PARENT`, `STUDENT`.
- GVCN không phải một role đăng nhập riêng. Một giáo viên là GVCN khi `school_class.homeroom_teacher_id = app_user.id`.
- Quyền giáo viên bộ môn được xác định bằng `teacher_assignment` theo bộ bốn giáo viên - lớp - môn - học kỳ.
- `student.parent_id` là nguồn dữ liệu chuẩn cho quan hệ phụ huynh - học sinh: một phụ huynh có nhiều con, mỗi học sinh chỉ thuộc một phụ huynh.
- Chỉ tài khoản `PARENT` có `id = student.parent_id` mới được tạo đơn cho học sinh đó.
- Đơn chỉ có một loại cố định `ABSENT`; trạng thái chỉ gồm `PENDING`, `APPROVED`, `REJECTED`.
- GVCN nhận đơn qua chuỗi `leave_request.student_id -> student.class_id -> school_class.homeroom_teacher_id`.
- Điểm danh gắn với `schedule`, vì vậy backend có thể kiểm tra giáo viên đang điểm danh đúng lớp/tiết được phân công.
- Điểm gắn với `teacher_assignment`; GVCN đọc tổng hợp theo `class_id`, giáo viên bộ môn chỉ sửa dữ liệu thuộc assignment của mình.
- `student_evaluation` lưu hạnh kiểm/xếp loại cuối kỳ và người đánh giá phải là GVCN của lớp.

## Quan hệ nghiệp vụ

```text
app_user(PARENT) 1---N student ---N school_class ---1 app_user(TEACHER/GVCN)
                           |               |
                           |               +---N teacher_assignment ---1 subject
                           |                              |
                           +---N leave_request            +---N schedule
                           +---N grade                     +---N attendance
                           +---N student_evaluation
```

## Khởi tạo môi trường development

`src/main/resources/create_table.sql` là nguồn schema duy nhất. Script chủ động drop và tạo lại toàn bộ bảng, sau đó thêm một bộ seed data nhất quán cho bốn role. Không sử dụng migration và không giữ các cột legacy.

## Ràng buộc phải kiểm tra ở service

SQL Server `CHECK`/FK đảm bảo tính toàn vẹn cơ bản; các quy tắc phụ thuộc role cần được enforce ở backend transaction:

- tài khoản được gán làm GVCN hoặc assignment phải có role `TEACHER`;
- người tạo leave request phải có role `PARENT` và liên kết với học sinh;
- người duyệt phải đúng GVCN hiện tại của lớp học sinh;
- giáo viên chỉ sửa điểm, điểm danh và gửi thông báo cho assignment/lớp thuộc quyền;
- một lớp chỉ có một GVCN, nhưng một giáo viên có thể đồng thời dạy bộ môn và chủ nhiệm.
