# 画面一覧

## 概要

legacy-app の JSP 画面一覧。共通レイアウトは `header.jsp` / `footer.jsp` のインクルード方式。

---

## 画面一覧表

| JSP パス | 対応 Action | フォームBean | 主な表示項目 |
|---|---|---|---|
| `/WEB-INF/jsp/auth/login.jsp` | LoginAction | username, password | ログインフォーム、エラーメッセージ |
| `/WEB-INF/jsp/book/list.jsp` | BookListAction | searchTitle, searchAuthor, searchCategory | 検索フォーム、書籍テーブル（ID/タイトル/著者/カテゴリ/出版年/操作） |
| `/WEB-INF/jsp/book/detail.jsp` | BookDetailAction | なし（book オブジェクト） | 全フィールド（DL タグ）、編集/削除ボタン |
| `/WEB-INF/jsp/book/form.jsp` | BookCreate/EditAction | BookForm（ネスト） | 入力フォーム全フィールド、バリデーションエラー表示 |
| `/WEB-INF/jsp/common/error.jsp` | BookDetail/Delete/EditAction | なし | actionErrors 表示、一覧へ戻るリンク |
| `/WEB-INF/jsp/common/header.jsp` | 全画面インクルード | なし | ブランドリンク、ナビゲーション（ログイン状態で分岐） |
| `/WEB-INF/jsp/common/footer.jsp` | 全画面インクルード | なし | `</main></body></html>` |

---

## 各画面の詳細

### ログイン画面（login.jsp）

**表示項目:**
- ユーザー名 テキスト入力
- パスワード パスワード入力
- ログイン ボタン（POST /auth/login）
- `<s:actionerror>` エラーメッセージ表示

**特記事項:**
- header/footer を使わず独立した HTML（ログイン専用デザイン）
- ログイン失敗時は username のみ保持（password は Struts2 が空に）

---

### 書籍一覧（list.jsp）

**表示項目:**

| 項目 | 表示形式 |
|---|---|
| 検索フォーム | タイトル・著者（テキスト）、カテゴリ（セレクト）、検索/クリアボタン |
| 新規登録ボタン | ログイン時のみ表示 |
| テーブル | ID / タイトル（詳細リンク）/ 著者 / カテゴリ / 出版年 / 操作 |
| 操作ボタン | 詳細（全員）/ 編集・削除（ログイン時のみ） |

**フォームBean マッピング:**
```
searchTitle   → BookListAction.searchTitle
searchAuthor  → BookListAction.searchAuthor
searchCategory → BookListAction.searchCategory
```

**条件分岐:**
- `${sessionScope.loginUser != null}` で登録/編集/削除ボタン表示切り替え
- `${empty books}` で「見つかりませんでした」表示

---

### 書籍詳細（detail.jsp）

**表示項目:**

| フィールド | 表示 |
|---|---|
| id | テキスト |
| title | テキスト |
| author | テキスト |
| isbn | テキスト |
| category | テキスト（コードそのまま） |
| publishedYear | テキスト |
| createdAt | テキスト |
| updatedAt | テキスト |

**操作:**
- 「一覧へ戻る」リンク（全員）
- 「編集」「削除」ボタン（ログイン時のみ）

---

### 書籍フォーム（form.jsp） — 登録・編集共通

**フォームBean:** `BookForm`（`bookForm.xxx` でネストアクセス）

| フィールド名 | 入力タイプ | バリデーション表示 |
|---|---|---|
| `bookForm.title` | textfield | `<s:fielderror>` |
| `bookForm.author` | textfield | `<s:fielderror>` |
| `bookForm.isbn` | textfield | `<s:fielderror>` |
| `bookForm.category` | select（NOVEL/TECH/REFERENCE/OTHER） | `<s:fielderror>` |
| `bookForm.publishedYear` | textfield | `<s:fielderror>` |

**登録/編集の切り替えロジック:**
```jsp
<c:choose>
  <c:when test="${bookForm.id != null}">
    <!-- 編集: action="edit", hidden id フィールドあり -->
  </c:when>
  <c:otherwise>
    <!-- 登録: action="create" -->
  </c:otherwise>
</c:choose>
```

**特記事項:**
- バリデーションエラー時はフォームの入力値がそのまま保持される（Struts2 の値スタック経由）
- `<s:actionerror>` でアクションレベルエラーも表示

---

### 共通ヘッダー（header.jsp）

**ナビゲーション分岐:**
```
ログイン済み: 書籍一覧 / 新規登録 / ログアウト（表示名）
未ログイン:  書籍一覧 / ログイン
```

**インクルード方法:**
```jsp
<%@ include file="../common/header.jsp" %>  ← 各画面の先頭
<%@ include file="../common/footer.jsp" %>  ← 各画面の末尾
```
