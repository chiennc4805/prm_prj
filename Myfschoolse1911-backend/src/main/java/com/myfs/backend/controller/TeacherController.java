package com.myfs.backend.controller;

import com.myfs.backend.dao.*;
import com.myfs.backend.model.*;
import com.myfs.backend.service.*;
import java.math.*;
import java.util.*;
import org.springframework.http.*;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/teacher")
public class TeacherController {

  private final SchoolAuthorizationService access;
  private final TeacherAssignmentDao assignments;
  private final ScheduleDao schedules;
  private final StudentDao students;
  private final GradeDao grades;
  private final NotificationDao notifications;
  private final GradeItemDao gradeItems;
  private final LeaveRequestDao leaves;
  private final StudentEvaluationDao evaluations;
  private final SchoolClassDao classes;

  public TeacherController(
      SchoolAuthorizationService access,
      TeacherAssignmentDao assignments,
      ScheduleDao schedules,
      StudentDao students,
      GradeDao grades,
      GradeItemDao gradeItems,
      NotificationDao notifications,
      LeaveRequestDao leaves,
      StudentEvaluationDao evaluations,
      SchoolClassDao classes) {
    this.access = access;
    this.assignments = assignments;
    this.schedules = schedules;
    this.students = students;
    this.grades = grades;
    this.gradeItems = gradeItems;
    this.notifications = notifications;
    this.leaves = leaves;
    this.evaluations = evaluations;
    this.classes = classes;
  }

  @GetMapping("/assignments")
  public List<TeacherAssignment> assignments(@RequestParam Integer teacherId) {
    return assignments.findByTeacherId(teacherId);
  }

  @GetMapping("/schedule")
  public List<Schedule> schedule(@RequestParam Integer teacherId) {
    return schedules.findForTeacher(teacherId);
  }

  @GetMapping("/assignments/{id}/students")
  public List<Student> roster(
      @RequestParam Integer teacherId,
      @PathVariable Integer id) {
    TeacherAssignment a = access.requireAssignment(id, teacherId);
    return students.findByClassId(a.getClassId());
  }

  @GetMapping("/assignments/{id}/grades")
  public List<Grade> grades(
      @RequestParam Integer teacherId,
      @RequestParam Integer semesterId,
      @PathVariable Integer id) {
    access.requireAssignment(id, teacherId);
    List<Grade> result = grades.findByTeacherAssignmentIdAndSemesterId(
        id,
        semesterId);
    result.forEach(g -> g.setItems(gradeItems.findByGradeId(g.getId())));
    return result;
  }

  @Transactional
  @PutMapping("/assignments/{id}/students/{studentId}/grade")
  public Grade saveGrade(
      @RequestParam Integer teacherId,
      @RequestParam Integer semesterId,
      @PathVariable Integer id,
      @PathVariable Integer studentId,
      @RequestBody Grade input) {
    TeacherAssignment a = access.requireAssignment(id, teacherId);
    access.requireStudentInClass(studentId, a.getClassId());
    Grade g = grades
        .findByStudentIdAndTeacherAssignmentIdAndSemesterId(
            studentId,
            id,
            semesterId)
        .orElseGet(Grade::new);
    g.setStudentId(studentId);
    g.setTeacherAssignmentId(id);
    g.setSemesterId(semesterId);
    validateItems(input.getItems());
    g.setAverageScore(average(input.getItems()));
    g = grades.save(g);
    gradeItems.deleteByGradeId(g.getId());
    List<GradeItem> saved = new ArrayList<>();
    for (GradeItem item : input.getItems()) {
      item.setId(null);
      item.setGradeId(g.getId());
      saved.add(gradeItems.save(item));
    }
    g.setItems(saved);
    return g;
  }

  @PostMapping("/classes/{classId}/notifications")
  public Notification notify(
      @RequestParam Integer teacherId,
      @PathVariable Integer classId,
      @RequestBody Notification n) {
    boolean allowed = assignments.existsByTeacherIdAndClassId(teacherId, classId) ||
        classes
            .findById(classId)
            .map(c -> teacherId.equals(c.getHomeroomTeacherId()))
            .orElse(false);
    if (!allowed)
      throw new ResponseStatusException(
          HttpStatus.FORBIDDEN,
          "Không phụ trách lớp này");
    n.setId(null);
    n.setSenderId(teacherId);
    n.setClassId(classId);
    return notifications.save(n);
  }

  @GetMapping("/homeroom/{classId}/leaves")
  public List<LeaveRequest> leaves(
      @RequestParam Integer teacherId,
      @PathVariable Integer classId) {
    access.requireHomeroom(classId, teacherId);
    return leaves.findForClass(classId);
  }

  @GetMapping("/homeroom/{classId}/grades")
  public List<Grade> classGrades(
      @RequestParam Integer teacherId,
      @PathVariable Integer classId) {
    access.requireHomeroom(classId, teacherId);
    Set<Integer> ids = new HashSet<>();
    students.findByClassId(classId).forEach(s -> ids.add(s.getId()));
    List<Grade> result = grades
        .findAll()
        .stream()
        .filter(g -> ids.contains(g.getStudentId()))
        .toList();
    result.forEach(g -> g.setItems(gradeItems.findByGradeId(g.getId())));
    return result;
  }

  @GetMapping("/homeroom/{classId}/evaluations")
  public List<StudentEvaluation> evaluations(
      @RequestParam Integer teacherId,
      @PathVariable Integer classId,
      @RequestParam Integer semesterId) {
    access.requireHomeroom(classId, teacherId);
    return evaluations.findByClassIdAndSemesterId(classId, semesterId);
  }

  @PutMapping("/homeroom/{classId}/students/{studentId}/evaluation")
  public StudentEvaluation evaluate(
      @RequestParam Integer teacherId,
      @PathVariable Integer classId,
      @PathVariable Integer studentId,
      @RequestParam Integer semesterId,
      @RequestBody StudentEvaluation input) {
    access.requireHomeroom(classId, teacherId);
    access.requireStudentInClass(studentId, classId);
    StudentEvaluation e = evaluations
        .findByStudentIdAndSemesterId(studentId, semesterId)
        .orElseGet(StudentEvaluation::new);
    e.setStudentId(studentId);
    e.setClassId(classId);
    e.setSemesterId(semesterId);
    e.setHomeroomTeacherId(teacherId);
    e.setConductRating(input.getConductRating());
    e.setAcademicRating(input.getAcademicRating());
    e.setComment(input.getComment());
    return evaluations.save(e);
  }

  private void validateItems(List<GradeItem> items) {
    if (items == null || items.isEmpty())
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "Cần ít nhất một đầu điểm");
    for (GradeItem i : items)
      if (i.getName() == null ||
          i.getName().isBlank() ||
          i.getScore() == null ||
          i.getScore().compareTo(BigDecimal.ZERO) < 0 ||
          i.getScore().compareTo(BigDecimal.TEN) > 0 ||
          i.getWeight() == null ||
          i.getWeight().compareTo(BigDecimal.ZERO) <= 0)
        throw new ResponseStatusException(
            HttpStatus.BAD_REQUEST,
            "Đầu điểm, giá trị và hệ số không hợp lệ");
  }

  private BigDecimal average(List<GradeItem> items) {
    BigDecimal sum = BigDecimal.ZERO,
        weights = BigDecimal.ZERO;
    for (GradeItem i : items) {
      sum = sum.add(i.getScore().multiply(i.getWeight()));
      weights = weights.add(i.getWeight());
    }
    return sum.divide(weights, 2, RoundingMode.HALF_UP);
  }
}
