package com.myfs.backend.dao;

import com.myfs.backend.model.Semester;
import java.util.*;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SemesterDao extends JpaRepository<Semester, Integer> {
  Optional<Semester> findByActiveTrue();
}
