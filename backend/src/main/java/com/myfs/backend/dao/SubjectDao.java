package com.myfs.backend.dao;
import com.myfs.backend.model.Subject;
import org.springframework.data.jpa.repository.JpaRepository;
public interface SubjectDao extends JpaRepository<Subject,Integer> {}
