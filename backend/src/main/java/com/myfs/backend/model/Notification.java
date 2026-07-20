package com.myfs.backend.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "notification")
public class Notification {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer id;

  @Column(nullable = false, length = 200)
  private String title;

  @Column(nullable = false, columnDefinition = "NVARCHAR(MAX)")
  private String content;

  @Column(name = "sender_id", nullable = false)
  private Integer senderId;

  @Column(name = "class_id")
  private Integer classId;

  @Column(name = "created_at", updatable = false)
  private LocalDateTime createdAt;

  @PrePersist
  void create() {
    if (createdAt == null) createdAt = LocalDateTime.now();
  }
}
