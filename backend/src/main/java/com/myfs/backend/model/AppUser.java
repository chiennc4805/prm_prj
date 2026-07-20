package com.myfs.backend.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Entity ánh xạ bảng app_user – tài khoản đăng nhập.
 * role: "TEACHER" (giáo viên) hoặc "PARENT" (phụ huynh).
 */
@Entity
@Table(name = "app_user")
public class AppUser {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "phone", nullable = false, length = 15, unique = true)
    private String phone;

    // Chỉ nhận khi ghi (login/đăng ký), KHÔNG trả ra JSON cho client.
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    @Column(name = "password", nullable = false, length = 100)
    private String password;

    @Column(name = "full_name", nullable = false, length = 100)
    private String fullName;

    @Column(name = "role", nullable = false, length = 10)
    private String role;

    @Column(name = "email", length = 100)
    private String email;

    @Column(name = "avatar_url", length = 255)
    private String avatarUrl;

    @Column(name = "student_id")
    private Integer studentId;   // gắn tài khoản với 1 học sinh (STUDENT/PARENT)

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    public AppUser() {}

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    public Integer getId()              { return id; }
    public String  getPhone()           { return phone; }
    public String  getPassword()        { return password; }
    public String  getFullName()        { return fullName; }
    public String  getRole()            { return role; }
    public String  getEmail()           { return email; }
    public String  getAvatarUrl()       { return avatarUrl; }
    public Integer getStudentId()       { return studentId; }
    public LocalDateTime getCreatedAt() { return createdAt; }

    public void setId(Integer v)        { this.id = v; }
    public void setPhone(String v)      { this.phone = v; }
    public void setPassword(String v)   { this.password = v; }
    public void setFullName(String v)   { this.fullName = v; }
    public void setRole(String v)       { this.role = v; }
    public void setEmail(String v)      { this.email = v; }
    public void setAvatarUrl(String v)  { this.avatarUrl = v; }
    public void setStudentId(Integer v) { this.studentId = v; }
    public void setCreatedAt(LocalDateTime v) { this.createdAt = v; }
}
