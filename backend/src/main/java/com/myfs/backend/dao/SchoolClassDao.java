package com.myfs.backend.dao;

import com.myfs.backend.model.SchoolClass;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/** DAO cho bảng school_class (lớp học). */
@Repository
public interface SchoolClassDao extends JpaRepository<SchoolClass, Integer> {

    /** Các lớp do một giáo viên làm chủ nhiệm. */
    List<SchoolClass> findByHomeroomTeacherId(Integer homeroomTeacherId);
}
