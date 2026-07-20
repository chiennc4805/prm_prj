package com.myfs.backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Getter @Setter
@Entity @Table(name = "student_evaluation")
public class StudentEvaluation {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Integer id;
    @Column(name = "student_id", nullable = false) private Integer studentId;
    @Column(name = "class_id", nullable = false) private Integer classId;
    @Column(name = "semester_id", nullable = false) private Integer semesterId;
    @Column(name = "homeroom_teacher_id", nullable = false) private Integer homeroomTeacherId;
    @Column(name = "conduct_rating", nullable = false, length = 20) private String conductRating;
    @Column(name = "academic_rating", length = 20) private String academicRating;
    @Column(length = 1000) private String comment;
    @Column(name = "evaluated_at", updatable = false) private LocalDateTime evaluatedAt;
    @Column(name = "updated_at") private LocalDateTime updatedAt;
    @PrePersist void create() { if (evaluatedAt == null) evaluatedAt = LocalDateTime.now(); }
    @PreUpdate void update() { updatedAt = LocalDateTime.now(); }
}
