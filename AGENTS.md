# Agent Workspace — Map & Rules (Canonical)

> **This file is the single source of truth.** Tool-specific entry points
> (e.g. `CLAUDE.md`, `.claude/skills/`) are **symlinks** back to this repo's
> neutral files. Do not fork the content — edit it here.

This repository is a team-shared **agent skills store and cross-cutting
context workspace**. It holds the *map*, the *rules*, the *skills*, and the
*scripts* that agents and humans use when working across many service
repositories. It deliberately does **not** contain the service code itself.

---

## 1. What lives here (and what does not)

| Path                      | Tracked? | Purpose                                                        |
| ------------------------- | -------- | ------------------------------------------------------------- |
| `AGENTS.md`               | ✅        | Canonical map + rules (this file). Source of truth.           |
| `CLAUDE.md`               | ✅ (link) | Tool-specific entry point → symlink to `AGENTS.md`.           |
| `skills/`                 | ✅        | Reusable agent skills (neutral, tool-agnostic).               |
| `.claude/skills/`         | ✅ (link) | Claude-specific skills entry → symlink to `skills/`.          |
| `scripts/`                | ✅        | Helper scripts (workspace sync, etc.).                        |
| `workspace.manifest.yaml` | ✅        | Declares which service repos get cloned into `workspace/`.    |
| `tasks/`                  | ✅        | Cross-cutting task notes / briefs.                            |
| `workspace/`              | ❌        | Where service repos are **cloned**. Ignored by git.           |

**Service code is never tracked here.** Each service repo is cloned under
`workspace/` and keeps its own `.git`. The parent repo ignores `workspace/`
so those clones are never accidentally added (no embedded-repo accidents).

---

## 2. Core principles

1. **Tool-neutral by default.** The canonical map, rules, and skills live in
   neutral locations. Anything tool-specific is an *entry point only* — a thin
   symlink (or a config pointer) into the neutral source. Never duplicate the
   real content under a tool-specific path.
2. **One source of truth.** If you find a real copy where a symlink belongs,
   delete the copy and restore the symlink (or, on a symlink-hostile platform,
   point the tool's config at the neutral path and note it).
3. **Clones stay out of git.** `workspace/` is gitignored. Service repos are
   cloned there at runtime and managed by their own `.git`.
4. **Templates may ship before values.** Placeholder manifests/maps are fine to
   commit; real values land in follow-up commits.

---

## 3. Getting started

```bash
# 1. Clone this workspace repo
git clone <this-repo-url> agent-workspace
cd agent-workspace

# 2. Review which service repos to pull in
cat workspace.manifest.yaml

# 3. Clone the declared service repos into workspace/ (kept out of git)
./scripts/sync-workspace.sh
```

> ⚠️ Do **not** run the sync script as part of preparing this repo for its
> first push — it would populate `workspace/` and is unnecessary for the
> scaffold. Run it only when you actually want the service repos locally.

---

## 4. Rules for agents

- Treat **this file** as authoritative for layout and conventions.
- Never `git add` anything under `workspace/` — those are independent clones.
- When adding a skill, put the real content under `skills/<name>/` and rely on
  the existing `.claude/skills` symlink for tool exposure.
- Keep secrets out of the repo. Use `.env` (gitignored) for local config.
- Prefer editing the neutral canonical files; let symlinks propagate.

---

## 5. Skills convention

Each skill is a directory under `skills/` containing a `SKILL.md` that
describes what it does and when to use it. See `skills/README.md` for the
format and `skills/example-skill/` for a starting template.
