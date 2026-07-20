package com.myfs.backend.controller;

import com.myfs.backend.dao.EventDao;
import com.myfs.backend.model.Event;
import java.util.List;
import org.springframework.web.bind.annotation.*;

/**
 * REST API sự kiện.
 * GET /api/events - danh sách sự kiện theo ngày.
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
