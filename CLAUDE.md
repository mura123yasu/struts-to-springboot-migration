# Claude 作業指示書：Struts → Spring Boot + Vue.js マイグレーション

## 基本ルール（厳守）
- `legacy-app/` は Phase 1 で実装した後は参照専用。Phase 2 以降は変更・削除しない
- `migration-app/` がバックエンド（Spring Boot REST API）の作業場所
- `frontend-app/` がフロントエンド（Vue.js SPA）の作業場所
- 各フェーズ完了時に必ず「完了報告」を出力する
- 判断に迷ったら実装を止めて `docs/questions.md` に質問と現時点の最善案を書き、作業を継続する
- 既存の設定ファイル（.devcontainer/ 等）は変更しない

## イシュー駆動開発ワークフロー（厳守）

すべての作業は GitHub Issue を起点とする。以下の順序で必ず進めること。

### ステップ 1: Issue 作成
作業開始前に Issue を作成し、ラベルとマイルストーンを設定する。

```bash
gh issue create \
  --title "[Phase X] 作業タイトル" \
  --label "phase-X,task" \
  --milestone "Phase X: ..." \
  --body "$(cat <<'BODY'
## 概要
<!-- 何を実装するか -->

## 受け入れ条件
- [ ] 条件1
- [ ] 条件2

## 対応する CLAUDE.md セクション
## Phase X: ...
BODY
)"
```

### ステップ 2: ブランチ作成
Issue 番号を含むブランチ名で作業する。

```bash
git checkout -b issue/<番号>/<短い説明>
# 例: issue/7/struts-project-setup
```

### ステップ 3: 実装・コミット
コミットは論理的にまとまった単位で行う。

### ステップ 4: PR 作成（`Closes #N` 必須）
PR 本文に `Closes #<番号>` を含めないと `pr-autocheck` CI が失敗する。

```bash
gh pr create \
  --title "作業タイトル" \
  --body "Closes #<番号>

## 変更内容
- ..."
```

### ステップ 5: CI 通過 → マージ
- `Linked Issue Check` が通ること
- 変更対象モジュールの CI（ci-legacy / ci-backend / ci-frontend）が通ること
- reviewdog の自動レビューコメントを確認し、重大な指摘は修正すること
- 人間のレビュー承認後にマージ → Issue が自動クローズされることを確認

---

## 自走実行ガイド（devcontainer + `--dangerously-skip-permissions`）

Dev Container は隔離された安全な実行環境であるため、`--dangerously-skip-permissions` を付けて Claude にフェーズ単位で自走させる。
ファイル操作・ビルド・git 操作・GitHub API 呼び出しをすべて無停止で完了する。

### 前提確認（devcontainer 内で実行）

```bash
gh auth status         # GitHub CLI の認証確認
git config user.name   # git ユーザー設定確認
```

### Claude の自走範囲

`--dangerously-skip-permissions` 使用時、Claude は以下を人間の確認なしに実行する：

1. 対象 Phase の既存 Issue を確認（`gh issue list --label "phase-X"`）
2. ブランチ作成（`git checkout -b issue/<最小番号>/<フェーズ説明>`）
3. コード実装・ドキュメント生成
4. ビルド・テスト確認（`mvn compile` / `npm run build` など）
5. コミット・push・PR 作成（複数 Issue を 1 PR でまとめて `Closes #N` を列挙）
6. 完了報告の出力

### バッチ実行時の IDD ルール

1 フェーズに複数 Issue がある場合、次のように処理する：
- そのフェーズで最も小さい Issue 番号を使ってブランチを作成（例: `issue/5/phase1-struts`）
- PR 本文にすべての関連 Issue を列挙（例: `Closes #5, Closes #6, Closes #7, Closes #8, Closes #9, Closes #10`）
- 複数 Issue を 1 PR でまとめてクローズする

> インタラクティブモード（通常の対話セッション）では Issue ごとに個別の PR を作成することを推奨する。

### フェーズ別起動コマンド

#### Phase 1: Struts アプリ実装（Issue #5〜#10）

```bash
claude --dangerously-skip-permissions \
  -p "CLAUDE.md の Phase 1 を実行してください。GitHub Issue #5〜#10 を参照し、IDD ワークフローに従い ブランチ作成・実装・PR 作成まで自走で完了してください。完了したら完了報告を出力してください。"
```

PR マージ前に確認（devcontainer 内）:

```bash
cd legacy-app && mvn -q compile
# 起動確認（任意）: mvn tomcat7:run
```

#### Phase 2: 解析レポート生成（Issue #11）

```bash
claude --dangerously-skip-permissions \
  -p "CLAUDE.md の Phase 2 を実行してください。GitHub Issue #11 を参照し、IDD ワークフローに従い ブランチ作成・ドキュメント生成・PR 作成まで自走で完了してください。完了したら完了報告を出力してください。"
```

> **Phase 2 PR マージ後推奨**: `docs/01_analysis/issues.md` の懸念点を確認し、移行方針の補足を本ファイル（CLAUDE.md）の該当 Phase セクションに追記する。Phase 3 以降の実装精度が向上する。

#### Phase 3: 移行設計書生成（Issue #12）

```bash
claude --dangerously-skip-permissions \
  -p "CLAUDE.md の Phase 3 を実行してください。GitHub Issue #12 を参照し、IDD ワークフローに従い ブランチ作成・設計書生成・PR 作成まで自走で完了してください。完了したら完了報告を出力してください。"
```

#### Phase 4: Spring Boot REST API 実装（Issue #13〜#15）

