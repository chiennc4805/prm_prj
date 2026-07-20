package com.myfs.backend.controller;

import com.myfs.backend.dao.ScheduleDao;
import com.myfs.backend.model.Schedule;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * ScheduleController – REST API lịch học / TKB (LichHoc).
 *   GET /api/schedules/class/{classId} – TKB của 1 lớp.
 */
@RestController
@RequestMapping("/api/schedules")
public class ScheduleController {

    private final ScheduleDao scheduleDao;

    public ScheduleController(ScheduleDao scheduleDao) {
        this.scheduleDao = scheduleDao;
    }

    @GetMapping("/class/{classId}")
    public List<Schedule> byClass(@PathVariable Integer classId) {
        return scheduleDao.findByClassIdOrderByDayOrderAscPeriodAsc(classId);
    }
}
