package com.myfs.backend.dao;

import com.myfs.backend.model.StudentEvaluation;
import java.util.*;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StudentEvaluationDao
  extends JpaRepository<StudentEvaluation, Integer>
{
  List<StudentEvaluation> findByClassIdAndSemesterId(
    Integer classId,
    Integer semesterId
  );
  Optional<StudentEvaluation> findByStudentIdAndSemesterId(
    Integer studentId,
    Integer semesterId
  );
}
