# Skills

Reusable, **tool-neutral** agent skills. This directory is the canonical
location for skill content. Tool-specific entry points (e.g.
`.claude/skills/`) are symlinks back to this directory — do not duplicate
content there.

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
