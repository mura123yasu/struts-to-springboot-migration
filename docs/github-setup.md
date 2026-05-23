# GitHub リポジトリ初期設定手順

CI/CD ワークフローが正しく動作し、イシュー駆動開発を回せる状態にするための設定手順。
**CI/CD 基盤整備フェーズ（最初に実施）** で Claude が実行する。

---

## 1. ラベル作成

```bash
# 既存のデフォルトラベルを整理（任意）
# gh label delete "good first issue" --yes 等

# フェーズラベル
gh label create "ci-cd"   --description "CI/CD 関連"                        --color "f0e030" --force
gh label create "phase-1" --description "Phase 1: Struts アプリ実装"        --color "0075ca" --force
gh label create "phase-2" --description "Phase 2: 解析レポート生成"         --color "cfd3d7" --force
gh label create "phase-3" --description "Phase 3: 移行設計書生成"           --color "a2eeef" --force
gh label create "phase-4" --description "Phase 4: Spring Boot API 実装"     --color "e4e669" --force
gh label create "phase-5" --description "Phase 5: Vue.js フロントエンド実装" --color "d93f0b" --force

# タイプラベル
gh label create "task"  --description "実装タスク"  --color "0052cc" --force
gh label create "setup" --description "環境・設定"  --color "c5def5" --force
```

## 2. マイルストーン作成

```bash
gh api repos/{owner}/{repo}/milestones --method POST -f title="CI/CD 基盤整備"           -f description="GitHub Actions・Projects・ブランチ保護の整備"
gh api repos/{owner}/{repo}/milestones --method POST -f title="Phase 1: Struts アプリ実装"
gh api repos/{owner}/{repo}/milestones --method POST -f title="Phase 2: 解析レポート"
gh api repos/{owner}/{repo}/milestones --method POST -f title="Phase 3: 移行設計書"
gh api repos/{owner}/{repo}/milestones --method POST -f title="Phase 4: Spring Boot API"
gh api repos/{owner}/{repo}/milestones --method POST -f title="Phase 5: Vue.js フロントエンド"
```

## 3. GitHub Projects（カンバンボード）作成

1. リポジトリの「Projects」タブ → 「Link a project」→「New project」
2. テンプレート: **Board**（カンバン形式）
3. プロジェクト名: `Struts → Spring Boot + Vue.js 移行`
4. カラム:
   - **To Do** — 未着手 Issue
   - **In Progress** — 作業中（ブランチ作成済み）
   - **In Review** — PR 提出済み・レビュー待ち
   - **Done** — マージ済み・Issue クローズ済み

### Projects 自動化設定（プロジェクト設定 > Workflows）

| トリガー | アクション |
|---|---|
| Item added to project | Status → To Do |
| Item reopened | Status → To Do |
| Pull request merged | Status → Done |
| Item closed | Status → Done |

## 4. ブランチ保護ルール

Settings → Branches → Add rule:

| 設定項目 | 値 |
|---|---|
| Branch name pattern | `main` |
| Require a pull request before merging | ON |
| Require approvals | 1 |
| Require status checks to pass | ON |
| Required checks | `Linked Issue Check` |
| Do not allow bypassing the above settings | ON |

> `Linked Issue Check` を必須にすることで CLAUDE.md の「main への直接コミット禁止 + IDD ルール」を GitHub 側でも強制する。
