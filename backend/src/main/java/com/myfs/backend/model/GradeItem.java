package com.myfs.backend.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "grade_item")
public class GradeItem {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer id;

  @Column(name = "grade_id", nullable = false)
  private Integer gradeId;

  @Column(nullable = false, length = 100)
  private String name;

  @Column(nullable = false, precision = 4, scale = 2)
  private BigDecimal score;

  @Column(nullable = false, precision = 5, scale = 2)
  private BigDecimal weight;
}
