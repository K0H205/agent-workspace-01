# Skills

Reusable, **tool-neutral** agent skills. This directory is the canonical
location for skill content. If a tool needs skills under its own path, add a
symlink back to this directory locally (e.g. `.<tool>/skills -> ../skills`) —
do not duplicate content there, and do not commit a tool-specific path as the
default.

## Layout

```
skills/
  <skill-name>/
    SKILL.md      # what the skill does, when to use it, how to use it
    ...           # optional supporting scripts/assets
```

## SKILL.md format

Start each `SKILL.md` with a short frontmatter-style header and a clear
"when to use" line, then the instructions. See `example-skill/SKILL.md`.
