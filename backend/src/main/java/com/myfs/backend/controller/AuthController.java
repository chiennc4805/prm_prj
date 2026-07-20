package com.myfs.backend.controller;

import com.myfs.backend.dao.*;
import com.myfs.backend.model.*;
import com.myfs.backend.service.AuthSessionService;
import java.util.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

  private final AuthSessionService auth;
  private final StudentDao students;
  private final SchoolClassDao classes;

  public AuthController(
    AuthSessionService auth,
    StudentDao students,
    SchoolClassDao classes
  ) {
    this.auth = auth;
    this.students = students;
    this.classes = classes;
  }

  public record LoginRequest(String phone, String password) {}

  @PostMapping("/login")
  public Map<String, Object> login(@RequestBody LoginRequest body) {
    AppUser user = auth.login(body.phone(), body.password());
    Map<String, Object> result = new LinkedHashMap<>();
    result.put("user", user);
    result.put("role", user.getRole());
    result.put("roles", List.of(user.getRole()));
    if ("PARENT".equals(user.getRole())) {
      List<Student> children = students.findByParentId(user.getId());
      children.forEach(this::attachClassName);
      result.put("children", children);
      if (!children.isEmpty()) result.put("student", children.get(0));
    }
    if ("STUDENT".equals(user.getRole())) students
      .findByStudentAccountId(user.getId())
      .ifPresent(s -> {
        attachClassName(s);
        result.put("student", s);
      });
    if ("TEACHER".equals(user.getRole())) result.put(
      "classes",
      classes.findByHomeroomTeacherId(user.getId())
    );
    return result;
  }

  @PostMapping("/forgot-password")
  public Map<String, String> forgot(@RequestBody Map<String, String> body) {
    auth.findByPhone(body.get("phone"));
    return Map.of("message", "Mã OTP demo: 123456");
  }

  @PostMapping("/update-password")
  public Map<String, String> updatePassword(
    @RequestBody Map<String, String> body
  ) {
    auth.updatePassword(body.get("phone"), body.get("newPassword"));
    return Map.of("message", "Đổi mật khẩu thành công");
  }

  private void attachClassName(Student student) {
    if (student.getClassId() != null) classes
      .findById(student.getClassId())
      .ifPresent(c -> student.setClassName(c.getName()));
  }
}
