#!/usr/bin/env bash
# Copyright 2026 Schelling Point Labs Inc
# SPDX-License-Identifier: AGPL-3.0-only

set -euo pipefail

VERSION=""
STAGING_DIR=".release-staging"
FORMULA="Formula/agent-harbor.rb"
DRY_RUN=false

usage() {
  cat <<'EOF'
Usage:
  ./scripts/publish-release-assets.sh --version VERSION [OPTIONS]

Options:
  --version VERSION    Release version (accepts 1.2.3 or v1.2.3)
  --staging-dir DIR    Directory containing staged ah-macos-*.tar.gz files
                       (default: .release-staging)
  --formula PATH       Formula path to update (default: Formula/agent-harbor.rb)
  --dry-run            Skip GitHub release API calls
  -h, --help           Show this help message

Environment:
  GH_TOKEN             Required unless --dry-run is used
EOF
}

log_info() {
  printf '[INFO] %s\n' "$*"
}

log_error() {
  printf '[ERROR] %s\n' "$*" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  --version)
    VERSION="${2:-}"
    shift 2
    ;;
  --staging-dir)
    STAGING_DIR="${2:-}"
    shift 2
    ;;
  --formula)
    FORMULA="${2:-}"
    shift 2
    ;;
  --dry-run)
    DRY_RUN=true
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    log_error "Unknown option: $1"
    usage >&2
    exit 1
    ;;
  esac
done

if [[ -z "$VERSION" ]]; then
  log_error "--version is required"
  usage >&2
  exit 1
fi

VERSION="${VERSION#v}"
RELEASE_TAG="v${VERSION}"
ARM64_TARBALL="${STAGING_DIR}/ah-macos-arm64.tar.gz"
X86_64_TARBALL="${STAGING_DIR}/ah-macos-x86_64.tar.gz"
DOWNLOADS_BASE_URL="https://github.com/agent-harbor/homebrew-tap/releases/download"

detect_sha256_cmd() {
  if command -v sha256sum >/dev/null 2>&1; then
    echo "sha256sum"
    return 0
  fi

  if command -v shasum >/dev/null 2>&1; then
    echo "shasum -a 256"
    return 0
  fi

  log_error "Neither sha256sum nor shasum is available"
  exit 1
}

for tarball in "$ARM64_TARBALL" "$X86_64_TARBALL"; do
  if [[ ! -f "$tarball" ]]; then
    log_error "Missing staged tarball: $tarball"
    exit 1
  fi
done

SHA256_CMD="$(detect_sha256_cmd)"
ARM64_SHA="$(${SHA256_CMD} "${ARM64_TARBALL}" | awk '{print $1}')"
X86_64_SHA="$(${SHA256_CMD} "${X86_64_TARBALL}" | awk '{print $1}')"

log_info "Preparing release assets for ${RELEASE_TAG}"
log_info "  arm64 sha256: ${ARM64_SHA}"
log_info "  x86_64 sha256: ${X86_64_SHA}"

if [[ "$DRY_RUN" == "false" ]]; then
  if [[ -z "${GH_TOKEN:-}" ]]; then
    log_error "GH_TOKEN is required unless --dry-run is used"
    exit 1
  fi

  if ! command -v gh >/dev/null 2>&1; then
    log_error "gh CLI is required unless --dry-run is used"
    exit 1
  fi

  if ! gh release view "$RELEASE_TAG" >/dev/null 2>&1; then
    gh release create "$RELEASE_TAG" \
      --title "$RELEASE_TAG" \
      --notes ""
  fi

  gh release upload "$RELEASE_TAG" \
    --clobber \
    "$ARM64_TARBALL" \
    "$X86_64_TARBALL"
fi

./scripts/update-formula.sh \
  "$VERSION" \
  "$ARM64_SHA" \
  "$X86_64_SHA" \
  "$DOWNLOADS_BASE_URL" \
  "$FORMULA"

log_info "Release assets prepared for ${RELEASE_TAG}"
