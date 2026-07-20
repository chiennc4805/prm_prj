package com.myfs.backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(
  name = "school_class",
  uniqueConstraints = @UniqueConstraint(
    columnNames = { "name", "academic_year" }
  )
)
public class SchoolClass {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer id;

  @Column(nullable = false, length = 50)
  private String name;

  @Column(name = "academic_year", nullable = false, length = 20)
  private String academicYear;

  @Column(name = "homeroom_teacher_id")
  private Integer homeroomTeacherId;
}
