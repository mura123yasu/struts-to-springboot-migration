# Struts → Spring Boot マイグレーション デモ

## 構成
- `legacy-app/` : 移行元 Struts2 アプリ（図書館蔵書管理システム）
- `migration-app/` : 移行先 Spring Boot 3.x REST API
- `frontend-app/` : 移行先 Vue.js 3 SPA
- `docs/` : 分析レポート・設計書

## 開発環境

### 前提条件
- Docker
- Node.js（devcontainer CLI のインストールに必要）

### VS Code で起動
Dev Container を使用。VS Code で開き「Reopen in Container」を選択。

### CLI で起動

devcontainer CLI をインストール:

```bash
npm install -g @devcontainers/cli
```

コンテナの起動・操作:

```bash
# ビルド & 起動
devcontainer up --workspace-folder .

# コンテナ内でシェルを開く
devcontainer exec --workspace-folder . bash

# コンテナ内でコマンドを実行
devcontainer exec --workspace-folder . mvn -f legacy-app/pom.xml compile

# 停止
docker ps --filter "label=devcontainer.local_folder=$(pwd)" -q | xargs docker stop
```

### Claude Code による自走実行

コンテナ内で Claude Code を使い、フェーズ単位で自走実行できます。

#### 認証（初回のみ）

コンテナ起動後、`claude login` を実行します。
ブラウザが使えない環境でも URL がターミナルに表示されるので、ホストのブラウザで開いて OAuth を完了してください。

```bash
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . claude login
# → URL が表示される
# → ホストのブラウザで開いて認証
# → "Logged in as ..." が表示されれば完了
```

認証情報は Docker ボリュームに保存されるため、コンテナを再起動しても再ログイン不要です。
（`--remove-existing-container` でコンテナを作り直した場合は再ログインが必要）

#### 自走実行

```bash
# Claude 自走実行（例: Phase 1）
devcontainer exec --workspace-folder . \
  claude --dangerously-skip-permissions \
  -p "CLAUDE.md の Phase 1 を実行してください。"
```

フェーズ別の詳細な起動コマンドは `CLAUDE.md` の「自走実行ガイド」を参照してください。

### コンテナ内のツール
| ツール | バージョン |
|---|---|
| Java (OpenJDK) | 21 |
| Maven | 3.9.x |
| Node.js | 20.x |
| GitHub CLI | 最新 |
| Claude Code | 最新 |
