#!/usr/bin/env bash
# Copyright 2026 Schelling Point Labs Inc
# SPDX-License-Identifier: AGPL-3.0-only

set -euo pipefail

readonly LOG_FILE="$(mktemp "${TMPDIR:-/tmp}/test-publish-release-assets.XXXXXX.log")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEST_ROOT=""
TEST_STATUS=1

cleanup() {
  local exit_code=$?

  if [[ -n "$TEST_ROOT" && -d "$TEST_ROOT" ]]; then
    rm -rf "$TEST_ROOT"
  fi

  if [[ $TEST_STATUS -eq 0 && $exit_code -eq 0 ]]; then
    printf 'PASS: publish release assets\n' >&3
  else
    local log_size=0
    if [[ -f "$LOG_FILE" ]]; then
      log_size=$(wc -c <"$LOG_FILE")
    fi
    printf 'FAIL: publish release assets (log: %s, size: %s bytes)\n' "$LOG_FILE" "$log_size" >&3
  fi
}

exec 3>&1
exec >"$LOG_FILE" 2>&1
trap cleanup EXIT

TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/test-publish-release-assets.dir.XXXXXX")"
STAGING_DIR="${TEST_ROOT}/staging"
FORMULA_COPY="${TEST_ROOT}/agent-harbor.rb"

mkdir -p "$STAGING_DIR"
cp "${REPO_ROOT}/Formula/agent-harbor.rb" "$FORMULA_COPY"
printf 'arm64-tarball\n' >"$STAGING_DIR/ah-macos-arm64.tar.gz"
printf 'x86_64-tarball\n' >"$STAGING_DIR/ah-macos-x86_64.tar.gz"

"$SCRIPT_DIR/publish-release-assets.sh" \
  --version 1.2.3 \
  --staging-dir "$STAGING_DIR" \
  --formula "$FORMULA_COPY" \
  --dry-run

ARM64_SHA_EXPECTED="$(sha256sum "$STAGING_DIR/ah-macos-arm64.tar.gz" | awk '{print $1}')"
X86_64_SHA_EXPECTED="$(sha256sum "$STAGING_DIR/ah-macos-x86_64.tar.gz" | awk '{print $1}')"

grep -q 'DOWNLOADS_BASE_URL = "https://github.com/agent-harbor/homebrew-tap/releases/download"' "$FORMULA_COPY"
grep -q 'RELEASE_VERSION = "1.2.3"' "$FORMULA_COPY"
grep -q "ARM64_SHA256 = \"${ARM64_SHA_EXPECTED}\"" "$FORMULA_COPY"
grep -q "X86_64_SHA256 = \"${X86_64_SHA_EXPECTED}\"" "$FORMULA_COPY"
grep -q 'url "#{DOWNLOADS_BASE_URL}/v#{RELEASE_VERSION}/ah-macos-arm64.tar.gz"' "$FORMULA_COPY"

TEST_STATUS=0
