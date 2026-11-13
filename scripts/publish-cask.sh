#!/usr/bin/env bash
# Copyright 2026 Schelling Point Labs Inc
# SPDX-License-Identifier: AGPL-3.0-only
#
# Install the cask that the Agent Harbor release staged on a release-assets
# branch into Casks/agent-harbor.rb on main, after checking it.
#
# macOS is Apple Silicon only, so the cask must be arm64-only: this refuses a
# cask that names another CPU, keeps the placeholder checksum, or is for a
# different version than the release being published.

set -euo pipefail

VERSION=""
STAGED=""
CASK="Casks/agent-harbor.rb"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/publish-cask.sh --version VERSION --staged-cask PATH [--cask PATH]

Options:
  --version VERSION    Release version (accepts 1.2.3 or v1.2.3)
  --staged-cask PATH   The cask staged by the release (Casks/agent-harbor.rb on
                       the release-assets branch)
  --cask PATH          Where to install it (default: Casks/agent-harbor.rb)
EOF
}

log_error() { printf '[ERROR] %s\n' "$*" >&2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
  --version) VERSION="${2:-}"; shift 2 ;;
  --staged-cask) STAGED="${2:-}"; shift 2 ;;
  --cask) CASK="${2:-}"; shift 2 ;;
  -h | --help) usage; exit 0 ;;
  *) log_error "Unknown option: $1"; usage >&2; exit 1 ;;
  esac
done

if [[ -z "$VERSION" || -z "$STAGED" ]]; then
  log_error "--version and --staged-cask are required"
  usage >&2
  exit 1
fi
VERSION="${VERSION#v}"
if [[ ! -f "$STAGED" ]]; then
  log_error "Staged cask not found: $STAGED (the release did not stage a cask)"
  exit 1
fi

fail=0
require() { # require DESCRIPTION REGEX
  if ! grep -Eq "$2" "$STAGED"; then
    log_error "staged cask: $1 (no line matching $2)"
    fail=1
  fi
}
require "version is ${VERSION}" "^[[:space:]]*version \"${VERSION//./\\.}\"\$"
require "has a real sha256" '^[[:space:]]*sha256 "[0-9a-f]{64}"$'
require "is Apple Silicon only" '^[[:space:]]*depends_on arch: :arm64$'
if grep -Eq '^[[:space:]]*sha256 "0{64}"$' "$STAGED"; then
  log_error "staged cask: the sha256 is still the all-zero placeholder"
  fail=1
fi
if grep -Eiq 'intel|x86_64' "$STAGED"; then
  log_error "staged cask: names Intel or x86_64, but macOS releases are Apple Silicon only"
  fail=1
fi
if command -v ruby >/dev/null 2>&1 && ! ruby -c "$STAGED" >/dev/null 2>&1; then
  log_error "staged cask: Ruby syntax error"
  ruby -c "$STAGED" >&2 || true
  fail=1
fi
if [[ "$fail" -ne 0 ]]; then
  exit 1
fi

mkdir -p "$(dirname "$CASK")"
cp "$STAGED" "$CASK"
printf '[INFO] Installed cask for v%s at %s\n' "$VERSION" "$CASK"
