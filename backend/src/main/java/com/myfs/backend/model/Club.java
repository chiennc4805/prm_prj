package com.myfs.backend.model;

import jakarta.persistence.*;

/**
 * Entity ánh xạ bảng club – câu lạc bộ (CLB).
 */
@Entity
@Table(name = "club")
public class Club {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "name", nullable = false, length = 150)
    private String name;

    @Column(name = "description", columnDefinition = "NVARCHAR(MAX)")
    private String description;

    @Column(name = "category", length = 50)
    private String category;

    @Column(name = "meeting_time", length = 100)
    private String meetingTime;

    @Column(name = "location", length = 150)
    private String location;

    @Column(name = "contact", length = 100)
    private String contact;

    @Column(name = "member_count", nullable = false)
    private Integer memberCount = 0;

    public Club() {}

    public Integer getId()          { return id; }
    public String  getName()        { return name; }
    public String  getDescription() { return description; }
    public String  getCategory()    { return category; }
    public String  getMeetingTime() { return meetingTime; }
    public String  getLocation()    { return location; }
    public String  getContact()     { return contact; }
    public Integer getMemberCount() { return memberCount; }

    public void setId(Integer v)          { this.id = v; }
    public void setName(String v)         { this.name = v; }
    public void setDescription(String v)  { this.description = v; }
    public void setCategory(String v)     { this.category = v; }
    public void setMeetingTime(String v)  { this.meetingTime = v; }
    public void setLocation(String v)     { this.location = v; }
    public void setContact(String v)      { this.contact = v; }
    public void setMemberCount(Integer v) { this.memberCount = v; }
}
