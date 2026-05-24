package com.example.legacy.action;

import com.opensymphony.xwork2.ActionSupport;
import org.apache.struts2.interceptor.SessionAware;

import java.util.Map;

public class LogoutAction extends ActionSupport implements SessionAware {
    private Map<String, Object> session;

    @Override
    public String execute() {
        session.clear();
        return SUCCESS;
    }

    @Override
    public void setSession(Map<String, Object> session) { this.session = session; }
}
