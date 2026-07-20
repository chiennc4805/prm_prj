package com.myfs.backend.model;

import jakarta.persistence.*;

/**
 * Entity ánh xạ bảng schedule – lịch học / thời khóa biểu (LichHoc).
 * dayOrder: 2=Thứ 2 ... 7=Thứ 7, 8=Chủ nhật.
 */
@Entity
@Table(name = "schedule")
public class Schedule {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "class_id", nullable = false)
    private Integer classId;

    @Column(name = "day_order", nullable = false)
    private Integer dayOrder;

    @Column(name = "period", nullable = false)
    private Integer period;

    @Column(name = "subject", nullable = false, length = 100)
    private String subject;

    @Column(name = "room", length = 50)
    private String room;

    @Column(name = "teacher_name", length = 100)
    private String teacherName;

    @Column(name = "start_time", length = 10)
    private String startTime;

    @Column(name = "end_time", length = 10)
    private String endTime;

    public Schedule() {}

    public Integer getId()          { return id; }
    public Integer getClassId()     { return classId; }
    public Integer getDayOrder()    { return dayOrder; }
    public Integer getPeriod()      { return period; }
    public String  getSubject()     { return subject; }
    public String  getRoom()        { return room; }
    public String  getTeacherName() { return teacherName; }
    public String  getStartTime()   { return startTime; }
    public String  getEndTime()     { return endTime; }

    public void setId(Integer v)          { this.id = v; }
    public void setClassId(Integer v)     { this.classId = v; }
    public void setDayOrder(Integer v)    { this.dayOrder = v; }
    public void setPeriod(Integer v)      { this.period = v; }
    public void setSubject(String v)      { this.subject = v; }
    public void setRoom(String v)         { this.room = v; }
    public void setTeacherName(String v)  { this.teacherName = v; }
    public void setStartTime(String v)    { this.startTime = v; }
    public void setEndTime(String v)      { this.endTime = v; }
}
