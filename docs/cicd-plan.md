# CI/CD 設計・計画書

## 方針

| 項目 | 選択 | 理由 |
|---|---|---|
| CI プラットフォーム | GitHub Actions | リポジトリと同一サービスで設定シンプル |
| トリガー | PR 作成/更新・main push | PR で品質ゲート、main push で最終確認 |
| ビルド分割 | モノレポ対応（paths filter） | 変更があったモジュールだけビルドしてコストを抑える |
| Java | JDK 21（ubuntu-latest） | 移行先と揃える。legacy-app も JDK 21 でビルド |
| Node.js | Node 20.x LTS | frontend-app の Vite / Vitest に対応 |

---

## ワークフロー構成

### 1. `legacy-app-ci.yml` — Struts レガシーアプリのビルド・テスト

```
トリガー: PR / push to main
変更パス: legacy-app/**

ジョブ:
  build-and-test:
    - actions/checkout
    - actions/setup-java (JDK 21)
    - actions/cache (Maven ~/.m2)
    - mvn compile --batch-mode --fail-at-end
    - mvn test  ※ Phase 1b 完了後に有効化
```

**目的**: legacy-app を触るときに意図せずビルドが壊れていないか検出する。

---

### 2. `migration-api-ci.yml` — Spring Boot REST API のビルド・テスト・カバレッジ

```
トリガー: PR / push to main
変更パス: migration-app/**

ジョブ:
  build-and-test:
    - actions/checkout
    - actions/setup-java (JDK 21)
    - actions/cache (Maven ~/.m2)
    - mvn compile --batch-mode
    - mvn test --batch-mode
    - JaCoCo カバレッジレポート生成
    - PR へのカバレッジサマリーコメント投稿（※ PR イベント時のみ）
```

**目的**: API の品質ゲート。Controller / Service のユニットテストが必ず通ることを保証する。

---

### 3. `frontend-ci.yml` — Vue.js フロントエンドの Lint・型チェック・テスト・ビルド

```
トリガー: PR / push to main
変更パス: frontend-app/**

ジョブ:
  lint-typecheck-test-build:
    - actions/checkout
    - actions/setup-node (Node 20.x)
    - actions/cache (npm ~/.npm)
    - npm ci
    - npm run lint          # ESLint
    - npm run type-check    # vue-tsc
    - npm run test          # Vitest（ヘッドレス）
    - npm run build         # Vite プロダクションビルド
```

**目的**: フロントエンドの品質ゲート。型エラー・テスト失敗・ビルド失敗をすべて PR 段階で検出する。

---

### 4. `security-scan.yml` — 依存ライブラリの脆弱性スキャン

```
トリガー: 毎週月曜 09:00 JST（cron: '0 0 * * 1'）
         + PR（pom.xml / package.json / package-lock.json の変更時）

ジョブ:
  maven-dependency-check:
    - OWASP Dependency Check（Maven プラグイン）
    - severity HIGH 以上で失敗
    - HTML レポートを Artifact 保存

  npm-audit:
    - npm audit --audit-level=high（frontend-app）
    - 脆弱性あれば PR コメントで報告
```

**目的**: 使用ライブラリの既知 CVE を定期的に検出する。デモプロジェクトのため CD での強制ブロックは行わず、まず可視化に留める。

---

### 5. `integration-test.yml` — E2E 統合テスト（Week 9 完了後に追加）

```
トリガー: push to main

ジョブ:
  e2e:
    - Spring Boot API をバックグラウンド起動（mvn spring-boot:run &）
    - Vue.js フロントエンドをビルド + serve
    - Playwright でシナリオ実行:
        1. ログイン
        2. 書籍一覧表示
        3. 書籍新規登録
        4. 書籍編集
        5. 書籍削除
    - スクリーンショットを Artifact 保存
```

**目的**: バックエンドとフロントエンドの結合を main マージ後に自動検証する。

---

## paths-filter による条件分岐パターン

各ワークフローで `dorny/paths-filter` を使い、変更がないモジュールのジョブをスキップします。

```yaml
jobs:
  changes:
    runs-on: ubuntu-latest
    outputs:
      legacy:   ${{ steps.filter.outputs.legacy }}
      backend:  ${{ steps.filter.outputs.backend }}
      frontend: ${{ steps.filter.outputs.frontend }}
    steps:
      - uses: actions/checkout@v4
      - uses: dorny/paths-filter@v3
        id: filter
        with:
          filters: |
            legacy:
              - 'legacy-app/**'
            backend:
              - 'migration-app/**'
            frontend:
              - 'frontend-app/**'

  build-legacy:
    needs: changes
    if: needs.changes.outputs.legacy == 'true'
    # ...
```

---

## ブランチ保護ルール（GitHub 上の手動設定）

Week 10 の作業完了後、GitHub リポジトリの Settings → Branches から以下を設定する。

| ルール | 設定値 |
|---|---|
| 対象ブランチ | `main` |
| Require a pull request before merging | ON |
| Require approvals | 1 名以上 |
| Require status checks to pass before merging | ON |
| Required status checks | `build-and-test (legacy)`, `build-and-test (backend)`, `lint-typecheck-test-build (frontend)` |
| Do not allow bypassing the above settings | ON |

> **注意**: CLAUDE.md の基本ルール「main への直接 commit・push は禁止」と整合させるため、  
> ブランチ保護ルールでも強制する。

---

## CI バッジ（README に追加）

```markdown
![Legacy App CI](https://github.com/<owner>/<repo>/actions/workflows/legacy-app-ci.yml/badge.svg)
![Migration API CI](https://github.com/<owner>/<repo>/actions/workflows/migration-api-ci.yml/badge.svg)
![Frontend CI](https://github.com/<owner>/<repo>/actions/workflows/frontend-ci.yml/badge.svg)
```

---

## Week 10 実装チェックリスト

- [ ] `.github/workflows/legacy-app-ci.yml` 作成
- [ ] `.github/workflows/migration-api-ci.yml` 作成（JaCoCo カバレッジ付き）
- [ ] `.github/workflows/frontend-ci.yml` 作成
- [ ] `.github/workflows/security-scan.yml` 作成
- [ ] `.github/workflows/integration-test.yml` の雛形作成（E2E は Week 9 完了後に有効化）
- [ ] `README.md` に CI バッジを追加
- [ ] ブランチ保護ルール設定手順を `README.md` に記載
- [ ] 各ワークフローが PR 上で正常に動作することを確認
