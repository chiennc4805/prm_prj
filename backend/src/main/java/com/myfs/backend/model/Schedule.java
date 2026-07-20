package com.myfs.backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalTime;

@Getter @Setter
@Entity @Table(name = "schedule")
public class Schedule {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY) private Integer id;
    @Column(name = "teacher_assignment_id", nullable = false) private Integer teacherAssignmentId;
    @Column(name = "day_order", nullable = false) private Integer dayOrder;
    @Column(nullable = false) private Integer period;
    @Column(length = 50) private String room;
    @Column(name = "start_time", nullable = false) private LocalTime startTime;
    @Column(name = "end_time", nullable = false) private LocalTime endTime;
}
