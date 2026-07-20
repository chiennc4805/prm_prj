package com.myfs.backend.model;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Entity ánh xạ bảng leave_request – đơn xin nghỉ học.
 * Phụ huynh tạo đơn (createdById), Giáo viên duyệt (reviewedById).
 * status: PENDING (chờ duyệt), APPROVED (đã duyệt), REJECTED (từ chối).
 */
@Entity
@Table(name = "leave_request")
public class LeaveRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "student_id", nullable = false)
    private Integer studentId;

    @Column(name = "student_code", nullable = false, length = 20)
    private String studentCode;

    @Column(name = "student_name", nullable = false, length = 100)
    private String studentName;

    @Column(name = "class_name", length = 50)
    private String className;

    @Column(name = "leave_type", nullable = false, length = 20)
    private String leaveType = "ABSENT";

    @Column(name = "title", length = 200)
    private String title;

    @Column(name = "from_date", nullable = false)
    private LocalDate fromDate;

    @Column(name = "to_date", nullable = false)
    private LocalDate toDate;

    @Column(name = "time_value", length = 10)
    private String timeValue;

    @Column(name = "reason", nullable = false, length = 500)
    private String reason;

    @Column(name = "status", nullable = false, length = 20)
    private String status;

    @Column(name = "created_by_id")
    private Integer createdById;

    @Column(name = "reviewed_by_id")
    private Integer reviewedById;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    public LeaveRequest() {}

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
        if (status == null)    status = "PENDING";
    }

    public Integer   getId()           { return id; }
    public Integer   getStudentId()    { return studentId; }
    public String    getStudentCode()  { return studentCode; }
    public String    getStudentName()  { return studentName; }
    public String    getClassName()    { return className; }
    public String    getLeaveType()    { return leaveType; }
    public String    getTitle()        { return title; }
    public LocalDate getFromDate()     { return fromDate; }
    public LocalDate getToDate()       { return toDate; }
    public String    getTimeValue()    { return timeValue; }
    public String    getReason()       { return reason; }
    public String    getStatus()       { return status; }
    public Integer   getCreatedById()  { return createdById; }
    public Integer   getReviewedById() { return reviewedById; }
    public LocalDateTime getCreatedAt(){ return createdAt; }

    public void setId(Integer v)          { this.id = v; }
    public void setStudentId(Integer v)   { this.studentId = v; }
    public void setStudentCode(String v)  { this.studentCode = v; }
    public void setStudentName(String v)  { this.studentName = v; }
    public void setClassName(String v)    { this.className = v; }
    public void setLeaveType(String v)    { this.leaveType = v; }
    public void setTitle(String v)        { this.title = v; }
    public void setFromDate(LocalDate v)  { this.fromDate = v; }
    public void setToDate(LocalDate v)    { this.toDate = v; }
    public void setTimeValue(String v)    { this.timeValue = v; }
    public void setReason(String v)       { this.reason = v; }
    public void setStatus(String v)       { this.status = v; }
    public void setCreatedById(Integer v) { this.createdById = v; }
    public void setReviewedById(Integer v){ this.reviewedById = v; }
    public void setCreatedAt(LocalDateTime v) { this.createdAt = v; }
}
