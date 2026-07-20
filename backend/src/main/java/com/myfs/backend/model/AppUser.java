package com.myfs.backend.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDateTime;

@Getter @Setter
@Entity @Table(name = "app_user")
public class AppUser {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Integer id;
    @Column(nullable = false, unique = true, length = 15) private String phone;
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    @Column(nullable = false, length = 100) private String password;
    @Column(name = "full_name", nullable = false, length = 100) private String fullName;
    @Column(nullable = false, length = 10) private String role;
    @Column(unique = true, length = 100) private String email;
    @Column(name = "avatar_url") private String avatarUrl;
    @Column(name = "is_active", nullable = false) private Boolean active = true;
    @Column(name = "created_at", updatable = false) private LocalDateTime createdAt;
    @Column(name = "updated_at") private LocalDateTime updatedAt;
    @PrePersist void create() { if (createdAt == null) createdAt = LocalDateTime.now(); }
    @PreUpdate void update() { updatedAt = LocalDateTime.now(); }
}
