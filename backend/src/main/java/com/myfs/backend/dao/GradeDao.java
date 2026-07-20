package com.myfs.backend.dao;
import com.myfs.backend.model.Grade;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.*;
public interface GradeDao extends JpaRepository<Grade,Integer> {
    List<Grade> findByStudentId(Integer studentId);
    List<Grade> findByTeacherAssignmentId(Integer assignmentId);
    Optional<Grade> findByStudentIdAndTeacherAssignmentId(Integer studentId, Integer assignmentId);
}
