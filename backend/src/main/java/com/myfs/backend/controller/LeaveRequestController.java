package com.myfs.backend.controller;

import com.myfs.backend.dao.LeaveRequestDao;
import com.myfs.backend.dao.StudentDao;
import com.myfs.backend.model.LeaveRequest;
import com.myfs.backend.model.Student;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * LeaveRequestController – REST API đơn xin nghỉ học.
 *
 *   POST /api/leaves                  – phụ huynh tạo đơn (PENDING)
 *   GET  /api/leaves/student/{sid}    – lịch sử đơn của 1 học sinh
 *   GET  /api/leaves/class/{cid}      – đơn của 1 lớp (giáo viên duyệt)
 *   PUT  /api/leaves/{id}/status      – duyệt/từ chối: { status, reviewedById }
 */
@RestController
@RequestMapping("/api/leaves")
public class LeaveRequestController {

    private final LeaveRequestDao leaveDao;
    private final StudentDao studentDao;

    public LeaveRequestController(LeaveRequestDao leaveDao, StudentDao studentDao) {
        this.leaveDao = leaveDao;
        this.studentDao = studentDao;
    }

    @PostMapping
    public LeaveRequest create(@RequestBody LeaveRequest req) {
        req.setId(null);
        if (req.getStatus() == null || req.getStatus().isEmpty()) {
            req.setStatus("PENDING_TEACHER");
        }
        req.setReviewedById(null);
        return leaveDao.save(req);
    }

    @GetMapping("/student/{studentId}")
    public List<LeaveRequest> byStudent(@PathVariable Integer studentId) {
        return leaveDao.findByStudentIdOrderByCreatedAtDesc(studentId);
    }

    @GetMapping("/class/{classId}")
    public List<LeaveRequest> byClass(@PathVariable Integer classId) {
        List<Integer> ids = new ArrayList<>();
        for (Student s : studentDao.findByClassId(classId)) ids.add(s.getId());
        if (ids.isEmpty()) return new ArrayList<>();
        List<LeaveRequest> all = leaveDao.findByStudentIdInOrderByCreatedAtDesc(ids);
        List<LeaveRequest> filtered = new ArrayList<>();
        for (LeaveRequest r : all) {
            if ("PENDING_PARENT".equals(r.getStatus())) continue;
            if ("OTHER".equals(r.getLeaveType())) continue;
            filtered.add(r);
        }
        return filtered;
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<LeaveRequest> updateStatus(@PathVariable Integer id,
                                                     @RequestBody Map<String, Object> body) {
        return leaveDao.findById(id).map(req -> {
            Object status = body.get("status");           // "APPROVED" | "REJECTED"
            Object reviewer = body.get("reviewedById");
            if (status != null) req.setStatus(status.toString());
            if (reviewer != null) req.setReviewedById(Integer.valueOf(reviewer.toString()));
            return ResponseEntity.ok(leaveDao.save(req));
        }).orElse(ResponseEntity.notFound().build());
    }
}
