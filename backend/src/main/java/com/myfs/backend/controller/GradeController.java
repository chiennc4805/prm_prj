package com.myfs.backend.controller;

import com.myfs.backend.dao.GradeDao;
import com.myfs.backend.model.Grade;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * GradeController – REST API điểm / sổ liên lạc (JSON cho Flutter).
 *
 *   GET    /api/grades                  – tất cả điểm
 *   GET    /api/grades/student/{sid}    – điểm của 1 học sinh (phụ huynh xem)
 *   GET    /api/grades/{id}             – 1 bản ghi
 *   POST   /api/grades                  – thêm (giáo viên)
 *   PUT    /api/grades/{id}             – sửa (giáo viên)
 *   DELETE /api/grades/{id}             – xóa (giáo viên)
 *
 * gradeLetter được server tự tính từ điểm số nên client không cần gửi.
 */
@RestController
@RequestMapping("/api/grades")
public class GradeController {

    private final GradeDao gradeDao;

    public GradeController(GradeDao gradeDao) {
        this.gradeDao = gradeDao;
    }

    @GetMapping
    public List<Grade> getAll() {
        return gradeDao.findAll();
    }

    @GetMapping("/student/{studentId}")
    public List<Grade> byStudent(@PathVariable Integer studentId) {
        return gradeDao.findByStudentId(studentId);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Grade> byId(@PathVariable Integer id) {
        return gradeDao.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/teacher/{teacherName}/assignments")
    public List<com.myfs.backend.model.TeacherAssignmentProjection> getTeacherAssignments(
            @PathVariable String teacherName,
            @RequestParam(required = false, defaultValue = "HK2") String semester) {
        if (semester != null && !semester.trim().isEmpty() && !semester.equalsIgnoreCase("ALL")) {
            return gradeDao.findAssignmentsByTeacherNameAndSemester(teacherName, semester);
        }
        return gradeDao.findAssignmentsByTeacherName(teacherName);
    }

    @GetMapping("/teacher/{teacherName}/class/{classId}/subject/{subject}/semester/{semester}")
    public List<Grade> getTeacherGrades(
            @PathVariable String teacherName,
            @PathVariable Integer classId,
            @PathVariable String subject,
            @PathVariable String semester) {
        return gradeDao.findGradesByTeacherClassAndSubject(teacherName, classId, subject, semester);
    }

    @PostMapping
    public ResponseEntity<Grade> create(@RequestBody Grade grade) {
        computeAndSetAverageAndLetter(grade);
        return ResponseEntity.ok(gradeDao.save(grade));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Grade> update(@PathVariable Integer id, @RequestBody Grade grade) {
        if (!gradeDao.existsById(id)) return ResponseEntity.notFound().build();
        grade.setId(id);
        computeAndSetAverageAndLetter(grade);
        return ResponseEntity.ok(gradeDao.save(grade));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Integer id) {
        if (!gradeDao.existsById(id)) return ResponseEntity.notFound().build();
        gradeDao.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    // ── Helpers ────────────────────────────────────────────────────────

    private void computeAndSetAverageAndLetter(Grade g) {
        double totalWeight = 0;
        double sum = 0;

        if (g.getRegularScores() != null && !g.getRegularScores().trim().isEmpty()) {
            String[] scores = g.getRegularScores().split(",");
            for (String s : scores) {
                try {
                    sum += Double.parseDouble(s.trim());
                    totalWeight += 1;
                } catch (Exception e) {}
            }
        }
        
        if (g.getMidtermScore() != null) {
            sum += g.getMidtermScore().doubleValue() * 2;
            totalWeight += 2;
        }

        if (g.getFinalScore() != null) {
            sum += g.getFinalScore().doubleValue() * 3;
            totalWeight += 3;
        }

        if (totalWeight > 0) {
            double avg = sum / totalWeight;
            g.setAverageScore(new java.math.BigDecimal(avg).setScale(2, java.math.RoundingMode.HALF_UP));
            g.setGradeLetter(computeGradeLetter(avg));
        } else {
            g.setAverageScore(null);
            g.setGradeLetter(null);
        }
    }

    /**
     * Quy đổi điểm số (0-10) sang điểm chữ.
     */
    private String computeGradeLetter(double score) {
        if (score >= 8.5) return "A";
        if (score >= 8.0) return "B+";
        if (score >= 7.0) return "B";
        if (score >= 6.5) return "C+";
        if (score >= 5.5) return "C";
        if (score >= 5.0) return "D+";
        if (score >= 4.0) return "D";
        return "F";
    }
}
