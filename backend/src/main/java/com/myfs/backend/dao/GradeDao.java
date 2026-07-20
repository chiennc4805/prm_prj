package com.myfs.backend.dao;

import com.myfs.backend.model.Grade;
import java.util.*;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GradeDao extends JpaRepository<Grade, Integer> {
  List<Grade> findByStudentId(Integer studentId);
  List<Grade> findByTeacherAssignmentId(Integer assignmentId);
  List<Grade> findByTeacherAssignmentIdAndSemesterId(
    Integer assignmentId,
    Integer semesterId
  );
  Optional<Grade> findByStudentIdAndTeacherAssignmentIdAndSemesterId(
    Integer studentId,
    Integer assignmentId,
    Integer semesterId
  );
}
