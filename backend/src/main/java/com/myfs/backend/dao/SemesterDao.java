package com.myfs.backend.dao;
import com.myfs.backend.model.Semester;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.*;
public interface SemesterDao extends JpaRepository<Semester,Integer> { Optional<Semester> findByActiveTrue(); }
