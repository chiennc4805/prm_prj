package com.myfs.backend.dao;

import com.myfs.backend.model.Club;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/** DAO cho bảng club (câu lạc bộ). */
@Repository
public interface ClubDao extends JpaRepository<Club, Integer> {}
