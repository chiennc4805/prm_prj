package com.myfs.backend.controller;

import com.myfs.backend.dao.EventDao;
import com.myfs.backend.model.Event;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * EventController – REST API sự kiện (SuKien).
 *   GET /api/events – danh sách sự kiện theo ngày.
 */
@RestController
@RequestMapping("/api/events")
public class EventController {

    private final EventDao eventDao;

    public EventController(EventDao eventDao) {
        this.eventDao = eventDao;
    }

    @GetMapping
    public List<Event> all() {
        return eventDao.findAllByOrderByEventDateAsc();
    }
}
