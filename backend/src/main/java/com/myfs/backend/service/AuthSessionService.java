package com.myfs.backend.service;

import com.myfs.backend.dao.AppUserDao;
import com.myfs.backend.model.AppUser;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

/** Minimal development authentication: validate phone/password only. */
@Service
public class AuthSessionService {

  private final AppUserDao users;

  public AuthSessionService(AppUserDao users) {
    this.users = users;
  }

  public AppUser login(String phone, String password) {
    AppUser user = users.findByPhone(phone).orElseThrow(this::unauthorized);
    if (
      !Boolean.TRUE.equals(user.getActive()) ||
      !user.getPassword().equals(password)
    ) throw unauthorized();
    return user;
  }

  public AppUser findByPhone(String phone) {
    return users.findByPhone(phone).orElseThrow(this::unauthorized);
  }

  public void updatePassword(String phone, String password) {
    AppUser user = findByPhone(phone);
    user.setPassword(password);
    users.save(user);
  }

  private ResponseStatusException unauthorized() {
    return new ResponseStatusException(
      HttpStatus.UNAUTHORIZED,
      "Sai số điện thoại hoặc mật khẩu"
    );
  }
}
