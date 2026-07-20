package com.myfs.backend.controller;

import com.myfs.backend.dao.*;
import com.myfs.backend.model.*;
import com.myfs.backend.service.*;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import java.math.*;
import java.time.*;
import java.util.*;

@RestController @RequestMapping("/api/teacher")
public class TeacherController {
    private final SchoolAuthorizationService access;
    private final TeacherAssignmentDao assignments; private final ScheduleDao schedules; private final StudentDao students;
    private final AttendanceDao attendance; private final GradeDao grades; private final NotificationDao notifications;
    private final LeaveRequestDao leaves; private final StudentEvaluationDao evaluations; private final SchoolClassDao classes;
    public TeacherController(SchoolAuthorizationService access,TeacherAssignmentDao assignments,ScheduleDao schedules,StudentDao students,AttendanceDao attendance,GradeDao grades,NotificationDao notifications,LeaveRequestDao leaves,StudentEvaluationDao evaluations,SchoolClassDao classes){this.access=access;this.assignments=assignments;this.schedules=schedules;this.students=students;this.attendance=attendance;this.grades=grades;this.notifications=notifications;this.leaves=leaves;this.evaluations=evaluations;this.classes=classes;}

    @GetMapping("/assignments") public List<TeacherAssignment> assignments(@RequestParam Integer teacherId){return assignments.findByTeacherId(teacherId);}
    @GetMapping("/schedule") public List<Schedule> schedule(@RequestParam Integer teacherId){return schedules.findForTeacher(teacherId);}
    @GetMapping("/assignments/{id}/students") public List<Student> roster(@RequestParam Integer teacherId,@PathVariable Integer id){TeacherAssignment a=access.requireAssignment(id,teacherId);return students.findByClassId(a.getClassId());}

    @GetMapping("/assignments/{id}/grades") public List<Grade> grades(@RequestParam Integer teacherId,@PathVariable Integer id){access.requireAssignment(id,teacherId);return grades.findByTeacherAssignmentId(id);}
    @PutMapping("/assignments/{id}/students/{studentId}/grade") public Grade saveGrade(@RequestParam Integer teacherId,@PathVariable Integer id,@PathVariable Integer studentId,@RequestBody Grade input){TeacherAssignment a=access.requireAssignment(id,teacherId);access.requireStudentInClass(studentId,a.getClassId());Grade g=grades.findByStudentIdAndTeacherAssignmentId(studentId,id).orElseGet(Grade::new);g.setStudentId(studentId);g.setTeacherAssignmentId(id);g.setRegularScores(input.getRegularScores());g.setMidtermScore(input.getMidtermScore());g.setFinalScore(input.getFinalScore());g.setAverageScore(average(g));return grades.save(g);}

    @GetMapping("/schedules/{scheduleId}/attendance") public List<Attendance> attendance(@RequestParam Integer teacherId,@PathVariable Integer scheduleId,@RequestParam LocalDate date){access.requireSchedule(scheduleId,teacherId);return attendance.findByScheduleIdAndAttendanceDate(scheduleId,date);}
    @PutMapping("/schedules/{scheduleId}/attendance") public List<Attendance> saveAttendance(@RequestParam Integer teacherId,@PathVariable Integer scheduleId,@RequestParam LocalDate date,@RequestBody List<Attendance> input){Schedule schedule=access.requireSchedule(scheduleId,teacherId);TeacherAssignment a=assignments.findById(schedule.getTeacherAssignmentId()).orElseThrow();List<Attendance> result=new ArrayList<>();for(Attendance row:input){access.requireStudentInClass(row.getStudentId(),a.getClassId());Attendance entity=attendance.findByStudentIdAndScheduleIdAndAttendanceDate(row.getStudentId(),scheduleId,date).orElseGet(Attendance::new);entity.setStudentId(row.getStudentId());entity.setScheduleId(scheduleId);entity.setAttendanceDate(date);entity.setStatus(row.getStatus());entity.setNote(row.getNote());entity.setRecordedById(teacherId);result.add(attendance.save(entity));}return result;}

