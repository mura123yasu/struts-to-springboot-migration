# 週次作業計画書

Claude に 1 週間単位で作業を委譲することを前提に、フェーズを分割しています。
各 Week は独立した PR として管理し、main へのマージ後に次 Week を開始します。

---

## Week 1（完了済み）: Phase 0 — プロジェクト枠組み整備

**目標**: 動くコードを一切書かず、ディレクトリ・設定ファイル・仕様書だけを用意する

| 作業項目 | 内容 |
|---|---|
| ディレクトリ骨格 | legacy-app / migration-app / frontend-app / docs の各パッケージを `.gitkeep` 付きで作成 |
| Dev Container 設定 | `.devcontainer/devcontainer.json`, `.devcontainer/Dockerfile` |
| CLAUDE.md 配置 | Phase 1〜5 の仕様書として配置 |
| 補助ファイル | `.gitignore`, `README.md` |

**完了条件**: `git clone` → Dev Container 起動でディレクトリ構造が確認できること

---

## Week 2: Phase 1a — Struts レガシーアプリ基盤層

**目標**: Struts アプリのデータアクセス層・設定層を完成させる

| 作業項目 | 内容 |
|---|---|
| pom.xml | Struts2 / MyBatis / H2 / JSTL の依存関係 |
| web.xml | Struts2 フィルター設定 |
| struts.xml | アクション定義（全 7 アクション分のルーティング） |
| H2 スキーマ | `schema.sql`（books, users テーブル） |
| 初期データ | `data.sql`（admin ユーザー, サンプル書籍 10 件） |
| Model クラス | `Book.java`, `LoginUser.java` |
| DAO インターフェース + Mapper XML | `BookDao.java`, `UserDao.java` + 各 Mapper（CRUD + 検索） |
| MyBatis 設定 | `mybatis-config.xml`, `SqlSessionFactory` Bean |

**完了条件**: `cd legacy-app && mvn compile` が通ること

---

## Week 3: Phase 1b — Struts レガシーアプリ UI 層

**目標**: Struts アプリの Action・JSP を実装し、ブラウザで全機能を動作させる

| 作業項目 | 内容 |
|---|---|
| Action クラス | `BookListAction`, `BookDetailAction`, `BookCreateAction`, `BookEditAction`, `BookDeleteAction`, `LoginAction`, `LogoutAction` |
| JSP ファイル | `book/list.jsp`, `book/detail.jsp`, `book/form.jsp`, `auth/login.jsp`, `common/layout.jsp`, `common/error.jsp` |
| バリデーション | `-validation.xml` ファイル（Book の各フィールド） |
| 起動検証 | `mvn tomcat7:run` で全画面を手動確認 |

**完了条件**:
- `mvn tomcat7:run` で起動できること
- ログイン → 一覧 → 登録 → 編集 → 削除 が動作すること
- バリデーションエラー時に入力値が保持されること

---

## Week 4: Phase 2 — 解析レポート生成

**目標**: legacy-app のソースコードを全解析し、移行の入力情報を文書化する

| 出力ファイル | 内容 |
|---|---|
| `docs/01_analysis/action_list.md` | Action 一覧（クラス・URL・フォワード先） |
| `docs/01_analysis/screen_list.md` | 画面一覧（JSP・フォーム Bean・表示項目） |
| `docs/01_analysis/domain_model.md` | ドメインモデル（フィールド・型・バリデーションルール） |
| `docs/01_analysis/db_access.md` | DB アクセスパターン（SQL 一覧・DAO 構成） |
| `docs/01_analysis/struts_config.md` | struts.xml・validation の整理 |
| `docs/01_analysis/dependencies.md` | pom.xml 依存ライブラリ一覧と移行時の対応方針 |
| `docs/01_analysis/issues.md` | 移行時の懸念点・人間確認が必要な箇所 |

**完了条件**: 7 ファイルがすべて揃い、Phase 3 の設計書作成に必要な情報が網羅されていること

---

## Week 5: Phase 3 — 移行設計書生成

**目標**: Phase 4・5 の実装に直接使える設計書を作成する

| 出力ファイル | 内容 |
|---|---|
| `docs/02_design/action_to_controller.md` | Action → RestController マッピング表（HTTP メソッド・URL・レスポンス形式） |
| `docs/02_design/form_to_dto.md` | ActionForm → Request/Response DTO 変換方針 |
| `docs/02_design/api_design.md` | REST API エンドポイント全仕様（OpenAPI 風・curl サンプル付き） |
| `docs/02_design/vue_component_design.md` | Vue コンポーネント構成・画面遷移図・Pinia ストア設計 |
| `docs/02_design/db_migration.md` | MyBatis SQL → JPA 変換方針（Specification パターン含む） |
| `docs/02_design/security_design.md` | セッション管理 → JWT + Spring Security 設計（フロー図付き） |
| `docs/02_design/package_structure.md` | migration-app / frontend-app ディレクトリ構成図 |

**完了条件**: 7 ファイルがすべて揃い、Week 6 以降の実装者（Claude）が設計書だけを読んで実装できる状態であること

---

## Week 6: Phase 4a — Spring Boot REST API 基盤層

**目標**: Spring Boot プロジェクトの土台と認証・DB 層を完成させる

| 作業項目 | 内容 |
|---|---|
| pom.xml | Spring Boot 3.3.x / Spring Security / Spring Data JPA / H2 / Lombok / jjwt 依存関係 |
| application.yml | H2 設定・JWT シークレット・CORS 許可オリジン |
| Entity クラス | `Book.java`, `User.java`（JPA アノテーション・Lombok） |
| Repository | `BookRepository.java`（JpaRepository + Specification）, `UserRepository.java` |
| JWT 関連 | `JwtUtil.java`（トークン生成・検証）, `JwtFilter.java`（Spring Security フィルター） |
| セキュリティ設定 | `SecurityConfig.java`（JWT フィルター登録・CORS・CSRF 無効化） |
| 初期データ | `DataInitializer.java`（CommandLineRunner で admin ユーザー + サンプル書籍投入） |

