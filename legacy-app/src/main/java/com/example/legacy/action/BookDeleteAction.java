package com.example.legacy.action;

import com.example.legacy.dao.BookDao;
import com.example.legacy.util.MyBatisUtil;
import com.opensymphony.xwork2.ActionSupport;
import org.apache.ibatis.session.SqlSession;

public class BookDeleteAction extends ActionSupport {
    private Long id;

    @Override
    public String execute() {
        if (id == null) {
            addActionError("IDが指定されていません。");
            return ERROR;
        }
        try (SqlSession session = MyBatisUtil.getSqlSessionFactory().openSession()) {
            BookDao dao = session.getMapper(BookDao.class);
            dao.delete(id);
            session.commit();
        }
        return SUCCESS;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
}