    @PostMapping("/classes/{classId}/notifications") public Notification notify(@RequestParam Integer teacherId,@PathVariable Integer classId,@RequestBody Notification n){boolean allowed=assignments.existsByTeacherIdAndClassId(teacherId,classId)||classes.findById(classId).map(c->teacherId.equals(c.getHomeroomTeacherId())).orElse(false);if(!allowed)throw new ResponseStatusException(HttpStatus.FORBIDDEN,"Không phụ trách lớp này");n.setId(null);n.setSenderId(teacherId);n.setClassId(classId);return notifications.save(n);}

    @GetMapping("/homeroom/{classId}/leaves") public List<LeaveRequest> leaves(@RequestParam Integer teacherId,@PathVariable Integer classId){access.requireHomeroom(classId,teacherId);return leaves.findForClass(classId);}
    public record ReviewRequest(String status,String rejectionReason){}
    @PutMapping("/homeroom/{classId}/leaves/{leaveId}") public LeaveRequest review(@RequestParam Integer teacherId,@PathVariable Integer classId,@PathVariable Integer leaveId,@RequestBody ReviewRequest body){access.requireHomeroom(classId,teacherId);if(!Set.of("APPROVED","REJECTED").contains(body.status()))throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Trạng thái phải là APPROVED hoặc REJECTED");LeaveRequest r=leaves.findById(leaveId).orElseThrow(()->new ResponseStatusException(HttpStatus.NOT_FOUND));Student s=access.requireStudentInClass(r.getStudentId(),classId);r.setStatus(body.status());r.setRejectionReason("REJECTED".equals(body.status())?body.rejectionReason():null);r.setReviewedById(teacherId);r.setReviewedAt(LocalDateTime.now());return leaves.save(r);}
    @GetMapping("/homeroom/{classId}/grades") public List<Grade> classGrades(@RequestParam Integer teacherId,@PathVariable Integer classId){access.requireHomeroom(classId,teacherId);Set<Integer> ids=new HashSet<>();students.findByClassId(classId).forEach(s->ids.add(s.getId()));return grades.findAll().stream().filter(g->ids.contains(g.getStudentId())).toList();}
    @GetMapping("/homeroom/{classId}/evaluations") public List<StudentEvaluation> evaluations(@RequestParam Integer teacherId,@PathVariable Integer classId,@RequestParam Integer semesterId){access.requireHomeroom(classId,teacherId);return evaluations.findByClassIdAndSemesterId(classId,semesterId);}
    @PutMapping("/homeroom/{classId}/students/{studentId}/evaluation") public StudentEvaluation evaluate(@RequestParam Integer teacherId,@PathVariable Integer classId,@PathVariable Integer studentId,@RequestParam Integer semesterId,@RequestBody StudentEvaluation input){access.requireHomeroom(classId,teacherId);access.requireStudentInClass(studentId,classId);StudentEvaluation e=evaluations.findByStudentIdAndSemesterId(studentId,semesterId).orElseGet(StudentEvaluation::new);e.setStudentId(studentId);e.setClassId(classId);e.setSemesterId(semesterId);e.setHomeroomTeacherId(teacherId);e.setConductRating(input.getConductRating());e.setAcademicRating(input.getAcademicRating());e.setComment(input.getComment());return evaluations.save(e);}

    private BigDecimal average(Grade g){double sum=0,w=0;if(g.getRegularScores()!=null)for(String v:g.getRegularScores().split(","))try{double x=Double.parseDouble(v.trim());if(x<0||x>10)throw new NumberFormatException();sum+=x;w++;}catch(NumberFormatException e){throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Điểm thường xuyên phải trong khoảng 0-10");}if(g.getMidtermScore()!=null){sum+=g.getMidtermScore().doubleValue()*2;w+=2;}if(g.getFinalScore()!=null){sum+=g.getFinalScore().doubleValue()*3;w+=3;}return w==0?null:BigDecimal.valueOf(sum/w).setScale(2,RoundingMode.HALF_UP);}
}