**完了条件**: `cd migration-app && mvn compile` が通ること

---

## Week 7: Phase 4b — Spring Boot REST API ビジネス層

**目標**: 全 API エンドポイントを実装し、テストで品質を担保する

| 作業項目 | 内容 |
|---|---|
| DTO クラス | `BookRequest.java`, `BookResponse.java`, `LoginRequest.java`, `LoginResponse.java`（Bean Validation 付き） |
| Service クラス | `BookService.java`（CRUD + 検索 + 論理削除）, `UserService.java`（UserDetailsService 実装） |
| RestController | `AuthController.java`（POST /api/auth/login）, `BookController.java`（GET/POST/PUT/DELETE /api/books/**） |
| 例外ハンドリング | `GlobalExceptionHandler.java`（404 / 400 / 401 のレスポンス統一） |
| ユニットテスト | `BookControllerTest.java`, `BookServiceTest.java` |
| 動作確認 | curl で全エンドポイントを確認するスクリプト `docs/03_migration_log/api_test.sh` |

**完了条件**:
- `mvn test` が通ること
- `mvn spring-boot:run` で起動し、curl で全 API が期待通り動作すること

---

## Week 8: Phase 5a — Vue.js フロントエンド基盤層

**目標**: Vue.js プロジェクトの土台と認証フローを完成させる

| 作業項目 | 内容 |
|---|---|
| プロジェクト初期化 | `npm create vue@latest`（TypeScript・Vue Router・Pinia・Vitest 選択） |
| Axios 設定 | `src/api/client.ts`（ベース URL・JWT インターセプター・401 自動ログアウト） |
| API 関数 | `src/api/auth.ts`, `src/api/books.ts` |
| Pinia ストア | `src/stores/authStore.ts`（ログイン状態・トークン管理）, `src/stores/bookStore.ts` |
| Vue Router 設定 | `src/router/index.ts`（ルート定義・認証ガード） |
| 共通コンポーネント | `AppLayout.vue`, `AppHeader.vue`, `LoadingSpinner.vue`, `ErrorMessage.vue` |
| ログイン画面 | `LoginView.vue`（フォーム + バリデーション + エラー表示） |

**完了条件**:
- `npm run build` が通ること
- `npm run dev` で起動し、ログイン → `/books` へのリダイレクトが動作すること
- 未ログイン状態で `/books` にアクセスすると `/login` にリダイレクトされること

---

## Week 9: Phase 5b — Vue.js 書籍管理画面

**目標**: 書籍管理の全画面を実装し、Spring Boot API と統合する

| 作業項目 | 内容 |
|---|---|
| 書籍一覧画面 | `BookListView.vue`（タイトル/著者/カテゴリ検索・結果一覧・削除ボタン） |
| 書籍詳細画面 | `BookDetailView.vue`（全フィールド表示・編集/削除ボタン） |
| 書籍フォーム画面 | `BookFormView.vue`（登録・編集の共通フォーム・クライアントサイドバリデーション・サーバーエラー表示） |
| 削除確認 | `ConfirmModal.vue`（削除前確認モーダル） |
| 書籍関連コンポーネント | `BookCard.vue`, `BookSearchForm.vue`, `CategoryBadge.vue` |
| ユニットテスト | `BookListView.test.ts`, `BookFormView.test.ts` |
| 統合確認 | Spring Boot API 起動状態で全フローを手動確認 |

**完了条件**:
- `npm run test` が通ること
- `npm run dev` + `mvn spring-boot:run` の状態でログイン → 一覧 → 登録 → 編集 → 削除 が動作すること
- バリデーションエラー時にメッセージが表示されること

---

## Week 10: CI/CD 実装

**目標**: GitHub Actions ワークフローを構築し、PR ごとに品質チェックが自動実行される状態にする

詳細は [`docs/cicd-plan.md`](./cicd-plan.md) を参照。

| 作業項目 | 内容 |
|---|---|
| legacy-app CI | `.github/workflows/legacy-app-ci.yml` |
| migration-app CI | `.github/workflows/migration-api-ci.yml`（テスト + カバレッジ） |
| frontend CI | `.github/workflows/frontend-ci.yml`（lint + 型チェック + テスト + ビルド） |
| セキュリティスキャン | `.github/workflows/security-scan.yml`（OWASP + npm audit） |
| README 更新 | CI バッジ追加・ローカル起動手順の整備 |

**完了条件**:
- PR 作成時に 3 つの CI ワークフローが自動実行されること
- main ブランチの保護ルールが設定済みであること（手順を README に記載）

---

## 計画サマリー

| Week | フェーズ | 主な成果物 |
|---|---|---|
| 1 | Phase 0 | ディレクトリ骨格・Dev Container（完了済み） |
| 2 | Phase 1a | Struts アプリ基盤（Model / DAO / 設定） |
| 3 | Phase 1b | Struts アプリ UI（Action / JSP）＋動作確認 |
| 4 | Phase 2 | 解析レポート 7 本 |
| 5 | Phase 3 | 移行設計書 7 本 |
| 6 | Phase 4a | Spring Boot API 基盤（Entity / Repository / JWT） |
| 7 | Phase 4b | Spring Boot API ビジネス層＋テスト |
| 8 | Phase 5a | Vue.js 基盤（認証・ルーター・共通コンポーネント） |
| 9 | Phase 5b | Vue.js 書籍管理画面＋統合確認 |
| 10 | CI/CD | GitHub Actions ワークフロー整備 |
