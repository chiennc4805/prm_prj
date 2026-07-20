package com.myfs.backend.model;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Entity ánh xạ bảng attendance – điểm danh / chuyên cần.
 * status: PRESENT (có mặt), ABSENT (vắng không phép),
 *         LATE (đi muộn), EXCUSED (nghỉ có phép).
 */
@Entity
@Table(name = "attendance")
public class Attendance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "student_id", nullable = false)
    private Integer studentId;

    @Column(name = "student_code", nullable = false, length = 20)
    private String studentCode;

    @Column(name = "student_name", nullable = false, length = 100)
    private String studentName;

    @Column(name = "att_date", nullable = false)
    private LocalDate date;

    @Column(name = "status", nullable = false, length = 10)
    private String status;

    @Column(name = "note", length = 255)
    private String note;

    @Column(name = "recorded_by_id")
    private Integer recordedById;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    public Attendance() {}

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    public Integer   getId()           { return id; }
    public Integer   getStudentId()    { return studentId; }
    public String    getStudentCode()  { return studentCode; }
    public String    getStudentName()  { return studentName; }
    public LocalDate getDate()         { return date; }
    public String    getStatus()       { return status; }
    public String    getNote()         { return note; }
    public Integer   getRecordedById() { return recordedById; }
    public LocalDateTime getCreatedAt(){ return createdAt; }

    public void setId(Integer v)          { this.id = v; }
    public void setStudentId(Integer v)   { this.studentId = v; }
    public void setStudentCode(String v)  { this.studentCode = v; }
    public void setStudentName(String v)  { this.studentName = v; }
    public void setDate(LocalDate v)      { this.date = v; }
    public void setStatus(String v)       { this.status = v; }
    public void setNote(String v)         { this.note = v; }
    public void setRecordedById(Integer v){ this.recordedById = v; }
    public void setCreatedAt(LocalDateTime v) { this.createdAt = v; }
}
