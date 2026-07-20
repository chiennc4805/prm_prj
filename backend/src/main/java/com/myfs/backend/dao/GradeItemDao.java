package com.myfs.backend.dao;

import com.myfs.backend.model.GradeItem;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GradeItemDao extends JpaRepository<GradeItem, Integer> {
  List<GradeItem> findByGradeId(Integer gradeId);
  void deleteByGradeId(Integer gradeId);
}
