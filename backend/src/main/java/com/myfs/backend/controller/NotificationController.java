package com.myfs.backend.controller;

import com.myfs.backend.dao.NotificationDao;
import com.myfs.backend.model.Notification;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * NotificationController – REST API thông báo / hộp thư.
 *
 *   GET  /api/notifications            – tất cả thông báo (giáo viên)
 *   GET  /api/notifications/class/{cid}– thông báo lớp + toàn trường (phụ huynh)
 *   POST /api/notifications            – giáo viên gửi thông báo
 */
@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationDao notificationDao;

    public NotificationController(NotificationDao notificationDao) {
        this.notificationDao = notificationDao;
    }

    @GetMapping
    public List<Notification> getAll() {
        return notificationDao.findAllByOrderByCreatedAtDesc();
    }

    @GetMapping("/class/{classId}")
    public List<Notification> forClass(@PathVariable Integer classId) {
        return notificationDao.findForClass(classId);
    }

    @PostMapping
    public Notification create(@RequestBody Notification noti) {
        noti.setId(null);
        return notificationDao.save(noti);
    }
}
