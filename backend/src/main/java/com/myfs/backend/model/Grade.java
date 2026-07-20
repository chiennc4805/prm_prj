package com.myfs.backend.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Entity ánh xạ bảng grade – điểm / sổ liên lạc (thang 0-100 chuẩn THPT).
 * studentId trỏ tới student; studentName/studentCode được lưu kèm (denormalize)
 * để client hiển thị nhanh mà không cần join.
 */
@Entity
@Table(name = "grade")
public class Grade {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "student_id", nullable = false)
    private Integer studentId;

    @Column(name = "student_code", nullable = false, length = 20)
    private String studentCode;

    @Column(name = "student_name", nullable = false, length = 100)
    private String studentName;

    @Column(name = "subject", nullable = false, length = 100)
    private String subject;

    @Column(name = "regular_scores", length = 50)
    private String regularScores;

    @Column(name = "midterm_score", precision = 5, scale = 2)
    private BigDecimal midtermScore;

    @Column(name = "final_score", precision = 5, scale = 2)
    private BigDecimal finalScore;

    @Column(name = "average_score", precision = 5, scale = 2)
    private BigDecimal averageScore;

    @Column(name = "grade_letter", length = 5)
    private String gradeLetter;

    @Column(name = "semester", nullable = false, length = 20)
    private String semester;

    @Column(name = "academic_year", nullable = false, length = 20)
    private String academicYear;

    @Column(name = "teacher_name", nullable = false, length = 100)
    private String teacherName;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    public Grade() {}

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    public Integer    getId()          { return id; }
    public Integer    getStudentId()   { return studentId; }
    public String     getStudentCode() { return studentCode; }
    public String     getStudentName() { return studentName; }
    public String     getSubject()     { return subject; }
    public String     getRegularScores() { return regularScores; }
    public BigDecimal getMidtermScore() { return midtermScore; }
    public BigDecimal getFinalScore()  { return finalScore; }
    public BigDecimal getAverageScore() { return averageScore; }
    public String     getGradeLetter() { return gradeLetter; }
    public String     getSemester()    { return semester; }
    public String     getAcademicYear(){ return academicYear; }
    public String     getTeacherName() { return teacherName; }
    public LocalDateTime getCreatedAt(){ return createdAt; }

    public void setId(Integer v)           { this.id = v; }
    public void setStudentId(Integer v)    { this.studentId = v; }
    public void setStudentCode(String v)   { this.studentCode = v; }
    public void setStudentName(String v)   { this.studentName = v; }
    public void setSubject(String v)       { this.subject = v; }
    public void setRegularScores(String v) { this.regularScores = v; }
    public void setMidtermScore(BigDecimal v) { this.midtermScore = v; }
    public void setFinalScore(BigDecimal v) { this.finalScore = v; }
    public void setAverageScore(BigDecimal v) { this.averageScore = v; }
    public void setGradeLetter(String v)   { this.gradeLetter = v; }
    public void setSemester(String v)      { this.semester = v; }
    public void setAcademicYear(String v)  { this.academicYear = v; }
    public void setTeacherName(String v)   { this.teacherName = v; }
    public void setCreatedAt(LocalDateTime v) { this.createdAt = v; }
}
