package com.myfs.backend.controller;

import com.myfs.backend.dao.ClubDao;
import com.myfs.backend.model.Club;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST API câu lạc bộ.
 * GET /api/clubs - danh sách câu lạc bộ.
 */
@RestController
@RequestMapping("/api/clubs")
public class ClubController {

    private final ClubDao clubDao;
    public ClubController(ClubDao clubDao) {
        this.clubDao = clubDao;
    }

    @GetMapping
    public List<Club> all() {
        return clubDao.findAll();
    }
}
