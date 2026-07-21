package com.myfs.backend.service;

import com.myfs.backend.dao.*;
import com.myfs.backend.model.*;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class SchoolAuthorizationService {

  private final SchoolClassDao classes;
  private final TeacherAssignmentDao assignments;
  private final StudentDao students;

  public SchoolAuthorizationService(
    SchoolClassDao classes,
    TeacherAssignmentDao assignments,
    StudentDao students
  ) {
    this.classes = classes;
    this.assignments = assignments;
    this.students = students;
  }

  public TeacherAssignment requireAssignment(Integer id, Integer teacherId) {
    TeacherAssignment a = assignments
      .findById(id)
      .orElseThrow(() -> notFound("Không tìm thấy phân công"));
    if (!a.getTeacherId().equals(teacherId)) throw forbidden();
    return a;
  }

  public SchoolClass requireHomeroom(Integer classId, Integer teacherId) {
    SchoolClass c = classes
      .findById(classId)
      .orElseThrow(() -> notFound("Không tìm thấy lớp"));
    if (!teacherId.equals(c.getHomeroomTeacherId())) throw forbidden();
    return c;
  }

  public Student requireChild(Integer studentId, Integer parentId) {
    Student s = students
      .findById(studentId)
      .orElseThrow(() -> notFound("Không tìm thấy học sinh"));
    if (!parentId.equals(s.getParentId())) throw forbidden();
    return s;
  }

  public Student requireStudentInClass(Integer studentId, Integer classId) {
    Student s = students
      .findById(studentId)
      .orElseThrow(() -> notFound("Không tìm thấy học sinh"));
    if (!classId.equals(s.getClassId())) throw new ResponseStatusException(
      HttpStatus.BAD_REQUEST,
      "Học sinh không thuộc lớp được phân công"
    );
    return s;
  }

  private ResponseStatusException forbidden() {
    return new ResponseStatusException(
      HttpStatus.FORBIDDEN,
      "Không có quyền trên lớp hoặc môn này"
    );
  }

  private ResponseStatusException notFound(String m) {
    return new ResponseStatusException(HttpStatus.NOT_FOUND, m);
  }
}
