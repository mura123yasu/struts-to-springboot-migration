# Struts 設定整理

## struts.xml 構成

### グローバル設定

```xml
<constant name="struts.devMode"        value="false"/>
<constant name="struts.i18n.encoding"  value="UTF-8"/>
<constant name="struts.action.extension" value="action,"/>
```

- `action.extension`: `.action` と 拡張子なし（空文字）の両方を受け付ける

### パッケージ構成

```
struts-default（Struts2 内蔵）
  └── default  (namespace="/")        ← ルートへのアクセスを list にリダイレクト
  └── book     (namespace="/book")    ← 書籍 CRUD 5アクション
  └── auth     (namespace="/auth")    ← ログイン・ログアウト 2アクション
```

### ルーティング詳細

```xml
<!-- デフォルト: / → /book/list -->
<package name="default" namespace="/">
  <action name="" class="BookListAction">
    <result>/WEB-INF/jsp/book/list.jsp</result>
  </action>
</package>

<!-- 書籍管理 -->
<package name="book" namespace="/book">
  <!-- list: success のみ -->
  <action name="list" class="BookListAction">
    <result>/WEB-INF/jsp/book/list.jsp</result>
  </action>

  <!-- detail: success / error -->
  <action name="detail" class="BookDetailAction">
    <result>/WEB-INF/jsp/book/detail.jsp</result>
    <result name="error">/WEB-INF/jsp/common/error.jsp</result>
  </action>

  <!-- create: input / success(redirect) -->
  <action name="create" class="BookCreateAction">
    <result name="input">/WEB-INF/jsp/book/form.jsp</result>
    <result name="success" type="redirectAction">
      <param name="actionName">list</param>
      <param name="namespace">/book</param>
    </result>
  </action>

  <!-- edit: input / success(redirect) / error -->
  <action name="edit" class="BookEditAction">
    <result name="input">/WEB-INF/jsp/book/form.jsp</result>
    <result name="success" type="redirectAction">...</result>
    <result name="error">/WEB-INF/jsp/common/error.jsp</result>
  </action>

  <!-- delete: success(redirect) / error -->
  <action name="delete" class="BookDeleteAction">
    <result name="success" type="redirectAction">...</result>
    <result name="error">/WEB-INF/jsp/common/error.jsp</result>
  </action>
</package>

<!-- 認証 -->
<package name="auth" namespace="/auth">
  <!-- login: input / success(redirect) -->
  <action name="login" class="LoginAction">
    <result name="input">/WEB-INF/jsp/auth/login.jsp</result>
    <result name="success" type="redirectAction">
      <param name="actionName">list</param>
      <param name="namespace">/book</param>
    </result>
  </action>

  <!-- logout: success(redirect) -->
  <action name="logout" class="LogoutAction">
    <result name="success" type="redirectAction">
      <param name="actionName">login</param>
      <param name="namespace">/auth</param>
    </result>
  </action>
</package>
```

---

## バリデーション実装

### 方式: validateXxx() メソッド

Struts2 の `validateXxx()` 規約を使用。`validate()` ではなく `validateExecute()` を定義することで、`execute()` 呼び出し時のみバリデーションが走り、`input()` 時はスキップされる。

```java
// BookCreateAction / BookEditAction
public void validateExecute() {
    // タイトル: 必須 + 最大100文字
    // 著者: 必須 + 最大50文字
    // ISBN: 必須 + 13桁数字
    // カテゴリ: 必須
    // 出版年: 1900〜現在年（任意）
}
```

### バリデーション XML は不使用

XML ベースのバリデーション（`BookCreateAction-validation.xml` 等）は実装していない。すべて Java コードで記述。

### エラー表示（JSP）

```jsp
<!-- フィールドエラー -->
<s:fielderror fieldName="bookForm.title" cssClass="error-message" theme="simple"/>

<!-- アクションエラー（認証失敗等） -->
<s:actionerror cssClass="alert-error" theme="simple"/>
```

---

## インターセプター構成

`struts-default` パッケージのデフォルトインターセプタースタック（`defaultStack`）を継承。
認証チェックの専用インターセプターは **未実装**。未ログイン状態でも書籍一覧・詳細は閲覧可能。

---

## Convention Plugin

依存には含まれているが、アノテーションベースのルーティングは不使用。
すべてのルートを `struts.xml` に明示定義しているため、Convention Plugin の自動スキャンは影響しない。

---

## web.xml 設定

```xml
<filter>
  <filter-name>struts2</filter-name>
  <filter-class>org.apache.struts2.dispatcher.filter.StrutsPrepareAndExecuteFilter</filter-class>
</filter>
<filter-mapping>
  <filter-name>struts2</filter-name>
  <url-pattern>/*</url-pattern>  <!-- 全URLをStruts2が処理 -->
</filter-mapping>
```

`/*` で全リクエストをフィルターしているため、静的ファイルも Struts2 を経由する点に注意（本アプリは静的ファイルなし）。
