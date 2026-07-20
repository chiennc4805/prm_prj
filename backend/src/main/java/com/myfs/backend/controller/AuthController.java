package com.myfs.backend.controller;

import com.myfs.backend.dao.AppUserDao;
import com.myfs.backend.dao.SchoolClassDao;
import com.myfs.backend.dao.StudentDao;
import com.myfs.backend.model.AppUser;
import com.myfs.backend.model.SchoolClass;
import com.myfs.backend.model.Student;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * AuthController – đăng nhập & đặt lại mật khẩu cho Flutter app.
 *
 * POST /api/auth/login           { phone, password }
 *   → 200 + { user, role, student, classId, children[], classes[] }
 *   → 401 nếu sai thông tin.
 * POST /api/auth/forgot-password { phone }
 *   → 200 + { message } (demo: gửi OTP).
 * POST /api/auth/update-password { phone, newPassword }
 *   → 200 + { message } (đổi mật khẩu thành công).
 *
 * Lưu ý (demo học tập): mật khẩu so sánh trực tiếp, chưa hash/JWT (xem README).
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AppUserDao userDao;
    private final StudentDao studentDao;
    private final SchoolClassDao classDao;

    public AuthController(AppUserDao userDao, StudentDao studentDao, SchoolClassDao classDao) {
        this.userDao = userDao;
        this.studentDao = studentDao;
        this.classDao = classDao;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> body) {
        String phone = body.getOrDefault("phone", "").trim();
        String password = body.getOrDefault("password", "");

        AppUser user = userDao.findByPhone(phone).orElse(null);
        if (user == null || !user.getPassword().equals(password)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("message", "Số điện thoại hoặc mật khẩu không đúng"));
        }

        Map<String, Object> result = new HashMap<>();
        result.put("user", user);
        result.put("role", user.getRole());

        // Xác định vai trò tự động (User có thể vừa là Giáo viên vừa là Phụ huynh)
        List<String> roles = new java.util.ArrayList<>();
        
        List<Student> children = studentDao.findByParentId(user.getId());
        if (!children.isEmpty()) {
            roles.add("PARENT");
            children.forEach(this::attachClassName);
            result.put("children", children);
        }
        
        List<SchoolClass> classes = classDao.findByHomeroomTeacherId(user.getId());
        if (!classes.isEmpty()) {
            roles.add("TEACHER");
            result.put("classes", classes);
        }
        
        // Nếu không có dữ liệu liên kết nào, dùng role cứng trong DB (ví dụ cho Học sinh)
        if (roles.isEmpty()) {
            roles.add(user.getRole());
        }

        result.put("role", roles.get(0)); // Giữ tương thích ngược với role chính
        result.put("roles", roles);       // Trả về danh sách tất cả các vai trò

        // Xác định "học sinh chính" để hiển thị dữ liệu (điểm, đơn từ...)
        Student primary = resolvePrimaryStudent(user, roles);
        if (primary != null) {
            attachClassName(primary);
            result.put("student", primary);
            result.put("classId", primary.getClassId());
        }

        return ResponseEntity.ok(result);
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody Map<String, String> body) {
        String phone = body.getOrDefault("phone", "").trim();
        AppUser user = userDao.findByPhone(phone).orElse(null);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", "Không tìm thấy tài khoản với số điện thoại này"));
        }
        return ResponseEntity.ok(Map.of("message", "Mã OTP đã được gửi đến số điện thoại của bạn."));
    }

    @PostMapping("/update-password")
    public ResponseEntity<?> updatePassword(@RequestBody Map<String, String> body) {
        String phone = body.getOrDefault("phone", "").trim();
        String newPassword = body.getOrDefault("newPassword", "");
        AppUser user = userDao.findByPhone(phone).orElse(null);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("message", "Không tìm thấy tài khoản với số điện thoại này"));
        }
        user.setPassword(newPassword);
        userDao.save(user);
        return ResponseEntity.ok(Map.of("message", "Đổi mật khẩu thành công."));
    }

    /** Chọn học sinh chính theo vai trò tài khoản. */
    private Student resolvePrimaryStudent(AppUser user, List<String> roles) {
        // STUDENT/PARENT có thể được gắn trực tiếp qua student_id
        if (user.getStudentId() != null) {
            Student s = studentDao.findById(user.getStudentId()).orElse(null);
            if (s != null) return s;
        }
        if (roles.contains("PARENT")) {
            List<Student> children = studentDao.findByParentId(user.getId());
            if (!children.isEmpty()) return children.get(0);
        }
        if (roles.contains("TEACHER")) {
            List<SchoolClass> classes = classDao.findByHomeroomTeacherId(user.getId());
            if (!classes.isEmpty()) {
                List<Student> roster = studentDao.findByClassId(classes.get(0).getId());
                if (!roster.isEmpty()) return roster.get(0);
            }
        }
        return null;
    }

    private void attachClassName(Student s) {
        if (s.getClassId() != null) {
            classDao.findById(s.getClassId()).ifPresent(c -> s.setClassName(c.getName()));
        }
    }
}
