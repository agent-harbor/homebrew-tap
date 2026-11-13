#!/usr/bin/env bash
# Copyright 2026 Schelling Point Labs Inc
# SPDX-License-Identifier: AGPL-3.0-only

set -euo pipefail

readonly LOG_FILE="$(mktemp "${TMPDIR:-/tmp}/test-publish-cask.XXXXXX.log")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_ROOT=""
TEST_STATUS=1

cleanup() {
  local exit_code=$?
  if [[ -n "$TEST_ROOT" && -d "$TEST_ROOT" ]]; then
    rm -rf "$TEST_ROOT"
  fi
  if [[ $TEST_STATUS -eq 0 && $exit_code -eq 0 ]]; then
    printf 'PASS: publish cask\n' >&3
  else
    printf 'FAIL: publish cask (log: %s, size: %s bytes)\n' "$LOG_FILE" "$(wc -c <"$LOG_FILE")" >&3
  fi
}

exec 3>&1
exec >"$LOG_FILE" 2>&1
trap cleanup EXIT

TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/test-publish-cask.dir.XXXXXX")"
SHA="$(printf 'dmg\n' | sha256sum | awk '{print $1}')"

write_cask() { # write_cask FILE VERSION SHA [EXTRA-LINE]
  cat >"$1" <<EOF
cask "agent-harbor" do
  version "$2"
  sha256 "$3"
  url "https://downloads.agent-harbor.com/macos/v#{version}/AgentHarbor-#{version}-arm64.dmg"
  name "Agent Harbor"
  homepage "https://agent-harbor.com"
  depends_on arch: :arm64
  app "Agent Harbor.app"
  ${4:-}
end
EOF
}

write_cask "$TEST_ROOT/good.rb" 1.2.3 "$SHA"
"$SCRIPT_DIR/publish-cask.sh" --version v1.2.3 --staged-cask "$TEST_ROOT/good.rb" --cask "$TEST_ROOT/out/Casks/agent-harbor.rb"
cmp "$TEST_ROOT/good.rb" "$TEST_ROOT/out/Casks/agent-harbor.rb"

expect_refused() { # expect_refused DESCRIPTION CASK-FILE [VERSION]
  if "$SCRIPT_DIR/publish-cask.sh" --version "${3:-1.2.3}" --staged-cask "$2" --cask "$TEST_ROOT/refused.rb"; then
    echo "expected the cask to be refused: $1" >&2
    exit 1
  fi
  if [[ -e "$TEST_ROOT/refused.rb" ]]; then
    echo "a refused cask was installed: $1" >&2
    exit 1
  fi
}

write_cask "$TEST_ROOT/old.rb" 1.2.2 "$SHA"
expect_refused "wrong version" "$TEST_ROOT/old.rb"
write_cask "$TEST_ROOT/zero.rb" 1.2.3 "$(printf '0%.0s' {1..64})"
expect_refused "placeholder checksum" "$TEST_ROOT/zero.rb"
write_cask "$TEST_ROOT/intel.rb" 1.2.3 "$SHA" 'sha256 intel: "x"'
expect_refused "an Intel branch" "$TEST_ROOT/intel.rb"
sed '/depends_on arch/d' "$TEST_ROOT/good.rb" >"$TEST_ROOT/without-arch.rb"
expect_refused "no arm64 requirement" "$TEST_ROOT/without-arch.rb"
if "$SCRIPT_DIR/publish-cask.sh" --version 1.2.3 --staged-cask "$TEST_ROOT/missing.rb"; then
  echo "expected failure when no cask was staged" >&2
  exit 1
fi

TEST_STATUS=0
