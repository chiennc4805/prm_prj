package com.myfs.backend.controller;

import com.myfs.backend.dao.*;
import com.myfs.backend.model.*;
import java.util.*;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/portal")
public class PortalController {

  private final StudentDao students;
  private final ScheduleDao schedules;
  private final GradeDao grades;
  private final NotificationDao notifications;
  private final LeaveRequestDao leaves;

  public PortalController(
    StudentDao students,
    ScheduleDao schedules,
    GradeDao grades,
    NotificationDao notifications,
    LeaveRequestDao leaves
  ) {
    this.students = students;
    this.schedules = schedules;
    this.grades = grades;
    this.notifications = notifications;
    this.leaves = leaves;
  }

  private Student student(Integer id) {
    return students
      .findById(id)
      .orElseThrow(() ->
        new ResponseStatusException(
          HttpStatus.NOT_FOUND,
          "Không tìm thấy học sinh"
        )
      );
  }

  @GetMapping("/students/{id}/schedule")
  public List<Schedule> schedule(@PathVariable Integer id) {
    return schedules.findForClass(student(id).getClassId());
  }

  @GetMapping("/students/{id}/grades")
  public List<Grade> grades(@PathVariable Integer id) {
    student(id);
    return grades.findByStudentId(id);
  }

  @GetMapping("/students/{id}/notifications")
  public List<Notification> notifications(@PathVariable Integer id) {
    return notifications.findForClass(student(id).getClassId());
  }

  @GetMapping("/students/{id}/leaves")
  public List<LeaveRequest> leaves(@PathVariable Integer id) {
    student(id);
    return leaves.findByStudentIdOrderByCreatedAtDesc(id);
  }

  @PostMapping("/students/{id}/leaves")
  public LeaveRequest createLeave(
    @PathVariable Integer id,
    @RequestBody LeaveRequest input
  ) {
    Student s = student(id);
    if (
      input.getCreatedById() == null ||
      !input.getCreatedById().equals(s.getParentId())
    ) throw new ResponseStatusException(
      HttpStatus.FORBIDDEN,
      "Chỉ phụ huynh của học sinh được tạo đơn"
    );
    if (
      input.getFromDate() == null ||
      input.getToDate() == null ||
      input.getFromDate().isAfter(input.getToDate())
    ) throw new ResponseStatusException(
      HttpStatus.BAD_REQUEST,
      "Khoảng ngày nghỉ không hợp lệ"
    );
    LeaveRequest r = new LeaveRequest();
    r.setStudentId(id);
    r.setCreatedById(input.getCreatedById());
    r.setFromDate(input.getFromDate());
    r.setToDate(input.getToDate());
    r.setReason(input.getReason());
    r.setStatus("SENT");
    return leaves.save(r);
  }
}
