package com.myfs.backend.dao;

import com.myfs.backend.model.TeacherAssignment;
import java.util.*;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TeacherAssignmentDao
  extends JpaRepository<TeacherAssignment, Integer>
{
  List<TeacherAssignment> findByTeacherId(Integer teacherId);
  List<TeacherAssignment> findByClassId(Integer classId);
  boolean existsByTeacherIdAndClassId(Integer teacherId, Integer classId);
}
