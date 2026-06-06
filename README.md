# agent-workspace

Team-shared **agent skills store and cross-cutting context workspace**.

This repo holds the *map*, *rules*, *skills*, and *scripts* used when working
across many service repositories — but **not** the service code itself.
Service repos are cloned under `workspace/` (which is gitignored) and keep
their own `.git`.

👉 **Start with [`AGENTS.md`](./AGENTS.md)** — the canonical, **tool-neutral**
map and rules. The repo presumes no specific agent tool and ships no
tool-specific files by default. If a tool needs its own entry point, add it
locally as a thin symlink back into the neutral source (see `AGENTS.md` §3).

## Quick start

```bash
cat workspace.manifest.yaml      # see which service repos are declared
./scripts/sync-workspace.sh      # clone them into workspace/ (untracked)
```
