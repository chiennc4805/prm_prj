package com.myfs.backend.model;

import jakarta.persistence.*;
import java.time.LocalDate;

/**
 * Entity ánh xạ bảng student – học sinh.
 * classId  -> school_class, parentId -> app_user (tài khoản phụ huynh).
 * className là field tạm (không lưu DB) để trả kèm tên lớp cho client.
 */
@Entity
@Table(name = "student")
public class Student {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "student_code", nullable = false, length = 20, unique = true)
    private String studentCode;

    @Column(name = "full_name", nullable = false, length = 100)
    private String fullName;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    @Column(name = "gender", length = 10)
    private String gender;

    @Column(name = "class_id")
    private Integer classId;

    @Column(name = "parent_id")
    private Integer parentId;

    // Không map cột — chỉ để trả tên lớp kèm theo response cho tiện hiển thị.
    @Transient
    private String className;

    public Student() {}

    public Integer getId()            { return id; }
    public String  getStudentCode()   { return studentCode; }
    public String  getFullName()      { return fullName; }
    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public String  getGender()        { return gender; }
    public Integer getClassId()       { return classId; }
    public Integer getParentId()      { return parentId; }
    public String  getClassName()     { return className; }

    public void setId(Integer v)            { this.id = v; }
    public void setStudentCode(String v)    { this.studentCode = v; }
    public void setFullName(String v)       { this.fullName = v; }
    public void setDateOfBirth(LocalDate v) { this.dateOfBirth = v; }
    public void setGender(String v)         { this.gender = v; }
    public void setClassId(Integer v)       { this.classId = v; }
    public void setParentId(Integer v)      { this.parentId = v; }
    public void setClassName(String v)      { this.className = v; }
}
