package com.myfs.backend.controller;

import com.myfs.backend.dao.*;
import com.myfs.backend.model.*;
import java.util.*;
import org.springframework.http.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

/** Small read-model adapter matching the existing Flutter JSON contracts. */
@RestController
public class MobileCompatibilityController {

  private final JdbcTemplate jdbc;
  private final StudentDao students;
  private final LeaveRequestDao leaves;

  public MobileCompatibilityController(
      JdbcTemplate jdbc,
      StudentDao students,
      LeaveRequestDao leaves) {
    this.jdbc = jdbc;
    this.students = students;
    this.leaves = leaves;
  }

  @GetMapping("/api/grades/student/{studentId}")
  public List<Map<String, Object>> grades(@PathVariable Integer studentId) {
    return jdbc.query(
        """
            SELECT g.id,s.id student_id,g.average_score,
                   s.student_code,s.full_name student_name,sub.name subject,sem.name semester,
                   sem.academic_year,u.full_name teacher_name
            FROM student s JOIN teacher_assignment a ON a.class_id=s.class_id
            JOIN semester sem ON sem.academic_year=a.academic_year
            LEFT JOIN grade g ON g.teacher_assignment_id=a.id AND g.student_id=s.id AND g.semester_id=sem.id
            JOIN subject sub ON sub.id=a.subject_id
            JOIN app_user u ON u.id=a.teacher_id WHERE s.id=?
            ORDER BY sem.academic_year,sem.id,sub.name
            """,
        (rs, n) -> {
          Map<String, Object> m = new LinkedHashMap<>();
          Integer gradeId = (Integer) rs.getObject("id");
          m.put("id", gradeId);
          m.put("studentId", rs.getInt("student_id"));
          m.put("studentCode", rs.getString("student_code"));
          m.put("studentName", rs.getString("student_name"));
          m.put("subject", rs.getString("subject"));
          m.put("averageScore", rs.getObject("average_score"));
          m.put(
              "gradeLetter",
              letter(rs.getObject("average_score", Double.class)));
          m.put("semester", rs.getString("semester"));
          m.put("academicYear", rs.getString("academic_year"));
          m.put("teacherName", rs.getString("teacher_name"));
          m.put(
              "items",
              gradeId == null
                  ? List.of()
                  : jdbc.queryForList(
                      "SELECT id,name,score,weight FROM grade_item WHERE grade_id=? ORDER BY id",
                      gradeId));
          return m;
        },
        studentId);
  }

  @GetMapping("/api/schedules/class/{classId}")
  public List<Map<String, Object>> schedules(@PathVariable Integer classId) {
    return jdbc.query(
        """
            SELECT sc.id,a.class_id,sc.day_order,sc.period,sub.name subject,sc.room,sc.start_time,sc.end_time,u.full_name teacher_name
            FROM schedule sc JOIN teacher_assignment a ON a.id=sc.teacher_assignment_id
            JOIN subject sub ON sub.id=a.subject_id JOIN app_user u ON u.id=a.teacher_id
            WHERE a.class_id=? ORDER BY sc.day_order,sc.period
            """,
        (rs, n) -> {
          Map<String, Object> m = new LinkedHashMap<>();
          m.put("id", rs.getInt("id"));
          m.put("classId", rs.getInt("class_id"));
          m.put("dayOrder", rs.getInt("day_order"));
          m.put("period", rs.getInt("period"));
          m.put("subject", rs.getString("subject"));
          m.put("room", rs.getString("room"));
          m.put("teacherName", rs.getString("teacher_name"));
          m.put("startTime", rs.getTime("start_time").toLocalTime().toString());
          m.put("endTime", rs.getTime("end_time").toLocalTime().toString());
          return m;
        },
        classId);
  }

  @GetMapping("/api/notifications/class/{classId}")
  public List<Map<String, Object>> notifications(
      @PathVariable Integer classId) {
    return jdbc.query(
        """
            SELECT n.id,n.title,n.content,n.sender_id,u.full_name sender_name,n.class_id,c.name class_name,n.created_at
            FROM notification n JOIN app_user u ON u.id=n.sender_id LEFT JOIN school_class c ON c.id=n.class_id
            WHERE n.class_id=? OR n.class_id IS NULL ORDER BY n.created_at DESC
            """,
        (rs, n) -> {
          Map<String, Object> m = new LinkedHashMap<>();
          m.put("id", rs.getInt("id"));
          m.put("title", rs.getString("title"));
          m.put("content", rs.getString("content"));
          m.put("senderId", rs.getInt("sender_id"));
          m.put("senderName", rs.getString("sender_name"));
          m.put("classId", rs.getObject("class_id"));
          m.put("className", rs.getString("class_name"));
          m.put("createdAt", rs.getTimestamp("created_at").toLocalDateTime());
          return m;
        },
        classId);
  }

  @GetMapping("/api/leaves/student/{studentId}")
  public List<Map<String, Object>> leaveHistory(
      @PathVariable Integer studentId) {
    student(studentId);
    return leaves
        .findByStudentIdOrderByCreatedAtDesc(studentId)
        .stream()
        .map(this::leaveView)
        .toList();
  }

  @PostMapping("/api/leaves")
  public Map<String, Object> createLeave(@RequestBody LeaveRequest input) {
    Student s = student(input.getStudentId());
    if (input.getCreatedById() == null ||
        !input.getCreatedById().equals(s.getParentId()))
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN,
          "Chỉ phụ huynh được tạo đơn cho con");
    if (input.getFromDate() == null ||
        input.getToDate() == null ||
        input.getFromDate().isAfter(input.getToDate()))
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "Khoảng ngày nghỉ không hợp lệ");
    LeaveRequest r = new LeaveRequest();
    r.setStudentId(s.getId());
    r.setCreatedById(input.getCreatedById());
    r.setFromDate(input.getFromDate());
    r.setToDate(input.getToDate());
    r.setReason(input.getReason());
    r.setStatus("SENT");
    return leaveView(leaves.save(r));
  }

  @GetMapping("/api/leaves/class/{classId}")
  public List<Map<String, Object>> leaveByClass(@PathVariable Integer classId) {
    return leaves.findForClass(classId).stream().map(this::leaveView).toList();
  }

  private Map<String, Object> leaveView(LeaveRequest r) {
    Student s = student(r.getStudentId());
    String className = s.getClassId() == null
        ? null
        : jdbc.queryForObject(
            "SELECT name FROM school_class WHERE id=?",
            String.class,
            s.getClassId());
    Map<String, Object> m = new LinkedHashMap<>();
    m.put("id", r.getId());
    m.put("studentId", s.getId());
    m.put("studentCode", s.getStudentCode());
    m.put("studentName", s.getFullName());
    m.put("className", className);
    m.put("leaveType", "ABSENT");
    m.put("fromDate", r.getFromDate());
    m.put("toDate", r.getToDate());
    m.put("reason", r.getReason());
    m.put("status", r.getStatus());
    m.put("createdById", r.getCreatedById());
    m.put("reviewedById", r.getReviewedById());
    return m;
  }

  private Student student(Integer id) {
    return students
        .findById(id)
        .orElseThrow(() -> new ResponseStatusException(
            HttpStatus.NOT_FOUND,
            "Không tìm thấy học sinh"));
  }

  private String letter(Double x) {
    if (x == null)
      return "";
    if (x >= 8.5)
      return "A";
    if (x >= 8)
      return "B+";
    if (x >= 7)
      return "B";
    if (x >= 6.5)
      return "C+";
    if (x >= 5.5)
      return "C";
    if (x >= 5)
      return "D+";
    if (x >= 4)
      return "D";
    return "F";
  }
}
