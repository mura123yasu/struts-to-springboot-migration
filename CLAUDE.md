# Claude 作業指示書：Struts → Spring Boot マイグレーション

## 基本ルール（厳守）
- `legacy-app/` は Phase 1 で実装した後は参照専用。Phase 2 以降は変更・削除しない
- `migration-app/` が移行先の作業場所
- 各フェーズ完了時に必ず「完了報告」を出力する
- 判断に迷ったら実装を止めて `docs/questions.md` に質問と現時点の最善案を書き、作業を継続する
- 既存の設定ファイル（.devcontainer/ 等）は変更しない

## 技術スタック

### 移行元（legacy-app）
- Java 11 ターゲット（コンテナの JDK 21 でビルド可能にする）
- Struts2 (2.5.x) + Convention Plugin
- JSP + JSTL
- H2 Database（インメモリ）
- MyBatis（DAOパターン）
- Maven / Tomcat（mvn tomcat7:run で起動）

### 移行先（migration-app）
- Java 21
- Spring Boot 3.3.x
- Spring MVC + Thymeleaf（Layout Dialect 使用）
- Spring Data JPA + H2 Database
- Spring Security（ログイン認証）
- Bean Validation
- Lombok
- Maven

## ドメインモデル

### Book（書籍）
| フィールド | 型 | 備考 |
|---|---|---|
| id | Long | 主キー・自動採番 |
| title | String | 必須・100文字以内 |
| author | String | 必須・50文字以内 |
| isbn | String | 必須・ISBN-13形式 |
| category | String | NOVEL/TECH/REFERENCE/OTHER |
| publishedYear | Integer | 1900〜現在年 |
| deleted | boolean | 論理削除フラグ |
| createdAt | LocalDateTime | 登録日時 |
| updatedAt | LocalDateTime | 更新日時 |

### LoginUser（ログインユーザー）
| フィールド | 型 | 備考 |
|---|---|---|
| username | String | ログインID |
| password | String | パスワード |
| displayName | String | 表示名 |

---

## Phase 1: Struts アプリの実装（legacy-app/）

### Struts Action 一覧
| Action クラス | URL | メソッド | 概要 |
|---|---|---|---|
| BookListAction | /book/list | execute | 書籍一覧・検索 |
| BookDetailAction | /book/detail | execute | 書籍詳細 |
| BookCreateAction | /book/create | input/execute | 書籍登録（GET/POST） |
| BookEditAction | /book/edit | input/execute | 書籍編集（GET/POST） |
| BookDeleteAction | /book/delete | execute | 書籍削除（POST） |
| LoginAction | /auth/login | input/execute | ログイン（GET/POST） |
| LogoutAction | /auth/logout | execute | ログアウト |

### 画面一覧（JSP）
| JSP | 対応 Action | 概要 |
|---|---|---|
| book/list.jsp | BookListAction | 書籍一覧・検索フォーム |
| book/detail.jsp | BookDetailAction | 書籍詳細 |
| book/form.jsp | BookCreate/EditAction | 登録・編集フォーム（共通） |
| auth/login.jsp | LoginAction | ログイン画面 |
| common/layout.jsp | 全画面 | ヘッダー・フッター |
| common/error.jsp | - | エラー画面 |

### データ初期化
起動時に H2 へ投入：
- テストユーザー：admin / password
- サンプル書籍：各カテゴリ 2〜3 件ずつ（計 10 件程度）

### 完了条件
- `cd legacy-app && mvn compile` が通る
- `mvn tomcat7:run` で起動できる
- ログイン → 一覧 → 登録 → 編集 → 削除 が動作する
- バリデーションエラー時に入力値が保持される

---

## Phase 2: 解析レポート生成（docs/01_analysis/）
| ファイル | 内容 |
|---|---|
| action_list.md | Action一覧（クラス・URL・フォワード先） |
| screen_list.md | 画面一覧（JSP・フォームBean・表示項目） |
| domain_model.md | ドメインモデル（フィールド・型・バリデーション） |
| db_access.md | DBアクセスパターン（SQL一覧・DAO構成） |
| struts_config.md | struts.xml・validation の整理 |
| dependencies.md | pom.xml 依存ライブラリ一覧 |
| issues.md | 移行時の懸念点・人間確認が必要な箇所 |

---

## Phase 3: 移行設計書生成（docs/02_design/）
| ファイル | 内容 |
|---|---|
| action_to_controller.md | Action → Controller マッピング表 |
| form_to_dto.md | ActionForm → DTO 変換方針 |
| jsp_to_thymeleaf.md | JSP → Thymeleaf 変換方針 |
| db_migration.md | MyBatis SQL → JPA 変換方針 |
| security_design.md | セッション管理 → Spring Security 設計 |
| package_structure.md | migration-app パッケージ構成図 |

---

## Phase 4: Spring Boot アプリの実装（migration-app/）

### Controller
- Struts Action と 1:1 対応（対応元をコメントで記載）
- `@GetMapping` / `@PostMapping` を明示的に分ける
- バリデーションは `@Valid` + `BindingResult`

### Repository
- 単純 CRUD は `JpaRepository` を継承
- 検索・ソートは `Specification` パターン
- 複雑な SQL は `@Query(nativeQuery=true)` で移植

### セキュリティ
- `SecurityConfig` に CSRF・ログイン・ログアウトを集約
- パスワードは `BCryptPasswordEncoder`（初期データは変換して登録）
- ログイン後リダイレクト先は `/book/list`

### Thymeleaf
- `common/layout.html` を Layout Dialect で共通化
- `<s:form>` → `th:action` + `th:object` + `th:field`
- `<s:fielderror>` → `th:errors`

### 完了条件
- `cd migration-app && mvn compile` が通る
- `mvn test` が通る（最低限 Controller 層の単体テスト）
- `mvn spring-boot:run` で起動できる
- ログイン → 一覧 → 登録 → 編集 → 削除 が動作する

---

## 各フェーズ完了報告フォーマット
```
## Phase X 完了報告
### 完了した作業
### 生成したファイル一覧
### 発見した課題・未解決事項（なければ「なし」）
### 人間レビューが必要な箇所（なければ「なし」）
### 次のステップ
```
