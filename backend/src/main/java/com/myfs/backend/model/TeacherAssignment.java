package com.myfs.backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Getter @Setter
@Entity @Table(name = "teacher_assignment")
public class TeacherAssignment {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Integer id;
    @Column(name = "teacher_id", nullable = false) private Integer teacherId;
    @Column(name = "class_id", nullable = false) private Integer classId;
    @Column(name = "subject_id", nullable = false) private Integer subjectId;
    @Column(name = "semester_id", nullable = false) private Integer semesterId;
    @Column(name = "created_at", updatable = false) private LocalDateTime createdAt;
    @PrePersist void create() { if (createdAt == null) createdAt = LocalDateTime.now(); }
}
