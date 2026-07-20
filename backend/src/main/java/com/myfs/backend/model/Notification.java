package com.myfs.backend.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Entity ánh xạ bảng notification – thông báo (hộp thư).
 * classId = null  -> thông báo toàn trường;
 * classId = id lớp -> chỉ gửi cho lớp đó.
 */
@Entity
@Table(name = "notification")
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Column(name = "content", nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String content;

    @Column(name = "sender_id")
    private Integer senderId;

    @Column(name = "sender_name", length = 100)
    private String senderName;

    @Column(name = "class_id")
    private Integer classId;

    @Column(name = "class_name", length = 50)
    private String className;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    public Notification() {}

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    public Integer getId()         { return id; }
    public String  getTitle()      { return title; }
    public String  getContent()    { return content; }
    public Integer getSenderId()   { return senderId; }
    public String  getSenderName() { return senderName; }
    public Integer getClassId()    { return classId; }
    public String  getClassName()  { return className; }
    public LocalDateTime getCreatedAt() { return createdAt; }

    public void setId(Integer v)        { this.id = v; }
    public void setTitle(String v)      { this.title = v; }
    public void setContent(String v)    { this.content = v; }
    public void setSenderId(Integer v)  { this.senderId = v; }
    public void setSenderName(String v) { this.senderName = v; }
    public void setClassId(Integer v)   { this.classId = v; }
    public void setClassName(String v)  { this.className = v; }
    public void setCreatedAt(LocalDateTime v) { this.createdAt = v; }
}
