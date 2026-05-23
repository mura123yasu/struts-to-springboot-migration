# CI/CD 設計書

イシュー駆動開発（IDD）を支えるための CI/CD 構成。
**実装は CI/CD 基盤整備フェーズで最初に行い、Phase 1〜5 の実装フェーズより先に整備する。**

---

## ワークフロー全体像

```
開発者（Claude）
  │
  ├─ Issue 作成（gh issue create）
  │
  ├─ ブランチ: issue/<番号>/<説明>
  │
  ├─ コミット & Push
  │
  └─ PR 作成（Closes #N）
         │
         ▼
    pr-autocheck.yml ─── Linked Issue Check（Closes #N がなければ即失敗）
         │               reviewdog ESLint    （inline PR コメント）
         │               reviewdog Checkstyle（inline PR コメント）
         │
    ci-legacy.yml   ─── legacy-app/** 変更時に Build & Test
    ci-backend.yml  ─── migration-app/** 変更時に Build + Test + JaCoCo
    ci-frontend.yml ─── frontend-app/** 変更時に Lint + 型チェック + Vitest + Build
         │
         ▼
    人間レビュー（自動レビュー結果を踏まえて確認）
         │
         ▼
    main マージ → Issue 自動クローズ
```

---

## ワークフロー詳細

### `pr-autocheck.yml` — PR 自動チェック（全 PR に必ず実行）

| ジョブ | 内容 | 失敗条件 |
|---|---|---|
| `check-linked-issue` | PR 本文に `Closes #N` / `Fixes #N` / `Resolves #N` があるか | なければ即失敗（IDD 強制） |
| `reviewdog-eslint` | ESLint 結果を PR diff にインラインコメント投稿 | `frontend-app/package.json` 存在時のみ実行 |
| `reviewdog-checkstyle` | Checkstyle 結果を PR diff にインラインコメント投稿 | `migration-app/pom.xml` 存在時のみ実行 |

**ポイント**: `check-linked-issue` はブランチ保護の必須チェックに設定する。
reviewdog の lint 指摘は `fail_on_error: false`（コメントのみ）で、人間が内容を確認して判断する。

---

### `ci-legacy.yml` — Struts レガシーアプリ

- **トリガー**: `legacy-app/**` の変更を含む PR / main push
- **ジョブ**: JDK 21 + Maven キャッシュ → `mvn compile` → `mvn test`
- **有効化タイミング**: Phase 1 で `legacy-app/pom.xml` が追加されてから

---

### `ci-backend.yml` — Spring Boot REST API

- **トリガー**: `migration-app/**` の変更を含む PR / main push
- **ジョブ**: JDK 21 + Maven キャッシュ → `mvn compile` → `mvn test jacoco:report`
- **追加機能**: JaCoCo カバレッジレポートを PR にコメント投稿（60% 未満で警告）
- **有効化タイミング**: Phase 4 で `migration-app/pom.xml` が追加されてから
- **前提**: `pom.xml` に `jacoco-maven-plugin` と `maven-checkstyle-plugin` の設定が必要（Phase 4a で追加）

---

### `ci-frontend.yml` — Vue.js フロントエンド

- **トリガー**: `frontend-app/**` の変更を含む PR / main push
- **ジョブ**: Node 20 + npm キャッシュ → `npm ci` → `lint` → `type-check` → `test --coverage` → `build`
- **有効化タイミング**: Phase 5 で `frontend-app/package.json` が追加されてから

---

### `security-scan.yml` — 脆弱性スキャン

- **トリガー**: 毎週月曜 09:00 JST + `pom.xml` / `package*.json` 変更の PR
- **ジョブ**:
  - OWASP Dependency Check（Maven / CVSS 9 以上で警告）
  - npm audit（HIGH 以上で警告）
- **方針**: デモプロジェクトのため `|| true` でビルドはブロックせず、レポートを Artifact に保存して可視化

---

## 自動レビュー（reviewdog）の仕組み

```
PR push
  │
  ├─ reviewdog-eslint
  │    npm run lint（ESLint）を実行
  │    → 指摘箇所の PR diff 行に直接コメント投稿
  │    例: "no-console: Unexpected console statement"
  │
  └─ reviewdog-checkstyle
       mvn checkstyle:checkstyle を実行
       → target/checkstyle-result.xml を reviewdog でパース
       → 指摘箇所の PR diff 行に直接コメント投稿
       例: "LineLength: Line is longer than 120 characters"
```

人間のレビュアーは reviewdog コメントを確認し、修正が必要かどうか判断する。
CI 失敗にはしない（`fail_on_error: false`）ため、ゲートではなくアドバイスとして機能する。

---

## Phase 別 CI 有効化タイムライン

| Phase | 有効になる CI |
|---|---|
| CI/CD 基盤整備 | `pr-autocheck.yml`（全 PR で `Linked Issue Check` が動く） |
| Phase 1 完了後 | `ci-legacy.yml`（Build & Test）が動く |
| Phase 4 完了後 | `ci-backend.yml`（Build + Test + JaCoCo）と reviewdog Checkstyle が動く |
| Phase 5 完了後 | `ci-frontend.yml`（Lint + Test + Build）と reviewdog ESLint が動く |

---

## CI/CD 基盤整備フェーズのチェックリスト

Claude が Issue を起票し、以下を順に実施する。

- [ ] ラベル・Milestone・GitHub Projects を作成（`docs/github-setup.md` の手順）
- [ ] `pr-autocheck.yml` を動作確認（テスト PR を作成し `Linked Issue Check` が失敗することを確認）
- [ ] ブランチ保護ルールに `Linked Issue Check` を必須チェックとして追加
- [ ] CI バッジを `README.md` に追加
