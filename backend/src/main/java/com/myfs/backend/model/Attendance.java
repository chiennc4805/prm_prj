package com.myfs.backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter @Setter
@Entity @Table(name = "attendance")
public class Attendance {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Integer id;
    @Column(name = "student_id", nullable = false) private Integer studentId;
    @Column(name = "schedule_id", nullable = false) private Integer scheduleId;
    @Column(name = "attendance_date", nullable = false) private LocalDate attendanceDate;
    @Column(nullable = false, length = 10) private String status;
    @Column(length = 255) private String note;
    @Column(name = "recorded_by_id", nullable = false) private Integer recordedById;
    @Column(name = "created_at", updatable = false) private LocalDateTime createdAt;
    @Column(name = "updated_at") private LocalDateTime updatedAt;
    @PrePersist void create() { if (createdAt == null) createdAt = LocalDateTime.now(); }
    @PreUpdate void update() { updatedAt = LocalDateTime.now(); }
}
