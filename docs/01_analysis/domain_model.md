# ドメインモデル

## Book（書籍）

### フィールド一覧

| フィールド名（Java） | DB カラム名 | 型（Java） | 型（DB） | 必須 | 制約・バリデーション |
|---|---|---|---|---|---|
| `id` | `id` | `Long` | `BIGINT AUTO_INCREMENT` | - | 主キー・自動採番 |
| `title` | `title` | `String` | `VARCHAR(100)` | ✅ | 1〜100文字 |
| `author` | `author` | `String` | `VARCHAR(50)` | ✅ | 1〜50文字 |
| `isbn` | `isbn` | `String` | `VARCHAR(13)` | ✅ | 13桁の数字（正規表現 `\d{13}`） |
| `category` | `category` | `String` | `VARCHAR(20)` | ✅ | `NOVEL` / `TECH` / `REFERENCE` / `OTHER` のいずれか |
| `publishedYear` | `published_year` | `Integer` | `INT` | ❌ | 1900 〜 現在年（任意入力） |
| `deleted` | `deleted` | `boolean` | `BOOLEAN` | - | 論理削除フラグ、デフォルト `FALSE` |
| `createdAt` | `created_at` | `LocalDateTime` | `TIMESTAMP` | - | 登録時に `CURRENT_TIMESTAMP` |
| `updatedAt` | `updated_at` | `LocalDateTime` | `TIMESTAMP` | - | 更新時に `CURRENT_TIMESTAMP` |

### バリデーション実装箇所

```java
// BookCreateAction.validateExecute() / BookEditAction.validateExecute()
if (title == null || title.trim().isEmpty())  → "タイトルは必須です。"
if (title.length() > 100)                     → "タイトルは100文字以内で..."
if (author == null || author.trim().isEmpty()) → "著者名は必須です。"
if (author.length() > 50)                     → "著者名は50文字以内で..."
if (isbn == null || isbn.trim().isEmpty())     → "ISBNは必須です。"
if (!isbn.matches("\\d{13}"))                 → "ISBNは13桁の数字で..."
if (category == null || category.isEmpty())   → "カテゴリは必須です。"
if (publishedYear < 1900 || > currentYear)    → "出版年は1900年〜XXXX年..."
```

### カテゴリ定数

| コード | 表示名（JSP） |
|---|---|
| `NOVEL` | 小説 |
| `TECH` | 技術書 |
| `REFERENCE` | 参考書 |
| `OTHER` | その他 |

---

## LoginUser（ログインユーザー）

### フィールド一覧

| フィールド名（Java） | DB カラム名 | 型（Java） | 型（DB） | 必須 | 備考 |
|---|---|---|---|---|---|
| `username` | `username` | `String` | `VARCHAR(50) PRIMARY KEY` | ✅ | ログインID |
| `password` | `password` | `String` | `VARCHAR(100)` | ✅ | **平文保存**（デモ用途） |
| `displayName` | `display_name` | `String` | `VARCHAR(100)` | ✅ | ヘッダーに表示 |

### 認証ロジック

```java
// LoginAction.execute()
LoginUser user = dao.findByUsername(username);
if (user == null || !user.getPassword().equals(password)) {
    → エラー（ユーザー名またはパスワードが正しくありません。）
}
// 成功時: session["loginUser"] = user
```

---

## BookForm（フォームBean）

Struts2 のフォームバインディング用。`BookCreateAction` / `BookEditAction` が保持する。

| フィールド名 | 型 | 対応する Book フィールド |
|---|---|---|
| `id` | `Long` | `id`（編集時のみ使用） |
| `title` | `String` | `title` |
| `author` | `String` | `author` |
| `isbn` | `String` | `isbn` |
| `category` | `String` | `category` |
| `publishedYear` | `Integer` | `publishedYear` |

---

## Phase 4 移行時の考慮点

| 項目 | 現状（Struts） | 移行後（Spring Boot） |
|---|---|---|
| パスワード | 平文 | BCryptPasswordEncoder でハッシュ化 |
| カテゴリ | 文字列コード | `enum Category { NOVEL, TECH, REFERENCE, OTHER }` |
| バリデーション | `validateExecute()` に手動実装 | Bean Validation (`@NotBlank`, `@Size`, `@Pattern`) |
| フォームBean | `BookForm` | `BookRequest` DTO（`@Valid` + `@RequestBody`） |
| セッション認証 | `SessionAware` + HttpSession | JWT + Spring Security（ステートレス） |
