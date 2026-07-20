package com.myfs.backend.dao;
import com.myfs.backend.model.LeaveRequest;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;
import java.util.*;
public interface LeaveRequestDao extends JpaRepository<LeaveRequest,Integer> {
    List<LeaveRequest> findByStudentIdOrderByCreatedAtDesc(Integer studentId);
    @Query("select l from LeaveRequest l, Student s where l.studentId=s.id and s.classId=:classId order by l.createdAt desc")
    List<LeaveRequest> findForClass(@Param("classId") Integer classId);
}
