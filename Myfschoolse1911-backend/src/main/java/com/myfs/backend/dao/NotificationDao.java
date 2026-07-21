package com.myfs.backend.dao;

import com.myfs.backend.model.Notification;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

/** DAO cho bảng notification (thông báo / hộp thư). */
@Repository
public interface NotificationDao extends JpaRepository<Notification, Integer> {
  /** Tất cả thông báo, mới nhất lên trước (cho giáo viên). */
  List<Notification> findAllByOrderByCreatedAtDesc();

  /**
   * Thông báo mà một lớp nhận được = thông báo của lớp đó
   * HOẶC thông báo toàn trường (class_id = null).
   */
  @Query(
    "SELECT n FROM Notification n " +
      "WHERE n.classId = :classId OR n.classId IS NULL " +
      "ORDER BY n.createdAt DESC"
  )
  List<Notification> findForClass(@Param("classId") Integer classId);
}
