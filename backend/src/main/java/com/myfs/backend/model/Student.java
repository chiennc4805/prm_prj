package com.myfs.backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDate;

@Getter @Setter
@Entity @Table(name = "student")
public class Student {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Integer id;
    @Column(name = "student_code", nullable = false, unique = true, length = 20) private String studentCode;
    @Column(name = "full_name", nullable = false, length = 100) private String fullName;
    @Column(name = "date_of_birth") private LocalDate dateOfBirth;
    @Column(length = 10) private String gender;
    @Column(name = "class_id") private Integer classId;
    @Column(name = "parent_id") private Integer parentId;
    @Column(name = "student_account_id", unique = true) private Integer studentAccountId;
}
