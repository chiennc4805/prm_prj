package com.myfs.backend.controller;

import com.myfs.backend.dao.*;
import com.myfs.backend.model.*;
import java.time.LocalDate;
import java.util.*;
import org.springframework.http.*;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

  private final AppUserDao users;
  private final StudentDao students;
  private final SchoolClassDao classes;
  private final SubjectDao subjects;
  private final SemesterDao semesters;
  private final TeacherAssignmentDao assignments;
  private final ScheduleDao schedules;

  public AdminController(
    AppUserDao users,
    StudentDao students,
    SchoolClassDao classes,
    SubjectDao subjects,
    SemesterDao semesters,
    TeacherAssignmentDao assignments,
    ScheduleDao schedules
  ) {
    this.users = users;
    this.students = students;
    this.classes = classes;
    this.subjects = subjects;
    this.semesters = semesters;
    this.assignments = assignments;
    this.schedules = schedules;
  }

  @GetMapping("/users")
  public List<AppUser> users(@RequestParam(required = false) String role) {
    return role == null
      ? users.findAll()
      : users.findByRole(role.toUpperCase());
  }

  @PostMapping("/users")
  public AppUser createUser(@RequestBody AppUser u) {
    u.setId(null);
    validateRole(u.getRole());
    if (u.getPassword() == null || u.getPassword().isBlank()) u.setPassword(
      "123456"
    );
    if (u.getActive() == null) u.setActive(true);
    return users.save(u);
  }

  @PutMapping("/users/{id}")
  public AppUser updateUser(
    @PathVariable Integer id,
    @RequestBody AppUser input
  ) {
    AppUser u = users.findById(id).orElseThrow(() -> missing("Tài khoản"));
    validateRole(input.getRole());
    u.setPhone(input.getPhone());
    u.setFullName(input.getFullName());
    u.setRole(input.getRole());
    u.setEmail(input.getEmail());
    u.setAvatarUrl(input.getAvatarUrl());
    u.setActive(input.getActive());
    if (
      input.getPassword() != null && !input.getPassword().isBlank()
    ) u.setPassword(input.getPassword());
    return users.save(u);
  }

  @DeleteMapping("/users/{id}")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void deleteUser(@PathVariable Integer id) {
    AppUser u = users.findById(id).orElseThrow(() -> missing("Tài khoản"));
    u.setActive(false);
    users.save(u);
  }

  @GetMapping("/students")
  public List<Student> students() {
    return students.findAll();
  }

  public record StudentRequest(
    String studentCode,
    String fullName,
    LocalDate dateOfBirth,
    String gender,
    Integer classId,
    Integer parentId,
    String phone
  ) {}

  @PostMapping("/students")
  @Transactional
  public Student createStudent(@RequestBody StudentRequest input) {
    validateStudentLinks(input.classId(), input.parentId());
    if (
      input.phone() == null || input.phone().isBlank()
    ) throw new ResponseStatusException(
      HttpStatus.BAD_REQUEST,
      "Cần số điện thoại của học sinh"
    );
    if (
      users.findByPhone(input.phone()).isPresent()
    ) throw new ResponseStatusException(
      HttpStatus.BAD_REQUEST,
      "Số điện thoại đã được sử dụng"
    );
    AppUser account = new AppUser();
    account.setPhone(input.phone());
    account.setPassword("123456");
    account.setFullName(input.fullName());
    account.setRole("STUDENT");
    account.setActive(true);
    account = users.save(account);
    Student s = new Student();
    applyStudent(s, input);
    s.setStudentAccountId(account.getId());
    return students.save(s);
  }

  @PutMapping("/students/{id}")
  @Transactional
  public Student updateStudent(
    @PathVariable Integer id,
    @RequestBody StudentRequest input
  ) {
    Student s = students.findById(id).orElseThrow(() -> missing("Học sinh"));
    validateStudentLinks(input.classId(), input.parentId());
    AppUser account =
      s.getStudentAccountId() == null
        ? null
        : users.findById(s.getStudentAccountId()).orElse(null);
    if (account == null) {
      if (
        input.phone() == null || input.phone().isBlank()
      ) throw new ResponseStatusException(
        HttpStatus.BAD_REQUEST,
        "Cần số điện thoại của học sinh"
      );
      account = new AppUser();
      account.setRole("STUDENT");
      account.setActive(true);
      account.setPassword("123456");
    }
    if (input.phone() != null && !input.phone().isBlank()) account.setPhone(
      input.phone()
    );
    account.setFullName(input.fullName());
    account = users.save(account);
    applyStudent(s, input);
    s.setStudentAccountId(account.getId());
    return students.save(s);
  }

  @DeleteMapping("/students/{id}")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  @Transactional
  public void deleteStudent(@PathVariable Integer id) {
    Student s = students.findById(id).orElseThrow(() -> missing("Học sinh"));
    Integer accountId = s.getStudentAccountId();
    students.delete(s);
    if (accountId != null) users.findById(accountId).ifPresent(u -> {
      u.setActive(false);
      users.save(u);
    });
  }

  @GetMapping("/classes")
  public List<SchoolClass> classes() {
    return classes.findAll();
  }

  @PostMapping("/classes")
  public SchoolClass createClass(@RequestBody SchoolClass c) {
    c.setId(null);
    validateHomeroom(c);
    return classes.save(c);
  }

  @PutMapping("/classes/{id}")
  public SchoolClass updateClass(
    @PathVariable Integer id,
    @RequestBody SchoolClass c
  ) {
    if (!classes.existsById(id)) throw missing("Lớp");
    c.setId(id);
    validateHomeroom(c);
    return classes.save(c);
  }

  @DeleteMapping("/classes/{id}")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void deleteClass(@PathVariable Integer id) {
    classes.deleteById(id);
  }

  @GetMapping("/subjects")
  public List<Subject> subjects() {
    return subjects.findAll();
  }

  @PostMapping("/subjects")
  public Subject createSubject(@RequestBody Subject s) {
    s.setId(null);
    return subjects.save(s);
  }

  @PutMapping("/subjects/{id}")
  public Subject updateSubject(
    @PathVariable Integer id,
    @RequestBody Subject s
  ) {
    if (!subjects.existsById(id)) throw missing("Môn học");
    s.setId(id);
    return subjects.save(s);
  }

  @DeleteMapping("/subjects/{id}")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void deleteSubject(@PathVariable Integer id) {
    subjects.deleteById(id);
  }

  @GetMapping("/semesters")
  public List<Semester> semesters() {
    return semesters.findAll();
  }

  @PostMapping("/semesters")
  public Semester createSemester(@RequestBody Semester s) {
    s.setId(null);
    return semesters.save(s);
  }

  @GetMapping("/assignments")
  public List<TeacherAssignment> assignments() {
    return assignments.findAll();
  }

  @PostMapping("/assignments")
  public TeacherAssignment assign(@RequestBody TeacherAssignment a) {
    a.setId(null);
    validateAssignment(a);
    return assignments.save(a);
  }

  @PutMapping("/assignments/{id}")
  public TeacherAssignment updateAssignment(
    @PathVariable Integer id,
    @RequestBody TeacherAssignment a
  ) {
    if (!assignments.existsById(id)) throw missing("Phân công");
    validateAssignment(a);
    a.setId(id);
    return assignments.save(a);
  }

  @DeleteMapping("/assignments/{id}")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void unassign(@PathVariable Integer id) {
    assignments.deleteById(id);
  }

  @GetMapping("/schedules")
  public List<Schedule> schedules() {
    return schedules.findAll();
  }

  @PostMapping("/schedules")
  public Schedule schedule(@RequestBody Schedule s) {
    s.setId(null);
    if (!assignments.existsById(s.getTeacherAssignmentId())) throw missing(
      "Phân công"
    );
    return schedules.save(s);
  }

  @PutMapping("/schedules/{id}")
  public Schedule updateSchedule(
    @PathVariable Integer id,
    @RequestBody Schedule s
  ) {
    if (!schedules.existsById(id)) throw missing("Lịch học");
    s.setId(id);
    return schedules.save(s);
  }

  @DeleteMapping("/schedules/{id}")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void deleteSchedule(@PathVariable Integer id) {
    schedules.deleteById(id);
  }

  private void applyStudent(Student s, StudentRequest input) {
    s.setStudentCode(input.studentCode());
    s.setFullName(input.fullName());
    s.setDateOfBirth(input.dateOfBirth());
    s.setGender(input.gender());
    s.setClassId(input.classId());
    s.setParentId(input.parentId());
  }

  private void validateStudentLinks(Integer classId, Integer parentId) {
    if (parentId != null) requireRole(parentId, "PARENT");
    if (classId != null && !classes.existsById(classId)) throw missing("Lớp");
  }

  private void validateAssignment(TeacherAssignment a) {
    requireRole(a.getTeacherId(), "TEACHER");
    SchoolClass c = classes
      .findById(a.getClassId())
      .orElseThrow(() -> missing("Lớp"));
    if (!subjects.existsById(a.getSubjectId())) throw missing("Môn học");
    if (
      a.getAcademicYear() == null ||
      !a.getAcademicYear().equals(c.getAcademicYear())
    ) throw new ResponseStatusException(
      HttpStatus.BAD_REQUEST,
      "Năm học phân công phải trùng với năm học của lớp"
    );
  }

  private void validateHomeroom(SchoolClass c) {
    if (c.getHomeroomTeacherId() != null) requireRole(
      c.getHomeroomTeacherId(),
      "TEACHER"
    );
  }

  private AppUser requireRole(Integer id, String role) {
    AppUser u = users.findById(id).orElseThrow(() -> missing("Tài khoản"));
    if (!role.equals(u.getRole())) throw new ResponseStatusException(
      HttpStatus.BAD_REQUEST,
      "Tài khoản phải có role " + role
    );
    return u;
  }

  private void validateRole(String role) {
    if (
      !Set.of("ADMIN", "TEACHER", "PARENT", "STUDENT").contains(role)
    ) throw new ResponseStatusException(
      HttpStatus.BAD_REQUEST,
      "Role không hợp lệ"
    );
  }

  private ResponseStatusException missing(String n) {
    return new ResponseStatusException(
      HttpStatus.NOT_FOUND,
      "Không tìm thấy " + n
    );
  }
}
