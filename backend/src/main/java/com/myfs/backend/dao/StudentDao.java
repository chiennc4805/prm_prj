package com.myfs.backend.dao;

import com.myfs.backend.model.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/** DAO cho bảng student (học sinh). */
@Repository
public interface StudentDao extends JpaRepository<Student, Integer> {

    /** Các con của một phụ huynh (1 phụ huynh có thể có nhiều con). */
    List<Student> findByParentId(Integer parentId);

    /** Danh sách học sinh của một lớp (sĩ số lớp cho giáo viên). */
    List<Student> findByClassId(Integer classId);

    /** Tìm học sinh theo mã. */
    Optional<Student> findByStudentCode(String studentCode);
}
