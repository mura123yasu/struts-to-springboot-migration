# REST API エンドポイント設計

## 基本方針

- ベース URL: `/api`
- 認証: `Authorization: Bearer <JWT>` ヘッダー（`POST /api/auth/login` のみ不要）
- レスポンス形式: JSON（`Content-Type: application/json`）
- エラー形式: `{ "message": "エラー内容" }` を統一形式で返す

---

## エンドポイント一覧

### 認証

| メソッド | パス | 認証 | 概要 |
|---|---|---|---|
| POST | `/api/auth/login` | 不要 | ログイン・JWT 発行 |

### 書籍

| メソッド | パス | 認証 | 概要 |
|---|---|---|---|
| GET | `/api/books` | 必要 | 書籍一覧・検索 |
| GET | `/api/books/{id}` | 必要 | 書籍詳細 |
| POST | `/api/books` | 必要 | 書籍登録 |
| PUT | `/api/books/{id}` | 必要 | 書籍更新 |
| DELETE | `/api/books/{id}` | 必要 | 書籍削除（論理削除） |

---

## 詳細仕様

### POST /api/auth/login

**リクエスト:**
```json
{
  "username": "admin",
  "password": "password"
}
```

**レスポンス (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "displayName": "管理者"
}
```

**エラー (401 Unauthorized):**
```json
{ "message": "ユーザー名またはパスワードが正しくありません。" }
```

**curl サンプル:**
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}'
```

---

### GET /api/books

検索条件はすべて任意。複数指定時は AND 条件。

**クエリパラメータ:**

| パラメータ | 型 | 必須 | 説明 |
|---|---|---|---|
| `title` | string | 任意 | タイトル部分一致 |
| `author` | string | 任意 | 著者部分一致 |
| `category` | string | 任意 | カテゴリ完全一致（NOVEL/TECH/REFERENCE/OTHER） |

**レスポンス (200 OK):**
```json
[
  {
    "id": 1,
    "title": "吾輩は猫である",
    "author": "夏目漱石",
    "isbn": "9784101010014",
    "category": "NOVEL",
    "publishedYear": 1905,
    "createdAt": "2026-05-24T00:00:00",
    "updatedAt": "2026-05-24T00:00:00"
  }
]
```

**curl サンプル:**
```bash
TOKEN="eyJhbGciOiJIUzI1NiJ9..."

# 全件取得
curl http://localhost:8080/api/books \
  -H "Authorization: Bearer $TOKEN"

# タイトル検索
curl "http://localhost:8080/api/books?title=猫" \
  -H "Authorization: Bearer $TOKEN"

# カテゴリ絞り込み
curl "http://localhost:8080/api/books?category=TECH" \
  -H "Authorization: Bearer $TOKEN"
```

---

### GET /api/books/{id}

**パスパラメータ:**

| パラメータ | 型 | 説明 |
|---|---|---|
| `id` | Long | 書籍ID |

**レスポンス (200 OK):**
```json
{
  "id": 1,
  "title": "吾輩は猫である",
  "author": "夏目漱石",
  "isbn": "9784101010014",
  "category": "NOVEL",
  "publishedYear": 1905,
  "createdAt": "2026-05-24T00:00:00",
  "updatedAt": "2026-05-24T00:00:00"
}
```

**エラー (404 Not Found):**
```json
{ "message": "書籍が見つかりませんでした。(id=999)" }
```

**curl サンプル:**
```bash
curl http://localhost:8080/api/books/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

### POST /api/books

**リクエスト:**
```json
{
  "title": "テスト書籍",
  "author": "テスト著者",
  "isbn": "9784000000001",
  "category": "TECH",
  "publishedYear": 2024
}
```

**レスポンス (201 Created):**
```json
{
  "id": 11,
  "title": "テスト書籍",
  "author": "テスト著者",
  "isbn": "9784000000001",
  "category": "TECH",
  "publishedYear": 2024,
  "createdAt": "2026-05-24T12:00:00",
  "updatedAt": "2026-05-24T12:00:00"
}
```

**バリデーションエラー (400 Bad Request):**
```json
{
  "message": "入力値が不正です。",
  "errors": {
    "title": "タイトルは必須です。",
    "isbn": "ISBNは13桁の数字で入力してください。"
  }
}
```

**curl サンプル:**
```bash
curl -X POST http://localhost:8080/api/books \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"テスト","author":"著者","isbn":"9784000000001","category":"TECH","publishedYear":2024}'
```

---

### PUT /api/books/{id}

**リクエスト:** POST /api/books と同形式

**レスポンス (200 OK):** 更新後の BookResponse

**エラー:**
- 400: バリデーションエラー
- 404: 書籍が存在しない

**curl サンプル:**
```bash
curl -X PUT http://localhost:8080/api/books/11 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"更新後タイトル","author":"著者","isbn":"9784000000001","category":"TECH"}'
```

---

### DELETE /api/books/{id}

**レスポンス (204 No Content):** ボディなし（論理削除）

**エラー (404 Not Found):**
```json
{ "message": "書籍が見つかりませんでした。(id=999)" }
```

**curl サンプル:**
```bash
curl -X DELETE http://localhost:8080/api/books/11 \
  -H "Authorization: Bearer $TOKEN"
```

---

## エラーレスポンス統一形式

`GlobalExceptionHandler`（`@RestControllerAdvice`）で統一:

| HTTP ステータス | 発生ケース | レスポンス形式 |
|---|---|---|
| 400 | Bean Validation 失敗 | `{ "message": "...", "errors": { "field": "..." } }` |
| 401 | JWT 未提供 / 無効 / 期限切れ | `{ "message": "認証が必要です。" }` |
| 404 | 書籍が存在しない | `{ "message": "書籍が見つかりませんでした。(id=N)" }` |
| 500 | 予期しないサーバーエラー | `{ "message": "サーバーエラーが発生しました。" }` |

---

## JWT 仕様

| 項目 | 値 |
|---|---|
| アルゴリズム | HS256 |
| 有効期限 | 24時間 |
| ペイロード | `sub`（username）、`exp`（有効期限） |
| 送信方法 | `Authorization: Bearer <token>` ヘッダー |
