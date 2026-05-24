package com.example.legacy.dao;

import com.example.legacy.model.Book;
import java.util.List;

public interface BookDao {
    List<Book> findAll();
    List<Book> search(String title, String author, String category);
    Book findById(Long id);
    void insert(Book book);
    void update(Book book);
    void delete(Long id);
}
