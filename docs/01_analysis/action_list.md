# Action 一覧

## 概要

legacy-app に実装された Struts2 Action クラスの一覧。
Convention Plugin は不使用。`struts.xml` に全ルーティングを明示的に定義している。

---

## Action 一覧表

| クラス名 | ネームスペース | URL | メソッド | 役割 | フォワード先 |
|---|---|---|---|---|---|
| `BookListAction` | `/book` | `/book/list` | `execute` | 書籍全件取得・検索 | `/WEB-INF/jsp/book/list.jsp` |
| `BookDetailAction` | `/book` | `/book/detail?id=N` | `execute` | 書籍詳細取得 | `/WEB-INF/jsp/book/detail.jsp` (success) / `error.jsp` (error) |
| `BookCreateAction` | `/book` | `/book/create` | `input` / `execute` | 書籍登録フォーム表示・登録実行 | `form.jsp` (input) / redirect list (success) |
| `BookEditAction` | `/book` | `/book/edit?id=N` | `input` / `execute` | 書籍編集フォーム表示・更新実行 | `form.jsp` (input) / redirect list (success) / `error.jsp` (error) |
| `BookDeleteAction` | `/book` | `/book/delete` | `execute` | 書籍論理削除（POST） | redirect list (success) / `error.jsp` (error) |
| `LoginAction` | `/auth` | `/auth/login` | `input` / `execute` | ログインフォーム表示・認証 | `login.jsp` (input) / redirect list (success) |
| `LogoutAction` | `/auth` | `/auth/logout` | `execute` | セッション破棄 | redirect `/auth/login` |

---

## 各 Action の詳細

### BookListAction

```
クラス: com.example.legacy.action.BookListAction
継承: ActionSupport
フィールド:
  - List<Book> books          ← JSP に渡す書籍リスト
  - String searchTitle        ← 検索条件（タイトル部分一致）
  - String searchAuthor       ← 検索条件（著者部分一致）
  - String searchCategory     ← 検索条件（カテゴリ完全一致）
処理:
  - 検索条件がすべて空 → BookDao.findAll()
  - いずれか非空     → BookDao.search(title, author, category)
```

### BookDetailAction

```
クラス: com.example.legacy.action.BookDetailAction
継承: ActionSupport
フィールド:
  - Long id    ← リクエストパラメータ
  - Book book  ← JSP に渡す書籍
処理:
  - BookDao.findById(id) → null なら addActionError → ERROR
```

### BookCreateAction

```
クラス: com.example.legacy.action.BookCreateAction
継承: ActionSupport
フィールド:
  - BookForm bookForm ← フォームBean（ネスト）
処理:
  - input()    → INPUT を返す（フォーム表示）
  - execute()  → validateExecute() 後にエラーなければ INSERT → SUCCESS
バリデーション: validateExecute() で実施（execute 時のみ）
```

### BookEditAction

```
クラス: com.example.legacy.action.BookEditAction
継承: ActionSupport
フィールド:
  - Long id
  - BookForm bookForm
処理:
  - input()    → DB から既存値を BookForm に詰めて INPUT を返す
  - execute()  → validateExecute() 後に UPDATE → SUCCESS
バリデーション: validateExecute() で実施（execute 時のみ）
```

### BookDeleteAction

```
クラス: com.example.legacy.action.BookDeleteAction
継承: ActionSupport
フィールド:
  - Long id
処理:
  - execute() → id null チェック → BookDao.delete(id)（論理削除）
```

### LoginAction

```
クラス: com.example.legacy.action.LoginAction
継承: ActionSupport
実装: SessionAware
フィールド:
  - String username / password
処理:
  - input()    → INPUT
  - execute()  → UserDao.findByUsername(username) → password 平文照合
               → 一致: session["loginUser"] = user → SUCCESS
               → 不一致: addActionError → INPUT
```

### LogoutAction

```
クラス: com.example.legacy.action.LogoutAction
継承: ActionSupport
実装: SessionAware
処理:
  - execute() → session.clear() → SUCCESS
```

---

## struts.xml ルーティング抜粋

```xml
<package name="book" namespace="/book" extends="struts-default">
  <action name="list"   class="...BookListAction">   → list.jsp         </action>
  <action name="detail" class="...BookDetailAction"> → detail.jsp        </action>
  <action name="create" class="...BookCreateAction"> → form.jsp (input)  </action>
  <action name="edit"   class="...BookEditAction">   → form.jsp (input)  </action>
  <action name="delete" class="...BookDeleteAction"> → redirect list     </action>
</package>
<package name="auth" namespace="/auth" extends="struts-default">
  <action name="login"  class="...LoginAction">      → login.jsp (input) </action>
  <action name="logout" class="...LogoutAction">     → redirect login    </action>
</package>
```
