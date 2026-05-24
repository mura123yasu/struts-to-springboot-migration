# MyBatis SQL → JPA 変換方針

## 方針

- 単純 CRUD → `JpaRepository` の標準メソッドで置き換え
- 検索（動的 WHERE）→ `Specification` パターンで実装
- 論理削除 → `@Where(clause="deleted=false")` または `Specification` で絞り込み
- トランザクション → `@Transactional` に委譲（手動 commit 廃止）
- `updated_at` 自動更新 → `@UpdateTimestamp` または `@PreUpdate`

---

## エンティティ設計

### Book エンティティ

```java
@Entity
@Table(name = "books")
public class Book {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(nullable = false, length = 50)
    private String author;

    @Column(nullable = false, length = 13)
    private String isbn;

    @Column(nullable = false, length = 20)
    private String category;

    @Column(name = "published_year")
    private Integer publishedYear;

    @Column(nullable = false)
    private boolean deleted = false;

    @Column(name = "created_at", nullable = false, updatable = false)
    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
```

### User エンティティ

```java
@Entity
@Table(name = "users")
public class User {
    @Id
    @Column(length = 50)
    private String username;

    @Column(nullable = false, length = 100)
    private String password;  // BCrypt ハッシュ

    @Column(name = "display_name", nullable = false, length = 100)
    private String displayName;
}
```

---

## DAO → Repository 変換表

### BookDao → BookRepository

| MyBatis メソッド | JPA 実装方法 | コード例 |
|---|---|---|
| `findAll()` | `JpaRepository` + `Specification` | `findAll(Specification.where(notDeleted()))` |
| `search(title, author, category)` | `Specification` パターン | `findAll(spec, Sort.by("id").descending())` |
| `findById(id)` | `findById(id)` + フィルタ | `findById(id).filter(b -> !b.isDeleted())` |
| `insert(book)` | `save(book)` | `bookRepository.save(book)` |
| `update(book)` | `save(book)`（ID あり） | `bookRepository.save(book)` |
| `delete(id)` | 論理削除フラグを立てて `save` | `book.setDeleted(true); repository.save(book)` |

### UserDao → UserRepository

| MyBatis メソッド | JPA 実装方法 |
|---|---|
| `findByUsername(username)` | `Optional<User> findByUsername(String username)` |

---

## 動的検索の Specification 実装

### MyBatis（移行前）

```xml
<if test="title != null and title != ''">
    AND title LIKE CONCAT('%', #{title}, '%')
</if>
```

### JPA Specification（移行後）

```java
public class BookSpecification {

    public static Specification<Book> notDeleted() {
        return (root, query, cb) -> cb.equal(root.get("deleted"), false);
    }

    public static Specification<Book> titleLike(String title) {
        return (root, query, cb) ->
            (title == null || title.isEmpty())
                ? cb.conjunction()
                : cb.like(root.get("title"), "%" + title + "%");
    }

    public static Specification<Book> authorLike(String author) {
        return (root, query, cb) ->
            (author == null || author.isEmpty())
                ? cb.conjunction()
                : cb.like(root.get("author"), "%" + author + "%");
    }

    public static Specification<Book> categoryEqual(String category) {
        return (root, query, cb) ->
            (category == null || category.isEmpty())
                ? cb.conjunction()
                : cb.equal(root.get("category"), category);
    }
}

// BookService での使用例
public List<Book> search(String title, String author, String category) {
    Specification<Book> spec = Specification
        .where(notDeleted())
        .and(titleLike(title))
        .and(authorLike(author))
        .and(categoryEqual(category));
    return bookRepository.findAll(spec, Sort.by("id").descending());
}
```

---

## H2 初期化（Spring Boot 方式）

### MyBatis（移行前）

```xml
<!-- mybatis-config.xml -->
<property name="url" value="jdbc:h2:mem:...;INIT=RUNSCRIPT FROM 'classpath:schema.sql'..."/>
```

### Spring Boot（移行後）

```yaml
# application.yml
spring:
  sql:
    init:
      schema-locations: classpath:schema.sql
      data-locations:   classpath:data.sql
      mode: always
  jpa:
    hibernate:
      ddl-auto: none   # スキーマは schema.sql で管理
    show-sql: true
```

`data.sql` のパスワードは BCrypt ハッシュに変更:

```sql
-- data.sql（移行後）
INSERT INTO users (username, password, display_name) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '管理者');
-- ↑ BCrypt("password")
```

---

## トランザクション比較

| 操作 | MyBatis（移行前） | JPA（移行後） |
|---|---|---|
| 登録 | `session.commit()` を明示 | `@Transactional` を `BookService` に付与 |
| 更新 | `session.commit()` を明示 | 同上 |
| 削除 | `session.commit()` を明示 | 同上 |
| 読み取り | commit 不要 | `@Transactional(readOnly=true)` 推奨 |
