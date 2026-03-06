#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FORMULA="$REPO_ROOT/Formula/agent-harbor.rb"

echo "=== Homebrew Formula Verification ==="

if [[ ! -f "$FORMULA" ]]; then
  echo "FAIL: Formula not found at $FORMULA" >&2
  exit 1
fi
echo "PASS: Formula file exists"

if ! command -v ruby >/dev/null 2>&1; then
  echo "FAIL: ruby is required to validate the formula syntax" >&2
  exit 1
fi

if ruby -c "$FORMULA" >/dev/null 2>&1; then
  echo "PASS: Ruby syntax is valid"
else
  echo "FAIL: Ruby syntax error in formula" >&2
  ruby -c "$FORMULA"
  exit 1
fi

check_content() {
  local label="$1"
  local pattern="$2"

  if grep -qE "$pattern" "$FORMULA"; then
    echo "PASS: $label"
  else
    echo "FAIL: $label (pattern not found: $pattern)" >&2
    exit 1
  fi
}

check_content "Has release repo constant" 'RELEASE_REPO = "'
check_content "Has release version constant" 'RELEASE_VERSION = "'
check_content "Has ARM checksum constant" 'ARM64_SHA256 = "'
check_content "Has Intel checksum constant" 'X86_64_SHA256 = "'
check_content "Has desc" 'desc "'
check_content "Has homepage" 'homepage "'
check_content "Has url" 'url "'
check_content "Has license" 'license "'
check_content "Installs ah binary" 'bin\.install "ah"'
check_content "Installs daemon binary" 'bin\.install "ah-fs-snapshots-daemon"'
check_content "Generates shell completions" 'generate_completions_from_executable'
check_content "Has test block" 'test do'
check_content "Has ARM support" 'on_arm do'
check_content "Has Intel support" 'on_intel do'

echo ""
echo "=== All Homebrew formula checks passed ==="
