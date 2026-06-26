#!/usr/bin/env bash
#
# sync-workspace.sh
# ------------------------------------------------------------------------
# Clone (or update) the service repositories declared in
# workspace.manifest.yaml into ./workspace/.
#
# These clones keep their own .git and are intentionally ignored by the
# parent workspace repo (see .gitignore). Running this script does NOT add
# anything to the parent repo's git index.
#
# Requirements: bash, git, and a YAML parser. This template uses `yq` if
# available; otherwise it prints guidance and exits.
#
# NOTE: Do not run this while preparing the workspace repo for its first
# push — it populates workspace/ and is not needed for the scaffold.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="${ROOT_DIR}/workspace.manifest.yaml"
WORKSPACE_DIR="${ROOT_DIR}/workspace"

if [[ ! -f "${MANIFEST}" ]]; then
  echo "manifest not found: ${MANIFEST}" >&2
  exit 1
fi

if ! command -v yq >/dev/null 2>&1; then
  echo "This script needs 'yq' to parse ${MANIFEST}." >&2
  echo "Install yq (https://github.com/mikefarah/yq) or clone repos manually." >&2
  exit 1
fi

mkdir -p "${WORKSPACE_DIR}"

count="$(yq '.repos | length' "${MANIFEST}")"
if [[ "${count}" == "0" || "${count}" == "null" ]]; then
  echo "No repos declared in ${MANIFEST}. Nothing to do."
  exit 0
fi

for i in $(seq 0 $((count - 1))); do
  name="$(yq -r ".repos[${i}].name" "${MANIFEST}")"
  url="$(yq -r ".repos[${i}].url" "${MANIFEST}")"
  ref="$(yq -r ".repos[${i}].ref // \"\"" "${MANIFEST}")"
  dest="${WORKSPACE_DIR}/${name}"

  if [[ -d "${dest}/.git" ]]; then
    echo "==> Updating ${name}"
    git -C "${dest}" fetch --all --prune
    [[ -n "${ref}" ]] && git -C "${dest}" checkout "${ref}"
    git -C "${dest}" pull --ff-only || true
  else
    echo "==> Cloning ${name} from ${url}"
    git clone "${url}" "${dest}"
    [[ -n "${ref}" ]] && git -C "${dest}" checkout "${ref}"
  fi
done

echo "Workspace sync complete."
