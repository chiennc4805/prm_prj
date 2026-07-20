package com.myfs.backend.dao;

import com.myfs.backend.model.LeaveRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/** DAO cho bảng leave_request (đơn xin nghỉ học). */
@Repository
public interface LeaveRequestDao extends JpaRepository<LeaveRequest, Integer> {

    /** Đơn của một học sinh (phụ huynh xem lịch sử đơn của con). */
    List<LeaveRequest> findByStudentIdOrderByCreatedAtDesc(Integer studentId);

    /** Đơn của một lớp (giáo viên duyệt) – lọc theo tên lớp. */
    List<LeaveRequest> findByClassNameOrderByCreatedAtDesc(String className);

    /** Đơn của nhiều học sinh (theo danh sách lớp). */
    List<LeaveRequest> findByStudentIdInOrderByCreatedAtDesc(List<Integer> studentIds);
}
