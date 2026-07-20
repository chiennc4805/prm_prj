package com.myfs.backend.dao;

import com.myfs.backend.model.Grade;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/** DAO cho bảng grade (điểm / sổ liên lạc). */
@Repository
public interface GradeDao extends JpaRepository<Grade, Integer> {

    /** Tất cả điểm của một học sinh (cho phụ huynh xem). */
    List<Grade> findByStudentId(Integer studentId);

    /** Điểm theo môn học và học kỳ. */
    List<Grade> findBySubjectAndSemester(String subject, String semester);

    /** Điểm trung bình của một học sinh (theo mã). */
    @Query("SELECT AVG(g.averageScore) FROM Grade g WHERE g.studentCode = :studentCode")
    Double findAverageGradeByStudentCode(@Param("studentCode") String studentCode);

    /** Tìm danh sách các lớp và môn học mà giáo viên đang phụ trách. */
    @Query(value = "SELECT DISTINCT c.id as classId, c.name as className, g.subject as subject, g.semester as semester, g.academic_year as academicYear " +
                   "FROM grade g " +
                   "JOIN student s ON g.student_id = s.id " +
                   "JOIN school_class c ON s.class_id = c.id " +
                   "WHERE g.teacher_name = :teacherName", nativeQuery = true)
    List<com.myfs.backend.model.TeacherAssignmentProjection> findAssignmentsByTeacherName(@Param("teacherName") String teacherName);

    /** Tìm danh sách phân công theo Học kỳ cụ thể. */
    @Query(value = "SELECT DISTINCT c.id as classId, c.name as className, g.subject as subject, g.semester as semester, g.academic_year as academicYear " +
                   "FROM grade g " +
                   "JOIN student s ON g.student_id = s.id " +
                   "JOIN school_class c ON s.class_id = c.id " +
                   "WHERE g.teacher_name = :teacherName " +
                   "AND g.semester = :semester", nativeQuery = true)
    List<com.myfs.backend.model.TeacherAssignmentProjection> findAssignmentsByTeacherNameAndSemester(
            @Param("teacherName") String teacherName, 
            @Param("semester") String semester);

    /** Tìm danh sách điểm của cả lớp cho 1 môn học của 1 giáo viên. */
    @Query(value = "SELECT g.* FROM grade g " +
                   "JOIN student s ON g.student_id = s.id " +
                   "WHERE g.teacher_name = :teacherName " +
                   "AND s.class_id = :classId " +
                   "AND g.subject = :subject " +
                   "AND g.semester = :semester", nativeQuery = true)
    List<Grade> findGradesByTeacherClassAndSubject(
            @Param("teacherName") String teacherName,
            @Param("classId") Integer classId,
            @Param("subject") String subject,
            @Param("semester") String semester);
}
