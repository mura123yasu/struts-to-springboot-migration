package com.example.legacy.action;

import com.example.legacy.dao.UserDao;
import com.example.legacy.model.LoginUser;
import com.example.legacy.util.MyBatisUtil;
import com.opensymphony.xwork2.ActionSupport;
import org.apache.ibatis.session.SqlSession;
import org.apache.struts2.interceptor.SessionAware;

import java.util.Map;

public class LoginAction extends ActionSupport implements SessionAware {
    private String username;
    private String password;
    private Map<String, Object> session;

    public String input() {
        return INPUT;
    }

    @Override
    public String execute() {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSessionFactory().openSession()) {
            UserDao dao = sqlSession.getMapper(UserDao.class);
            LoginUser user = dao.findByUsername(username);
            if (user == null || !user.getPassword().equals(password)) {
                addActionError("ユーザー名またはパスワードが正しくありません。");
                return INPUT;
            }
            session.put("loginUser", user);
        }
        return SUCCESS;
    }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    @Override
    public void setSession(Map<String, Object> session) { this.session = session; }
}
