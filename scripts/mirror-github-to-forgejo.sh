#!/usr/bin/env bash
# Mirror GitHub Fresco-chat/element-x-ios → Forgejo fresco/element-x-ios.
# Use after merging on GitHub if you want Forgejo to stay in sync (e.g. workflow-only commits).
set -euo pipefail

FORGEJO_ORG="${FORGEJO_ORG:-fresco}"
FORGEJO_REPO="${FORGEJO_REPO:-element-x-ios}"
GITHUB_ORG="${GITHUB_ORG:-Fresco-chat}"
GITHUB_REPO="${GITHUB_REPO:-element-x-ios}"
FORGEJO_GIT="${FORGEJO_GIT:-ssh://forgejo@git.zem.systems:2222/${FORGEJO_ORG}}"
GITHUB_TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-$(gh auth token 2>/dev/null || true)}}"

die() { echo "error: $*" >&2; exit 1; }
[[ -n "$GITHUB_TOKEN" ]] || die "set GITHUB_TOKEN or run: gh auth login"

tmp="$(mktemp -d)"
work="$tmp/${GITHUB_REPO}.git"

echo "==> ${GITHUB_ORG}/${GITHUB_REPO} → ${FORGEJO_ORG}/${FORGEJO_REPO}"
git clone --mirror "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_ORG}/${GITHUB_REPO}.git" "$work"

# Push only Fresco branches (avoid overwriting Forgejo with thousands of upstream topic branches).
git -C "$work" push --force "${FORGEJO_GIT}/${FORGEJO_REPO}.git" \
  refs/heads/develop refs/heads/fresco/branding
rm -rf "$tmp"
echo "OK → ssh://forgejo@git.zem.systems:2222/${FORGEJO_ORG}/${FORGEJO_REPO}.git"
