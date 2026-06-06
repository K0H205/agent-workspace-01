# agent-workspace

チーム共有の **agent skills 置き場 兼 横断文脈ワークスペース** です。

複数のサービスリポジトリをまたいで作業するときに使う「地図・ルール・skills・
scripts」を Git 管理します。**サービスのコード自体はここでは管理しません**。各
サービスリポは `workspace/` 配下に clone する運用で、それらは gitignore で除外し、
各自の `.git` で管理します。

特定のエージェントツールに依存しない**中立な構成**を保ちます。正本は中立な
`AGENTS.md` と `skills/` の1か所に置き、ツール固有の入口は（必要な人が）任意で
symlink として足します。

---

## ディレクトリ構成

| パス                      | Git管理 | 役割                                                       |
| ------------------------- | ------- | ---------------------------------------------------------- |
| `AGENTS.md`               | ✅      | 地図・ルールの**中立な正本**（唯一の正本）                  |
| `skills/`                 | ✅      | 再利用可能な skills（中立・ツール非依存）                   |
| `scripts/`                | ✅      | 補助スクリプト（workspace 同期など）                       |
| `workspace.manifest.yaml` | ✅      | `workspace/` に clone するサービスリポの一覧               |
| `tasks/`                  | ✅      | 横断タスクのメモ・ブリーフ                                 |
| `workspace/`              | ❌      | サービスリポを **clone する場所**（gitignore で除外）       |

👉 まずは **[`AGENTS.md`](./AGENTS.md)** を読んでください。レイアウトと運用ルールの
正本です。

---

## セットアップ

### 1. このワークスペースを clone する

```bash
git clone <このリポのURL> agent-workspace
cd agent-workspace
```

### 2. clone するサービスリポを確認する

`workspace.manifest.yaml` に、`workspace/` 配下へ取り込むサービスリポを記述します。

```bash
cat workspace.manifest.yaml
```

記述例:

```yaml
version: 1
repos:
  - name: example-service                 # workspace/ 配下に作るディレクトリ名
    url: git@github.com:K0H205/example-service.git
    ref: main                             # 省略可（既定ブランチを使う）
```

### 3. サービスリポを workspace/ に clone する

マニフェストに従って一括 clone（または更新）します。clone した実リポは `workspace/`
配下に入り、**親リポでは追跡されません**。

```bash
./scripts/sync-workspace.sh
```

> このスクリプトは YAML 解析に [`yq`](https://github.com/mikefarah/yq) を使います。
> 未インストールの場合は案内を出して終了するので、`yq` を入れるか手動で clone して
> ください。

これで `workspace/<サービス名>/` に各リポが揃い、横断作業を始められます。

---

## ツール固有の入口を足したい場合（任意）

多くのエージェントツールは `AGENTS.md` と `skills/` を直接読むため、追加設定は
基本的に不要です。ツールが独自のファイル名やパスを要求する場合は、**実体をコピー
せず** 中立な正本へ symlink を張ってください。

```bash
# ツールが独自のルート指示ファイルを要求する場合
ln -s AGENTS.md <TOOL>.md            # 例: CLAUDE.md, GEMINI.md, ...

# ツールが独自ディレクトリ配下の skills を要求する場合
mkdir -p .<tool> && ln -s ../skills .<tool>/skills
```

これらの symlink は **ローカル/任意** にとどめ、特定ツールの入口を既定として
コミットしないでください（リポが特定ツールに再特化してしまうため）。Windows など
symlink が使えない環境では、ツールの設定で正本パス（`AGENTS.md` / `skills/`）を
直接指す方式にフォールバックしてください。

---

## 運用上のルール

- **`workspace/` 配下は絶対に `git add` しない**。clone した実リポは各自の `.git` を
  持つため、親リポで追跡すると「embedded repository」事故になります（`.gitignore`
  で除外済み）。
- **正本は中立な場所に1つだけ**。ツール固有はあくまで入口（symlink/設定）にとどめる。
- **秘密情報はコミットしない**。ローカル設定は `.env`（gitignore 済み）に置く。
- skill を追加するときは実体を `skills/<名前>/` に置き、`SKILL.md` で「何をするか・
  いつ使うか」を書く（詳細は `skills/README.md`）。

---

## このリポに含まれないもの

- 各サービスのソースコード（`workspace/` に clone するだけで追跡しない）
- 特定エージェントツール専用の設定ファイル（既定では同梱しない）
