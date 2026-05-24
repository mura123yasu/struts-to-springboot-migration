package com.example.legacy.action;

import com.example.legacy.dao.BookDao;
import com.example.legacy.model.Book;
import com.example.legacy.util.MyBatisUtil;
import com.opensymphony.xwork2.ActionSupport;
import org.apache.ibatis.session.SqlSession;

public class BookDetailAction extends ActionSupport {
    private Long id;
    private Book book;

    @Override
    public String execute() {
        try (SqlSession session = MyBatisUtil.getSqlSessionFactory().openSession()) {
            BookDao dao = session.getMapper(BookDao.class);
            book = dao.findById(id);
        }
        if (book == null) {
            addActionError("書籍が見つかりませんでした。");
            return ERROR;
        }
        return SUCCESS;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Book getBook() { return book; }
}
