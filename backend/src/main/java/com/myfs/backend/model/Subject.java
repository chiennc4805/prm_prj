package com.myfs.backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter @Setter
@Entity @Table(name = "subject")
public class Subject {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Integer id;
    @Column(nullable = false, unique = true, length = 20) private String code;
    @Column(nullable = false, unique = true, length = 100) private String name;
    @Column(length = 500) private String description;
    @Column(name = "is_active", nullable = false) private Boolean active = true;
}
