# skills-sync.sh — 共通 Agent Skills 同期

チーム共通の Agent Skills を管理する中央リポジトリ(`agent-workspace`)から、
`shared-*` という名前の skill だけをこのリポジトリの `.github/skills/` 配下に
自動コピーする仕組みです。`.github/hooks/skills-sync.json` の `sessionStart`
フックから起動され、Copilot CLI / VS Code のセッション開始時に実行されます。

> **注記**: このリポジトリ自体を中央リポジトリとして運用する予定はなく、
> 各サービスリポ側に導入する仕組みの実装例として記録用に置いています。

## 何をするか

1. `.github/skills/.sync-meta` の更新時刻が10分以内なら何もせず終了(多重発火対策)
2. `~/.cache/agent-workspace` に中央リポジトリを shallow clone(2回目以降は
   `fetch --depth 1` + `checkout FETCH_HEAD` で更新)
3. 中央リポジトリの `skills/shared-*/` を1ディレクトリずつ、このリポジトリの
   `.github/skills/` 配下へ実体コピー(symlink は使わない)
4. 中央側で削除された `shared-*` はローカルからも削除する
5. `.sync-meta` に同期日時・参照ブランチ・コミットSHA(短縮)を書き出す

`.github/skills/` 配下にある `shared-*` 以外のディレクトリ(このリポジトリ専用の
skill)には一切触れません。

## 設定

| 環境変数 | 既定値 | 説明 |
| --- | --- | --- |
| `AGENT_WORKSPACE_REPO` | `git@github.com:YOUR_ORG/agent-workspace.git` | 中央リポジトリのURL |
| `AGENT_WORKSPACE_REF` | `main` | 同期元のブランチ/参照 |

実際に使う際は `YOUR_ORG` を実際の組織名に置き換えるか、環境変数で上書きしてください。

## 失敗しても安全

ネットワークがない、中央リポジトリにアクセスできない、`rsync` が入っていない、
といった状況でも **常に exit 0** で終了し、セッション開始を妨げません。

- fetch に失敗した場合は既存キャッシュのまま続行
- 初回 clone に失敗した場合は何もせず終了
- `rsync` が無い環境では `rm -rf` + `cp -R` にフォールバック

## Windows / macOS 対応について

このスクリプトは Bash スクリプト(`#!/usr/bin/env bash`)で、`git` /
`rsync`(任意)/ `cp` / `stat` / `date` といった POSIX 系コマンドに依存します。

- **macOS**: 標準の `bash` と `git` で動作します。`stat` は BSD 版
  (`stat -f %m`)なので、GNU版(`stat -c %Y`)が失敗した場合のフォールバックとして
  スクリプト内で両方を試すようにしています。`flock` は macOS に標準で無いため
  意図的に使っていません(10分デバウンスのみで多重発火に対応)。
- **Windows**: `cmd.exe` や PowerShell からネイティブには実行できません。
  **Git for Windows(Git Bash)** または **WSL** など、Bash と GNU 相当の
  coreutils が使える環境が必要です。Copilot CLI / VS Code のフックが
  Windows 上で `bash` 経由 (`"bash": "./scripts/agent/skills-sync.sh"`) に
  スクリプトを起動する前提のため、これらの環境があれば問題なく動作します。
