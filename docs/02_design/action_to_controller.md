# Action → RestController マッピング表

## 対応方針

- Struts2 Action 1クラス = Spring Boot RestController 1クラス（原則）
- `input` / `execute` の2メソッド構造 → `GET` / `POST`（または `PUT` / `DELETE`）に分割
- セッション認証 → JWT ベアラートークン認証に変更
- フォワード（JSP レンダリング）→ JSON レスポンスに変更

---

## マッピング表

| Struts2 Action | メソッド | URL | → | RestController | HTTPメソッド | エンドポイント |
|---|---|---|---|---|---|---|
| `BookListAction` | `execute` | `/book/list` | → | `BookController` | GET | `/api/books` |
| `BookDetailAction` | `execute` | `/book/detail?id=N` | → | `BookController` | GET | `/api/books/{id}` |
| `BookCreateAction` | `input` | GET `/book/create` | → | *(フロントエンド側)* | - | - |
| `BookCreateAction` | `execute` | POST `/book/create` | → | `BookController` | POST | `/api/books` |
| `BookEditAction` | `input` | GET `/book/edit?id=N` | → | `BookController` | GET | `/api/books/{id}` |
| `BookEditAction` | `execute` | POST `/book/edit` | → | `BookController` | PUT | `/api/books/{id}` |
| `BookDeleteAction` | `execute` | POST `/book/delete` | → | `BookController` | DELETE | `/api/books/{id}` |
| `LoginAction` | `input` | GET `/auth/login` | → | *(フロントエンド側)* | - | - |
| `LoginAction` | `execute` | POST `/auth/login` | → | `AuthController` | POST | `/api/auth/login` |
| `LogoutAction` | `execute` | `/auth/logout` | → | *(フロントエンド側)* | - | - |

> **注:** ログアウトはステートレス JWT のためサーバー側 API は不要。Vue.js の `authStore` がトークンを破棄するだけ。

---

## 詳細マッピング

### AuthController

```java
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    // POST /api/auth/login
    // 移行元: LoginAction.execute()
    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        // UserDetailsService で認証 → JwtUtil でトークン生成
        // 成功: 200 + { token: "..." }
        // 失敗: 401 + { message: "認証失敗" }
    }
}
```

### BookController

```java
@RestController
@RequestMapping("/api/books")
public class BookController {

    // GET /api/books?title=&author=&category=
    // 移行元: BookListAction.execute()
    @GetMapping
    public ResponseEntity<List<BookResponse>> list(
        @RequestParam(required=false) String title,
        @RequestParam(required=false) String author,
        @RequestParam(required=false) String category) { ... }

    // GET /api/books/{id}
    // 移行元: BookDetailAction.execute() / BookEditAction.input()
    @GetMapping("/{id}")
    public ResponseEntity<BookResponse> get(@PathVariable Long id) { ... }

    // POST /api/books
    // 移行元: BookCreateAction.execute()
    @PostMapping
    public ResponseEntity<BookResponse> create(@Valid @RequestBody BookRequest request) { ... }

    // PUT /api/books/{id}
    // 移行元: BookEditAction.execute()
    @PutMapping("/{id}")
    public ResponseEntity<BookResponse> update(
        @PathVariable Long id,
        @Valid @RequestBody BookRequest request) { ... }

    // DELETE /api/books/{id}
    // 移行元: BookDeleteAction.execute()
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) { ... }
}
```

---

## 変更点のまとめ

| 観点 | Struts2（移行元） | Spring Boot（移行後） |
|---|---|---|
| URL 設計 | `/book/list`, `/book/detail?id=N` | `/api/books`, `/api/books/{id}` (RESTful) |
| HTTP メソッド | GET/POST のみ | GET/POST/PUT/DELETE を使い分け |
| レスポンス形式 | JSP レンダリング（HTML） | JSON (`ResponseEntity<T>`) |
| 認証方式 | HttpSession | JWT Bearer Token |
| バリデーション | `validateExecute()` 手動実装 | Bean Validation (`@Valid`) |
| エラー処理 | `addActionError` + JSP 表示 | `@RestControllerAdvice` + JSON |
| ログアウト | サーバー側セッション破棄 | クライアント側トークン破棄のみ |
