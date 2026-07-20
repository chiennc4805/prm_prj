package com.myfs.backend.model;

import jakarta.persistence.*;

/**
 * Entity ánh xạ bảng school_class – lớp học.
 * homeroomTeacherId trỏ tới app_user của giáo viên chủ nhiệm.
 */
@Entity
@Table(name = "school_class")
public class SchoolClass {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "name", nullable = false, length = 50)
    private String name;

    @Column(name = "academic_year", nullable = false, length = 20)
    private String academicYear;

    @Column(name = "homeroom_teacher_id")
    private Integer homeroomTeacherId;

    public SchoolClass() {}

    public Integer getId()                { return id; }
    public String  getName()              { return name; }
    public String  getAcademicYear()      { return academicYear; }
    public Integer getHomeroomTeacherId() { return homeroomTeacherId; }

    public void setId(Integer v)                { this.id = v; }
    public void setName(String v)               { this.name = v; }
    public void setAcademicYear(String v)       { this.academicYear = v; }
    public void setHomeroomTeacherId(Integer v) { this.homeroomTeacherId = v; }
}
