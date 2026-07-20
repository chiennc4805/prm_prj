package com.myfs.backend.dao;

import com.myfs.backend.model.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/** DAO cho bảng schedule (lịch học / TKB). */
@Repository
public interface ScheduleDao extends JpaRepository<Schedule, Integer> {

    /** Thời khóa biểu của 1 lớp, sắp theo thứ rồi theo tiết. */
    List<Schedule> findByClassIdOrderByDayOrderAscPeriodAsc(Integer classId);
}
