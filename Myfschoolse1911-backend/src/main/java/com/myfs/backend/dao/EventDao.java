package com.myfs.backend.dao;

import com.myfs.backend.model.Event;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/** DAO cho bảng event (sự kiện). */
@Repository
public interface EventDao extends JpaRepository<Event, Integer> {
  /** Sự kiện sắp theo ngày diễn ra (gần nhất trước). */
  List<Event> findAllByOrderByEventDateAsc();
}
