package com.example.legacy.action;

import com.example.legacy.dao.BookDao;
import com.example.legacy.model.Book;
import com.example.legacy.util.MyBatisUtil;
import com.opensymphony.xwork2.ActionSupport;
import org.apache.ibatis.session.SqlSession;

import java.util.List;

public class BookListAction extends ActionSupport {
    private List<Book> books;
    private String searchTitle;
    private String searchAuthor;
    private String searchCategory;

    @Override
    public String execute() {
        try (SqlSession session = MyBatisUtil.getSqlSessionFactory().openSession()) {
            BookDao dao = session.getMapper(BookDao.class);
            if (hasSearchParams()) {
                books = dao.search(searchTitle, searchAuthor, searchCategory);
            } else {
                books = dao.findAll();
            }
        }
        return SUCCESS;
    }

    private boolean hasSearchParams() {
        return (searchTitle != null && !searchTitle.isEmpty())
                || (searchAuthor != null && !searchAuthor.isEmpty())
                || (searchCategory != null && !searchCategory.isEmpty());
    }

    public List<Book> getBooks() { return books; }
    public String getSearchTitle() { return searchTitle; }
    public void setSearchTitle(String searchTitle) { this.searchTitle = searchTitle; }
    public String getSearchAuthor() { return searchAuthor; }
    public void setSearchAuthor(String searchAuthor) { this.searchAuthor = searchAuthor; }
    public String getSearchCategory() { return searchCategory; }
    public void setSearchCategory(String searchCategory) { this.searchCategory = searchCategory; }
}
