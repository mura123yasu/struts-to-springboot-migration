# ActionForm → Request/Response DTO 変換方針

## 方針

- Struts2 の `BookForm`（フォームBean）→ `BookRequest`（リクエスト DTO）に置き換え
- JSP の表示に使っていた `Book` モデル直接渡し → `BookResponse` DTO 経由に変更
- バリデーションは Bean Validation アノテーションに統一

---

## BookForm → BookRequest

### 移行前（BookForm.java）

```java
public class BookForm {
    private Long id;           // 編集時のみ使用
    private String title;
    private String author;
    private String isbn;
    private String category;
    private Integer publishedYear;
    // getter/setter のみ、バリデーションなし
}
```

### 移行後（BookRequest.java）

```java
public class BookRequest {
    @NotBlank(message = "タイトルは必須です。")
    @Size(max = 100, message = "タイトルは100文字以内で入力してください。")
    private String title;

    @NotBlank(message = "著者名は必須です。")
    @Size(max = 50, message = "著者名は50文字以内で入力してください。")
    private String author;

    @NotBlank(message = "ISBNは必須です。")
    @Pattern(regexp = "\\d{13}", message = "ISBNは13桁の数字で入力してください。")
    private String isbn;

    @NotBlank(message = "カテゴリは必須です。")
    private String category;  // "NOVEL" / "TECH" / "REFERENCE" / "OTHER"

    @Min(value = 1900, message = "出版年は1900年以降で入力してください。")
    private Integer publishedYear;  // null 許容（任意）
}
```

**変更点:**
- `id` フィールドを削除（POST/PUT の URL パスパラメータで表現するため不要）
- バリデーションを Bean Validation アノテーションで宣言的に定義
- `@Valid @RequestBody BookRequest request` でリクエストボディに自動バインド

---

## Book（エンティティ）→ BookResponse

### 移行前（JSP に Book モデルを直接渡す）

```java
// BookDetailAction
Book book = dao.findById(id);
// book がそのまま ValueStack 経由で JSP へ
```

### 移行後（BookResponse.java）

```java
public class BookResponse {
    private Long id;
    private String title;
    private String author;
    private String isbn;
    private String category;
    private Integer publishedYear;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    // getter のみ（不変）
}
```

**変換ロジック（BookService 内）:**

```java
private BookResponse toResponse(Book book) {
    BookResponse res = new BookResponse();
    res.setId(book.getId());
    res.setTitle(book.getTitle());
    res.setAuthor(book.getAuthor());
    res.setIsbn(book.getIsbn());
    res.setCategory(book.getCategory());
    res.setPublishedYear(book.getPublishedYear());
    res.setCreatedAt(book.getCreatedAt());
    res.setUpdatedAt(book.getUpdatedAt());
    return res;
}
```

**変更点:**
- `deleted` フィールドは API レスポンスに含めない（論理削除フラグはクライアントに不要）
- `Book` エンティティ（JPA 管理オブジェクト）を直接シリアライズしない（循環参照・Lazy Loading 問題を避けるため）

---

## LoginRequest / LoginResponse

### LoginRequest.java

```java
public class LoginRequest {
    @NotBlank(message = "ユーザー名は必須です。")
    private String username;

    @NotBlank(message = "パスワードは必須です。")
    private String password;
}
```

### LoginResponse.java

```java
public class LoginResponse {
    private String token;       // JWT トークン
    private String displayName; // ヘッダー表示用
}
```

---

## 一覧表

| 移行前 | 移行後 | 役割 |
|---|---|---|
| `BookForm` | `BookRequest` | 登録・更新リクエストのバインド + バリデーション |
| `Book`（モデル直渡し） | `BookResponse` | API レスポンス（エンティティを隠蔽） |
| なし | `LoginRequest` | 認証リクエスト |
| なし | `LoginResponse` | JWT トークンレスポンス |
