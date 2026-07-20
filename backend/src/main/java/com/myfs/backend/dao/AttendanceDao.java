package com.myfs.backend.dao;
import com.myfs.backend.model.Attendance;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.*;
public interface AttendanceDao extends JpaRepository<Attendance,Integer> {
    List<Attendance> findByStudentIdOrderByAttendanceDateDesc(Integer studentId);
    List<Attendance> findByScheduleIdAndAttendanceDate(Integer scheduleId, LocalDate date);
    Optional<Attendance> findByStudentIdAndScheduleIdAndAttendanceDate(Integer studentId, Integer scheduleId, LocalDate date);
    long countByStudentIdAndStatus(Integer studentId, String status);
}
