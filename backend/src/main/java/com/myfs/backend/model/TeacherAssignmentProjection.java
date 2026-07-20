package com.myfs.backend.model;

public interface TeacherAssignmentProjection {
    Integer getClassId();
    String getClassName();
    String getSubject();
    String getSemester();
    String getAcademicYear();
}
