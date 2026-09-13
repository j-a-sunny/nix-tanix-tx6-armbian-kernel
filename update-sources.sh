#!/usr/bin/env bash
# update-sources.sh
#
# Regenerates sources.nix with the current Armbian kernel build's URLs and
# hashes. Doesn't touch any running system — only writes a text file.
#
# Run via `nix run .#update-sources`, review the diff, commit it like any
# other change. Also run automatically by .github/workflows/auto-update.yml.

set -euo pipefail

REPO_BASE="https://beta.armbian.com"
PACKAGES_PATH="/dists/sid/main/binary-arm64/Packages"

# "current" or "edge" — change this one value (or set BRANCH env var) to
# switch which Armbian kernel branch is tracked.
BRANCH="${BRANCH:-current}"

IMAGE_PKG="linux-image-${BRANCH}-sunxi64"
DTB_PKG="linux-dtb-${BRANCH}-sunxi64"
HEADERS_PKG="linux-headers-${BRANCH}-sunxi64"
LIBC_DEV_PKG="linux-libc-dev-${BRANCH}-sunxi64"

SOURCES_NIX="${SOURCES_NIX:-./sources.nix}"

log() { echo "[update-sources] $*" >&2; }

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

log "fetching package index (branch: $BRANCH)..."
curl -fsSL "${REPO_BASE}${PACKAGES_PATH}.gz" -o "${WORKDIR}/Packages.gz"
gunzip "${WORKDIR}/Packages.gz"

extract_stanza() {
  local pkg="$1"
  awk -v pkg="Package: $pkg" '
    BEGIN { RS=""; FS="\n"; ORS="\0" }
    $1 == pkg { print }
  ' "${WORKDIR}/Packages"
}

pick_highest_version_stanza() {
  local pkg="$1"
  local best_version="" best_stanza=""
  local stanza v
  while IFS= read -r -d $'\0' stanza; do
    v="$(echo "$stanza" | grep '^Version:' | cut -d' ' -f2)"
    if [[ -z "$best_version" ]] || dpkg --compare-versions "$v" gt "$best_version"; then
      best_version="$v"
      best_stanza="$stanza"
    fi
  done < <(extract_stanza "$pkg")
  printf '%s' "$best_stanza"
}

find_matching_stanza() {
  local pkg="$1" want_version="$2"
  local stanza v
  while IFS= read -r -d $'\0' stanza; do
    v="$(echo "$stanza" | grep '^Version:' | cut -d' ' -f2)"
    if [[ "$v" == "$want_version" ]]; then
      printf '%s' "$stanza"
      return 0
    fi
  done < <(extract_stanza "$pkg")
  return 1
}

field() {
  echo "$1" | grep "^$2:" | cut -d' ' -f2
}

IMAGE_STANZA="$(pick_highest_version_stanza "$IMAGE_PKG")"
if [[ -z "$IMAGE_STANZA" ]]; then
  log "error: package '$IMAGE_PKG' not found in repo index"
  exit 1
fi

PKG_VERSION="$(field "$IMAGE_STANZA" Version)"
REMOTE_FAMILY="$(field "$IMAGE_STANZA" Armbian-Kernel-Version-Family)"
IMAGE_FILENAME="$(field "$IMAGE_STANZA" Filename)"

DTB_STANZA="$(find_matching_stanza "$DTB_PKG" "$PKG_VERSION")" || {
  log "error: no matching $DTB_PKG for version $PKG_VERSION"
  exit 1
}
HEADERS_STANZA="$(find_matching_stanza "$HEADERS_PKG" "$PKG_VERSION")" || {
  log "error: no matching $HEADERS_PKG for version $PKG_VERSION"
  exit 1
}
LIBC_DEV_STANZA="$(find_matching_stanza "$LIBC_DEV_PKG" "$PKG_VERSION")" || {
  log "error: no matching $LIBC_DEV_PKG for version $PKG_VERSION"
  exit 1
}

DTB_FILENAME="$(field "$DTB_STANZA" Filename)"
HEADERS_FILENAME="$(field "$HEADERS_STANZA" Filename)"
LIBC_DEV_FILENAME="$(field "$LIBC_DEV_STANZA" Filename)"

log "found: $REMOTE_FAMILY (package $PKG_VERSION, branch $BRANCH)"

if [[ -f "$SOURCES_NIX" ]] && grep -q "\"$REMOTE_FAMILY\"" "$SOURCES_NIX"; then
  log "sources.nix already pinned to $REMOTE_FAMILY, nothing to do"
  exit 0
fi

hash_url() {
  log "hashing $1..."
  nix-prefetch-url --type sha256 "$1" 2>/dev/null
}

IMAGE_URL="${REPO_BASE}/${IMAGE_FILENAME}"
DTB_URL="${REPO_BASE}/${DTB_FILENAME}"
HEADERS_URL="${REPO_BASE}/${HEADERS_FILENAME}"
LIBC_DEV_URL="${REPO_BASE}/${LIBC_DEV_FILENAME}"

IMAGE_HASH="$(hash_url "$IMAGE_URL")"
DTB_HASH="$(hash_url "$DTB_URL")"
HEADERS_HASH="$(hash_url "$HEADERS_URL")"
LIBC_DEV_HASH="$(hash_url "$LIBC_DEV_URL")"

VERSION="${REMOTE_FAMILY%%-*}"

cat > "$SOURCES_NIX" << EOF
{
  version = "${VERSION}";
  modDirVersion = "${REMOTE_FAMILY}";

  image = {
    url = "${IMAGE_URL}";
    sha256 = "${IMAGE_HASH}";
  };
  dtb = {
    url = "${DTB_URL}";
    sha256 = "${DTB_HASH}";
  };
  headers = {
    url = "${HEADERS_URL}";
    sha256 = "${HEADERS_HASH}";
  };
  libcDev = {
    url = "${LIBC_DEV_URL}";
    sha256 = "${LIBC_DEV_HASH}";
  };
}
EOF

log "wrote ${SOURCES_NIX} (${REMOTE_FAMILY})"