```bash
claude --dangerously-skip-permissions \
  -p "CLAUDE.md の Phase 4 を実行してください。GitHub Issue #13〜#15 を参照し、IDD ワークフローに従い ブランチ作成・実装・PR 作成まで自走で完了してください。完了したら完了報告を出力してください。"
```

PR マージ前に確認（devcontainer 内）:

```bash
cd migration-app && mvn -q compile && mvn -q test
```

#### Phase 5: Vue.js フロントエンド実装（Issue #16〜#18）

```bash
claude --dangerously-skip-permissions \
  -p "CLAUDE.md の Phase 5 を実行してください。GitHub Issue #16〜#18 を参照し、IDD ワークフローに従い ブランチ作成・実装・PR 作成まで自走で完了してください。完了したら完了報告を出力してください。"
```

PR マージ前に確認（devcontainer 内）:

```bash
cd frontend-app && npm run build && npm test
```

---

## 技術スタック

### 移行元（legacy-app）
- Java 11 ターゲット（コンテナの JDK 21 でビルド可能にする）
- Struts2 (2.5.x) + Convention Plugin
- JSP + JSTL
- H2 Database（インメモリ）
- MyBatis（DAOパターン）
- Maven / Tomcat（mvn tomcat7:run で起動）

### 移行先バックエンド（migration-app）
- Java 21
- Spring Boot 3.3.x
- Spring Web（REST API / `@RestController`）
- Spring Data JPA + H2 Database
- Spring Security + JWT（ステートレス認証）
- Bean Validation
- Lombok
- Maven

### 移行先フロントエンド（frontend-app）
- Node.js 20.x
- Vue.js 3（Composition API / `<script setup>`）
- Vite（ビルドツール）
- Vue Router 4（クライアントサイドルーティング）
- Pinia（状態管理）
- Axios（HTTP クライアント / JWT インターセプター）
- Vitest + Vue Test Utils（ユニットテスト）

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
| password | String | BCrypt ハッシュ済み |
| displayName | String | 表示名 |

### API 認証方式
- JWT（JSON Web Token）を使用
- ログイン成功時に `{ token: "..." }` を返す
- フロントエンドは `Authorization: Bearer <token>` ヘッダーで送信
- Spring Security Filter でリクエストごとに検証（ステートレス）
- トークン有効期限：24時間

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
| action_to_controller.md | Action → RestController マッピング表 |
| form_to_dto.md | ActionForm → Request/Response DTO 変換方針 |
| api_design.md | REST API エンドポイント設計（URL・HTTP メソッド・リクエスト/レスポンス形式） |
| vue_component_design.md | Vue コンポーネント構成・画面遷移・Pinia ストア設計 |
| db_migration.md | MyBatis SQL → JPA 変換方針 |
| security_design.md | セッション管理 → JWT + Spring Security 設計 |
| package_structure.md | migration-app / frontend-app ディレクトリ構成図 |

---

## Phase 4: Spring Boot REST API の実装（migration-app/）

### RestController
- Struts Action と 1:1 対応（対応元をコメントで記載）
- `@GetMapping` / `@PostMapping` / `@PutMapping` / `@DeleteMapping` を明示的に分ける
- バリデーションは `@Valid` + `@RequestBody`
- レスポンスは `ResponseEntity<T>` で統一

### Repository
- 単純 CRUD は `JpaRepository` を継承
- 検索・ソートは `Specification` パターン
- 複雑な SQL は `@Query(nativeQuery=true)` で移植

### セキュリティ
- `SecurityConfig` に JWT フィルター・CORS・CSRF 無効化を集約
- `JwtFilter` でリクエストごとにトークン検証
- パスワードは `BCryptPasswordEncoder`（初期データは変換して登録）
- 認証不要エンドポイント：`POST /api/auth/login`

### CORS 設定
- 開発環境：`http://localhost:5173`（Vite デフォルト）を許可
- 全 API エンドポイントに適用

### 完了条件
- `cd migration-app && mvn compile` が通る
- `mvn test` が通る（最低限 Controller 層の単体テスト）
- `mvn spring-boot:run` で起動できる
- `curl` で全 API エンドポイントの動作確認ができる

---

## Phase 5: Vue.js フロントエンドの実装（frontend-app/）

### プロジェクト構成
```
frontend-app/
  src/
    api/          # Axios インスタンス・API 呼び出し関数
    assets/       # 静的ファイル
    components/
      auth/       # ログイン関連コンポーネント
      book/       # 書籍関連コンポーネント
      common/     # AppLayout, AppHeader, LoadingSpinner 等
    router/       # Vue Router 設定・認証ガード
    stores/       # Pinia ストア（authStore, bookStore）
    types/        # TypeScript 型定義
    views/        # 各画面（ページ）コンポーネント
```

### 画面一覧
| View | パス | 概要 |
|---|---|---|
| LoginView | /login | ログイン画面 |
| BookListView | /books | 書籍一覧・検索 |
| BookDetailView | /books/:id | 書籍詳細 |
| BookFormView | /books/new, /books/:id/edit | 登録・編集フォーム（共通） |

### 認証フロー
- 未ログイン状態で `/books` 系にアクセス → `/login` にリダイレクト
- ログイン成功 → JWT を `authStore` に保存 → `/books` にリダイレクト
- Axios インターセプターで全リクエストに `Authorization` ヘッダーを付与
- トークン期限切れ（401）→ 自動ログアウト

### 完了条件
- `cd frontend-app && npm run build` が通る
- `npm run test` が通る（最低限 View 層のユニットテスト）
- `npm run dev` で起動し、Spring Boot API と連携して全機能が動作する
- ログイン → 一覧 → 登録 → 編集 → 削除 が動作する
- バリデーションエラー時にメッセージが表示される

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
