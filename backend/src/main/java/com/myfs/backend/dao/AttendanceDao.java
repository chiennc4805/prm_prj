package com.myfs.backend.dao;

import com.myfs.backend.model.Attendance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

/** DAO cho bảng attendance (điểm danh / chuyên cần). */
@Repository
public interface AttendanceDao extends JpaRepository<Attendance, Integer> {

    /** Lịch sử điểm danh của một học sinh, mới nhất lên trước. */
    List<Attendance> findByStudentIdOrderByDateDesc(Integer studentId);

    /** Điểm danh của các học sinh trong một ngày (cho giáo viên). */
    List<Attendance> findByStudentIdInAndDate(List<Integer> studentIds, LocalDate date);

    /** Một bản ghi điểm danh cụ thể (1 học sinh - 1 ngày). */
    Attendance findByStudentIdAndDate(Integer studentId, LocalDate date);

    /** Đếm số buổi theo trạng thái của 1 học sinh (PRESENT/ABSENT/LATE/EXCUSED). */
    long countByStudentIdAndStatus(Integer studentId, String status);
}
