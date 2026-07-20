package com.myfs.backend.dao;

import com.myfs.backend.model.AppUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/** DAO cho bảng app_user (tài khoản đăng nhập). */
@Repository
public interface AppUserDao extends JpaRepository<AppUser, Integer> {

    /** Tìm tài khoản theo số điện thoại – dùng cho đăng nhập. */
    Optional<AppUser> findByPhone(String phone);
    Optional<AppUser> findByEmail(String email);

    /** Lấy danh sách tài khoản theo vai trò (TEACHER / PARENT). */
    List<AppUser> findByRole(String role);
}
