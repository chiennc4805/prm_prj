package com.myfs.backend.controller;

import com.myfs.backend.dao.SchoolClassDao;
import com.myfs.backend.dao.StudentDao;
import com.myfs.backend.model.Student;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * StudentController – REST API cho học sinh.
 *   GET /api/students/parent/{parentId} – danh sách con của 1 phụ huynh
 *   GET /api/students/class/{classId}   – sĩ số 1 lớp (cho giáo viên)
 *   GET /api/students/{id}              – chi tiết 1 học sinh
 */
@RestController
@RequestMapping("/api/students")
public class StudentController {

    private final StudentDao studentDao;
    private final SchoolClassDao classDao;

    public StudentController(StudentDao studentDao, SchoolClassDao classDao) {
        this.studentDao = studentDao;
        this.classDao = classDao;
    }

    @GetMapping("/parent/{parentId}")
    public List<Student> byParent(@PathVariable Integer parentId) {
        List<Student> list = studentDao.findByParentId(parentId);
        list.forEach(this::attachClassName);
        return list;
    }

    @GetMapping("/class/{classId}")
    public List<Student> byClass(@PathVariable Integer classId) {
        List<Student> list = studentDao.findByClassId(classId);
        list.forEach(this::attachClassName);
        return list;
    }

    @GetMapping("/{id}")
    public ResponseEntity<Student> byId(@PathVariable Integer id) {
        return studentDao.findById(id)
                .map(s -> { attachClassName(s); return ResponseEntity.ok(s); })
                .orElse(ResponseEntity.notFound().build());
    }

    private void attachClassName(Student s) {
        if (s.getClassId() != null) {
            classDao.findById(s.getClassId()).ifPresent(c -> s.setClassName(c.getName()));
        }
    }
}
