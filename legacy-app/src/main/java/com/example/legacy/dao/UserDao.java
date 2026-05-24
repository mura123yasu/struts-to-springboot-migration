package com.example.legacy.dao;

import com.example.legacy.model.LoginUser;

public interface UserDao {
    LoginUser findByUsername(String username);
}
