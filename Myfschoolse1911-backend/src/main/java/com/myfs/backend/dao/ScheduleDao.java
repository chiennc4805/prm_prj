package com.myfs.backend.dao;

import com.myfs.backend.model.Schedule;
import java.util.*;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;

public interface ScheduleDao extends JpaRepository<Schedule, Integer> {
  @Query(
    "select s from Schedule s, TeacherAssignment a where s.teacherAssignmentId=a.id and a.classId=:classId order by s.dayOrder,s.period"
  )
  List<Schedule> findForClass(@Param("classId") Integer classId);

  @Query(
    "select s from Schedule s, TeacherAssignment a where s.teacherAssignmentId=a.id and a.teacherId=:teacherId order by s.dayOrder,s.period"
  )
  List<Schedule> findForTeacher(@Param("teacherId") Integer teacherId);
}
