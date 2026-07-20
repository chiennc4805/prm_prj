package com.myfs.backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter @Setter
@Entity @Table(name = "grade")
public class Grade {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Integer id;
    @Column(name = "student_id", nullable = false) private Integer studentId;
    @Column(name = "teacher_assignment_id", nullable = false) private Integer teacherAssignmentId;
    @Column(name = "regular_scores", length = 100) private String regularScores;
    @Column(name = "midterm_score", precision = 4, scale = 2) private BigDecimal midtermScore;
    @Column(name = "final_score", precision = 4, scale = 2) private BigDecimal finalScore;
    @Column(name = "average_score", precision = 4, scale = 2) private BigDecimal averageScore;
    @Column(name = "created_at", updatable = false) private LocalDateTime createdAt;
    @Column(name = "updated_at") private LocalDateTime updatedAt;
    @PrePersist void create() { if (createdAt == null) createdAt = LocalDateTime.now(); }
    @PreUpdate void update() { updatedAt = LocalDateTime.now(); }
}
