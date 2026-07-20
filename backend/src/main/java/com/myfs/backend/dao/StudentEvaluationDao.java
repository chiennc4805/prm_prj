package com.myfs.backend.dao;
import com.myfs.backend.model.StudentEvaluation;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.*;
public interface StudentEvaluationDao extends JpaRepository<StudentEvaluation,Integer> {
    List<StudentEvaluation> findByClassIdAndSemesterId(Integer classId,Integer semesterId);
    Optional<StudentEvaluation> findByStudentIdAndSemesterId(Integer studentId,Integer semesterId);
}
