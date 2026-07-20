package com.myfs.backend.model;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Entity ánh xạ bảng event – sự kiện của trường (SuKien).
 */
@Entity
@Table(name = "event")
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Column(name = "description", columnDefinition = "NVARCHAR(MAX)")
    private String description;

    @Column(name = "location", length = 150)
    private String location;

    @Column(name = "event_date", nullable = false)
    private LocalDate eventDate;

    @Column(name = "event_time", length = 20)
    private String eventTime;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    public Event() {}

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    public Integer   getId()          { return id; }
    public String    getTitle()       { return title; }
    public String    getDescription() { return description; }
    public String    getLocation()    { return location; }
    public LocalDate getEventDate()   { return eventDate; }
    public String    getEventTime()   { return eventTime; }
    public LocalDateTime getCreatedAt() { return createdAt; }

    public void setId(Integer v)          { this.id = v; }
    public void setTitle(String v)        { this.title = v; }
    public void setDescription(String v)  { this.description = v; }
    public void setLocation(String v)     { this.location = v; }
    public void setEventDate(LocalDate v) { this.eventDate = v; }
    public void setEventTime(String v)    { this.eventTime = v; }
    public void setCreatedAt(LocalDateTime v) { this.createdAt = v; }
}
