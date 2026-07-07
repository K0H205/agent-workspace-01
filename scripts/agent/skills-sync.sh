#!/usr/bin/env bash
# Sync shared Agent Skills from the central agent-workspace repository into
# .github/skills/ as shared-* directories. Runs from a sessionStart hook
# (Copilot CLI / VS Code), so it must never block or fail the session:
# every exit path is exit 0.
set -uo pipefail

REPO_URL="${AGENT_WORKSPACE_REPO:-git@github.com:YOUR_ORG/agent-workspace.git}"
REPO_REF="${AGENT_WORKSPACE_REF:-main}"
CACHE_DIR="${HOME}/.cache/agent-workspace"

# Resolve the root of the repository this hook runs in.
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
[ -n "$REPO_ROOT" ] || exit 0

SKILLS_DIR="${REPO_ROOT}/.github/skills"
META_FILE="${SKILLS_DIR}/.sync-meta"

# Debounce: skip if we synced within the last 10 minutes (hooks can fire
# multiple times in quick succession). flock is intentionally avoided
# because it is not available on macOS.
if [ -f "$META_FILE" ]; then
  now="$(date +%s)"
  meta_mtime="$(stat -c %Y "$META_FILE" 2>/dev/null || stat -f %m "$META_FILE" 2>/dev/null || echo 0)"
  if [ $((now - meta_mtime)) -lt 600 ]; then
    exit 0
  fi
fi

# Refresh the shallow cache of the central repo. On fetch failure keep
# using whatever is already cached; on first-clone failure bail silently.
if [ -d "${CACHE_DIR}/.git" ]; then
  if git -C "$CACHE_DIR" fetch --depth 1 origin "$REPO_REF" >/dev/null 2>&1; then
    git -C "$CACHE_DIR" checkout -q FETCH_HEAD >/dev/null 2>&1 || true
  fi
else
  mkdir -p "$(dirname "$CACHE_DIR")" 2>/dev/null
  rm -rf "$CACHE_DIR" 2>/dev/null
  git clone --depth 1 --branch "$REPO_REF" "$REPO_URL" "$CACHE_DIR" >/dev/null 2>&1 || exit 0
fi

# The cache is authoritative from here on: if skills/ is absent upstream,
# the copy loop no-ops and the prune loop removes all local shared-*.
SRC_SKILLS="${CACHE_DIR}/skills"

mkdir -p "$SKILLS_DIR" 2>/dev/null || exit 0

# Copy each shared-* skill from the central repo as a real directory
# (no symlinks). rsync keeps the copy exact; fall back to rm+cp where
# rsync is unavailable.
have_rsync=0
command -v rsync >/dev/null 2>&1 && have_rsync=1

for src in "$SRC_SKILLS"/shared-*/; do
  [ -d "$src" ] || continue
  name="$(basename "$src")"
  dest="${SKILLS_DIR}/${name}"
  if [ "$have_rsync" -eq 1 ]; then
    rsync -a --delete "$src" "$dest/" 2>/dev/null || true
  else
    rm -rf "$dest" 2>/dev/null
    cp -R "$src" "$dest" 2>/dev/null || true
  fi
done

# Remove local shared-* skills that no longer exist upstream. Anything
# not prefixed shared-* is a repo-local skill and is left untouched.
for dest in "$SKILLS_DIR"/shared-*/; do
  [ -d "$dest" ] || continue
  name="$(basename "$dest")"
  if [ ! -d "${SRC_SKILLS}/${name}" ]; then
    rm -rf "$dest" 2>/dev/null
  fi
done

# Record sync metadata (also serves as the debounce timestamp).
src_sha="$(git -C "$CACHE_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)"
{
  echo "synced_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "source_ref=${REPO_REF}"
  echo "source_sha=${src_sha}"
} > "$META_FILE" 2>/dev/null

exit 0
