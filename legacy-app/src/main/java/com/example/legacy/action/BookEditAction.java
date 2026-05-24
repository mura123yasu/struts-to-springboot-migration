package com.example.legacy.action;

import com.example.legacy.dao.BookDao;
import com.example.legacy.form.BookForm;
import com.example.legacy.model.Book;
import com.example.legacy.util.MyBatisUtil;
import com.opensymphony.xwork2.ActionSupport;
import org.apache.ibatis.session.SqlSession;

public class BookEditAction extends ActionSupport {
    private Long id;
    private BookForm bookForm = new BookForm();

    public String input() {
        try (SqlSession session = MyBatisUtil.getSqlSessionFactory().openSession()) {
            BookDao dao = session.getMapper(BookDao.class);
            Book book = dao.findById(id);
            if (book == null) {
                addActionError("書籍が見つかりませんでした。");
                return ERROR;
            }
            bookForm.setId(book.getId());
            bookForm.setTitle(book.getTitle());
            bookForm.setAuthor(book.getAuthor());
            bookForm.setIsbn(book.getIsbn());
            bookForm.setCategory(book.getCategory());
            bookForm.setPublishedYear(book.getPublishedYear());
        }
        return INPUT;
    }

    @Override
    public String execute() {
        if (hasErrors()) {
            return INPUT;
        }
        Book book = new Book();
        book.setId(bookForm.getId());
        book.setTitle(bookForm.getTitle());
        book.setAuthor(bookForm.getAuthor());
        book.setIsbn(bookForm.getIsbn());
        book.setCategory(bookForm.getCategory());
        book.setPublishedYear(bookForm.getPublishedYear());

        try (SqlSession session = MyBatisUtil.getSqlSessionFactory().openSession()) {
            BookDao dao = session.getMapper(BookDao.class);
            dao.update(book);
            session.commit();
        }
        return SUCCESS;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public BookForm getBookForm() { return bookForm; }
    public void setBookForm(BookForm bookForm) { this.bookForm = bookForm; }

    // Struts2 はメソッド名に対応する validateXxx() を自動で呼ぶ
    public void validateExecute() {
        if (bookForm.getTitle() == null || bookForm.getTitle().trim().isEmpty()) {
            addFieldError("bookForm.title", "タイトルは必須です。");
        } else if (bookForm.getTitle().length() > 100) {
            addFieldError("bookForm.title", "タイトルは100文字以内で入力してください。");
        }
        if (bookForm.getAuthor() == null || bookForm.getAuthor().trim().isEmpty()) {
            addFieldError("bookForm.author", "著者名は必須です。");
        } else if (bookForm.getAuthor().length() > 50) {
            addFieldError("bookForm.author", "著者名は50文字以内で入力してください。");
        }
        if (bookForm.getIsbn() == null || bookForm.getIsbn().trim().isEmpty()) {
            addFieldError("bookForm.isbn", "ISBNは必須です。");
        } else if (!bookForm.getIsbn().matches("\\d{13}")) {
            addFieldError("bookForm.isbn", "ISBNは13桁の数字で入力してください。");
        }
        if (bookForm.getCategory() == null || bookForm.getCategory().trim().isEmpty()) {
            addFieldError("bookForm.category", "カテゴリは必須です。");
        }
        if (bookForm.getPublishedYear() != null) {
            int currentYear = java.time.Year.now().getValue();
            if (bookForm.getPublishedYear() < 1900 || bookForm.getPublishedYear() > currentYear) {
                addFieldError("bookForm.publishedYear", "出版年は1900年〜" + currentYear + "年の間で入力してください。");
            }
        }
    }
}
