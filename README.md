# agent-workspace

Team-shared **agent skills store and cross-cutting context workspace**.

This repo holds the *map*, *rules*, *skills*, and *scripts* used when working
across many service repositories — but **not** the service code itself.
Service repos are cloned under `workspace/` (which is gitignored) and keep
their own `.git`.

👉 **Start with [`AGENTS.md`](./AGENTS.md)** — the canonical map and rules.
Tool-specific entry points like `CLAUDE.md` and `.claude/skills/` are
symlinks back into the neutral source.

## Quick start

```bash
cat workspace.manifest.yaml      # see which service repos are declared
./scripts/sync-workspace.sh      # clone them into workspace/ (untracked)
```
