# 移行時の懸念点・人間確認が必要な箇所

## 優先度凡例

| マーク | 意味 |
|---|---|
| 🔴 高 | セキュリティリスク or 設計変更必須 |
| 🟡 中 | 動作に影響する可能性がある |
| 🟢 低 | デモ範囲で許容できるが記録すべき点 |

---

## セキュリティ

### 🔴 パスワード平文保存

**現状:** `data.sql` で `password = 'password'` と平文でDBに格納。`LoginAction` でも平文照合。

**Phase 4 対応:** `BCryptPasswordEncoder` でハッシュ化し、`DataInitializer` で `$2a$...` 形式で投入する。`UserDetailsService` で `passwordEncoder.matches()` を使用。

**人間確認:** デモ用の admin ユーザーの初期パスワードを `password` のままにしてよいか。

---

### 🔴 認証インターセプター未実装

**現状:** 未ログインでも `/book/list`、`/book/detail` に直接アクセス可能。JSP 側でボタンを非表示にしているだけで、URL 直打ちによる操作は防げていない。

**Phase 4 対応:** Spring Security の `SecurityConfig` で `/api/auth/login` 以外を全認証必須にする。

---

### 🟡 CSRF 対策なし

**現状:** 削除フォーム（POST /book/delete）に CSRF トークンがない。Struts2 のデフォルトトークン機構も未使用。

**Phase 4 対応:** Spring Security の CSRF 保護は REST API では `disabled`（JWT + SameSite Cookie 不使用のため）。Vue.js 側は `Authorization: Bearer` ヘッダーで送信するため CSRF リスクは低減される。

---

### 🟢 XSS（JSP の EL 式直出力）

**現状:** `list.jsp` / `detail.jsp` で `${book.title}` 等を `<c:out>` なしに直接出力。タイトルに `<script>` が含まれると XSS になる。

**Phase 4/5 対応:** Vue.js の `{{ }}` バインディングはデフォルトでエスケープ済みのため、フロント移行後は自動解消。

---

## データ・DB 互換性

### 🟡 H2 MySQL 互換モード依存

**現状:** `jdbc:h2:mem:...;MODE=MySQL` を指定。`CONCAT('%', ?, '%')` や `ON UPDATE CURRENT_TIMESTAMP` を使用。

**影響:** H2 標準モードでは `CONCAT` の挙動が異なる場合があり、テスト環境での差異が出る可能性。

**Phase 4 対応:** JPA の `Specification` パターンに書き換えるため `CONCAT` 構文は不要になる。`updated_at` の自動更新は JPA の `@PreUpdate` で代替。

---

### 🟢 updated_at の自動更新

**現状:** `schema.sql` に `ON UPDATE CURRENT_TIMESTAMP` を記述しているが、INSERT/UPDATE の SQL でも明示的に `CURRENT_TIMESTAMP` をセットしているため実害なし。ただし H2 で `ON UPDATE` が正しく動作しているかは未確認。

**Phase 4 対応:** `@UpdateTimestamp`（Hibernate）または `@PreUpdate` で管理。

---

## アーキテクチャ

### 🟡 SqlSession の Action 直接管理

**現状:** 各 Action クラスが `SqlSessionFactory` から `SqlSession` を `try-with-resources` で開閉。共通処理が Action ごとに重複。

**Phase 4 対応:** `@Service` + `@Transactional` でトランザクション管理を Spring に委譲。

---

### 🟢 バリデーションロジックの重複

**現状:** `BookCreateAction.validateExecute()` と `BookEditAction.validateExecute()` はほぼ同一（タイトル・著者・ISBN・カテゴリ・出版年の検証）。

**Phase 4 対応:** `BookRequest` DTO に Bean Validation アノテーションを付けることで一元化。

---

### 🟢 layout.jsp の残留

**現状:** `header.jsp` / `footer.jsp` インクルード方式に変更後、`layout.jsp` が不要ファイルとして残っている。Phase 2 解析時点では削除対象。

---

## フロントエンド移行

### 🟡 サーバーサイドレンダリング → SPA 移行

**現状:** JSP でサーバーサイドレンダリング。認証状態を `sessionScope.loginUser` でテンプレートに直接渡す。

**Phase 5 対応:**
- 認証状態管理は Pinia の `authStore` に移行（JWT をローカルストレージまたはメモリに保持）
- `sessionScope` は廃止し、全状態をクライアントサイドで管理
- ページ遷移は Vue Router のクライアントサイドルーティングに変更

---

### 🟢 カテゴリの表示名変換

**現状:** DB には `NOVEL` / `TECH` / `REFERENCE` / `OTHER` と英字コードで保存し、JSP の select タグで日本語表示（`NOVEL → 小説` 等）。API レスポンスでどちらを返すか要検討。

**Phase 4/5 対応方針（案）:** API は英字コードを返し、Vue.js 側で表示名に変換する定数ファイルを持つ。

---

## 人間確認が必要な箇所まとめ

| # | 項目 | 確認内容 |
|---|---|---|
| 1 | 初期パスワード | admin の初期パスワードを `password` のままにしてよいか |
| 2 | カテゴリ値の API 設計 | API が英字コードを返すか、日本語名を返すか |
| 3 | 認証不要エンドポイントの範囲 | 書籍一覧・詳細を未認証でも参照できる仕様にするか |
| 4 | layout.jsp | 削除してよいか（使われていない） |
