# Agent Workspace — Map & Rules (Canonical)

> **This file is the single source of truth, and it is tool-neutral.**
> `AGENTS.md` is the neutral entry point that agent tooling reads directly.
> This repo ships **no** tool-specific files by default so it stays neutral.
> If a particular tool needs its own entry point, add it locally as a thin
> **symlink** back to these neutral files — never fork the content.

This repository is a team-shared **agent skills store and cross-cutting
context workspace**. It holds the *map*, the *rules*, the *skills*, and the
*scripts* that agents and humans use when working across many service
repositories. It deliberately does **not** contain the service code itself,
and it is **not tied to any single agent tool**.

---

## 1. What lives here (and what does not)

| Path                      | Tracked? | Purpose                                                        |
| ------------------------- | -------- | ------------------------------------------------------------- |
| `AGENTS.md`               | ✅        | Canonical, tool-neutral map + rules (this file). Source of truth. |
| `skills/`                 | ✅        | Reusable agent skills (neutral, tool-agnostic).               |
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
   neutral locations (`AGENTS.md`, `skills/`). The repo presumes no specific
   agent tool. Nothing tool-specific is committed by default.
2. **One source of truth.** All real content lives in the neutral files. If a
   tool needs its own entry point, it is an *entry point only* — a thin
   symlink (or a config pointer) into the neutral source. Never duplicate the
   real content under a tool-specific path. If you find a real copy where a
   symlink belongs, delete the copy and restore the symlink.
3. **Clones stay out of git.** `workspace/` is gitignored. Service repos are
   cloned there at runtime and managed by their own `.git`.
4. **Templates may ship before values.** Placeholder manifests/maps are fine to
   commit; real values land in follow-up commits.

---

## 3. Adding a tool-specific entry point (optional, local)

Most agent tools read `AGENTS.md` and `skills/` directly, so nothing extra is
needed. If your tool insists on its own filename or path, link it back to the
neutral source instead of copying — for example:

```bash
# A tool that wants its own root instructions file:
ln -s AGENTS.md <TOOL>.md            # e.g. CLAUDE.md, GEMINI.md, ...

# A tool that wants skills under its own directory:
mkdir -p .<tool> && ln -s ../skills .<tool>/skills
```

Keep these links **local/optional**. Do not commit a tool-specific entry point
as the assumed default — that would re-specialize the repo toward one tool. If
your platform is symlink-hostile (e.g. Windows), point the tool's config at the
neutral path (`AGENTS.md` / `skills/`) instead, and note that in your setup.

---

## 4. Getting started

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

## 5. Rules for agents

- Treat **this file** as authoritative for layout and conventions.
- Never `git add` anything under `workspace/` — those are independent clones.
- When adding a skill, put the real content under `skills/<name>/`. Expose it
  to your tool via its own entry point (symlink/config) only if the tool needs
  one — do not commit tool-specific exposure by default.
- Keep secrets out of the repo. Use `.env` (gitignored) for local config.
- Prefer editing the neutral canonical files; let any entry points propagate.

---

## 6. Skills convention

Each skill is a directory under `skills/` containing a `SKILL.md` that
describes what it does and when to use it. See `skills/README.md` for the
format and `skills/example-skill/` for a starting template.
