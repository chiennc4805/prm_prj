package com.myfs.backend.model;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "leave_request")
public class LeaveRequest {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer id;

  @Column(name = "student_id", nullable = false)
  private Integer studentId;

  @Column(name = "created_by_id", nullable = false)
  private Integer createdById;

  @Column(name = "from_date", nullable = false)
  private LocalDate fromDate;

  @Column(name = "to_date", nullable = false)
  private LocalDate toDate;

  @Column(nullable = false, length = 500)
  private String reason;

  @Column(nullable = false, length = 10)
  private String status = "PENDING";

  @Column(name = "reviewed_by_id")
  private Integer reviewedById;

  @Column(name = "reviewed_at")
  private LocalDateTime reviewedAt;

  @Column(name = "rejection_reason", length = 500)
  private String rejectionReason;

  @Column(name = "created_at", updatable = false)
  private LocalDateTime createdAt;

  @PrePersist
  void create() {
    if (createdAt == null) createdAt = LocalDateTime.now();
  }
}
