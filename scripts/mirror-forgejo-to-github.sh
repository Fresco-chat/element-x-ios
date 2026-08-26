#!/usr/bin/env bash
# Mirror Forgejo fresco/element-x-ios → GitHub Fresco-chat/element-x-ios (public).
# Run from any machine with SSH to git.zem.systems and gh auth.
set -euo pipefail

FORGEJO_ORG="${FORGEJO_ORG:-fresco}"
FORGEJO_REPO="${FORGEJO_REPO:-element-x-ios}"
GITHUB_ORG="${GITHUB_ORG:-Fresco-chat}"
GITHUB_REPO="${GITHUB_REPO:-element-x-ios}"
FORGEJO_GIT="${FORGEJO_GIT:-ssh://forgejo@git.zem.systems:2222/${FORGEJO_ORG}}"
GITHUB_TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-$(gh auth token 2>/dev/null || true)}}"

die() { echo "error: $*" >&2; exit 1; }
[[ -n "$GITHUB_TOKEN" ]] || die "set GITHUB_TOKEN or run: gh auth login"

if ! gh repo view "${GITHUB_ORG}/${GITHUB_REPO}" >/dev/null 2>&1; then
  echo "Creating public ${GITHUB_ORG}/${GITHUB_REPO}"
  gh repo create "${GITHUB_ORG}/${GITHUB_REPO}" --public --confirm
fi

# Push Fresco branches only (full --mirror hits GitHub limits on upstream tag history).
SRC_DIR="${SRC_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
if [ -d "$SRC_DIR/.git" ]; then
  echo "==> pushing branches from $SRC_DIR → ${GITHUB_ORG}/${GITHUB_REPO}"
  git -C "$SRC_DIR" push --force \
    "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_ORG}/${GITHUB_REPO}.git" \
    develop fresco/branding
  if command -v git-lfs >/dev/null 2>&1 || git lfs version >/dev/null 2>&1; then
    echo "==> pushing Git LFS objects (may take a while on first sync)"
    git -C "$SRC_DIR" lfs install
    git -C "$SRC_DIR" lfs push \
      "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_ORG}/${GITHUB_REPO}.git" \
      --all 2>/dev/null || echo "warn: LFS push incomplete — CI fetches LFS from element-hq upstream"
  else
    echo "warn: git-lfs not installed; CI fetches LFS from element-hq upstream"
  fi
  gh repo edit "${GITHUB_ORG}/${GITHUB_REPO}" --default-branch fresco/branding
  echo "OK → https://github.com/${GITHUB_ORG}/${GITHUB_REPO}"
  exit 0
fi

tmp="$(mktemp -d)"
work="$tmp/${FORGEJO_REPO}.git"

echo "==> ${FORGEJO_ORG}/${FORGEJO_REPO} → ${GITHUB_ORG}/${GITHUB_REPO} (mirror fallback)"
git clone --mirror "${FORGEJO_GIT}/${FORGEJO_REPO}.git" "$work"
git -C "$work" push --mirror \
  "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_ORG}/${GITHUB_REPO}.git"
rm -rf "$tmp"
gh repo edit "${GITHUB_ORG}/${GITHUB_REPO}" --default-branch fresco/branding 2>/dev/null || true
echo "OK → https://github.com/${GITHUB_ORG}/${GITHUB_REPO}"
