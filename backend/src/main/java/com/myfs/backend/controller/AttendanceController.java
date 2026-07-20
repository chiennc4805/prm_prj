package com.myfs.backend.controller;

import com.myfs.backend.dao.AttendanceDao;
import com.myfs.backend.dao.StudentDao;
import com.myfs.backend.model.Attendance;
import com.myfs.backend.model.Student;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * AttendanceController – REST API điểm danh / chuyên cần.
 *
 *   GET  /api/attendance/student/{sid}          – lịch sử điểm danh 1 học sinh
 *   GET  /api/attendance/student/{sid}/summary  – thống kê chuyên cần
 *   GET  /api/attendance/class/{cid}?date=...    – điểm danh cả lớp 1 ngày
 *   POST /api/attendance                         – ghi 1 lượt (tự cập nhật nếu đã có)
 *   POST /api/attendance/batch                   – điểm danh nhiều học sinh cùng lúc
 */
@RestController
@RequestMapping("/api/attendance")
public class AttendanceController {

    private final AttendanceDao attendanceDao;
    private final StudentDao studentDao;

    public AttendanceController(AttendanceDao attendanceDao, StudentDao studentDao) {
        this.attendanceDao = attendanceDao;
        this.studentDao = studentDao;
    }

    @GetMapping("/student/{studentId}")
    public List<Attendance> byStudent(@PathVariable Integer studentId) {
        return attendanceDao.findByStudentIdOrderByDateDesc(studentId);
    }

    @GetMapping("/student/{studentId}/summary")
    public Map<String, Long> summary(@PathVariable Integer studentId) {
        Map<String, Long> m = new HashMap<>();
        long present = attendanceDao.countByStudentIdAndStatus(studentId, "PRESENT");
        long absent  = attendanceDao.countByStudentIdAndStatus(studentId, "ABSENT");
        long late    = attendanceDao.countByStudentIdAndStatus(studentId, "LATE");
        long excused = attendanceDao.countByStudentIdAndStatus(studentId, "EXCUSED");
        m.put("present", present);
        m.put("absent", absent);
        m.put("late", late);
        m.put("excused", excused);
        m.put("total", present + absent + late + excused);
        return m;
    }

    @GetMapping("/class/{classId}")
    public List<Attendance> byClassAndDate(
            @PathVariable Integer classId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        List<Integer> ids = studentIdsOfClass(classId);
        if (ids.isEmpty()) return new ArrayList<>();
        return attendanceDao.findByStudentIdInAndDate(ids, date);
    }

    /** Ghi/điểm danh 1 học sinh. Nếu đã có bản ghi cùng ngày thì cập nhật. */
    @PostMapping
    public Attendance record(@RequestBody Attendance att) {
        Attendance existing = attendanceDao.findByStudentIdAndDate(att.getStudentId(), att.getDate());
        if (existing != null) {
            existing.setStatus(att.getStatus());
            existing.setNote(att.getNote());
            existing.setRecordedById(att.getRecordedById());
            return attendanceDao.save(existing);
        }
        return attendanceDao.save(att);
    }

    /** Điểm danh hàng loạt (cả lớp trong 1 ngày). */
    @PostMapping("/batch")
    public List<Attendance> recordBatch(@RequestBody List<Attendance> list) {
        List<Attendance> saved = new ArrayList<>();
        for (Attendance att : list) saved.add(record(att));
        return saved;
    }

    private List<Integer> studentIdsOfClass(Integer classId) {
        List<Integer> ids = new ArrayList<>();
        for (Student s : studentDao.findByClassId(classId)) ids.add(s.getId());
        return ids;
    }
}
