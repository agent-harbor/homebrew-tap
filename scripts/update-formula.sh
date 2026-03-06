#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/update-formula.sh <version> <arm64-sha256> <x86_64-sha256> [release-repo]

Examples:
  ./scripts/update-formula.sh 0.3.2 <arm64-sha256> <x86_64-sha256>
  ./scripts/update-formula.sh 0.3.2 <arm64-sha256> <x86_64-sha256> blocksense-network/agent-harbor
EOF
}

if [[ $# -lt 3 || $# -gt 4 ]]; then
  usage >&2
  exit 1
fi

VERSION="${1#v}"
ARM64_SHA256="$2"
X86_64_SHA256="$3"
RELEASE_REPO="${4:-blocksense-network/agent-harbor}"
FORMULA="Formula/agent-harbor.rb"

if [[ ! -f "$FORMULA" ]]; then
  echo "Formula not found: $FORMULA" >&2
  exit 1
fi

if [[ ! "$ARM64_SHA256" =~ ^[0-9a-f]{64}$ ]]; then
  echo "Invalid arm64 SHA-256: $ARM64_SHA256" >&2
  exit 1
fi

if [[ ! "$X86_64_SHA256" =~ ^[0-9a-f]{64}$ ]]; then
  echo "Invalid x86_64 SHA-256: $X86_64_SHA256" >&2
  exit 1
fi

RELEASE_REPO_VALUE="$RELEASE_REPO" \
  perl -0pi -e 's/^  RELEASE_REPO = ".*"$/  RELEASE_REPO = "$ENV{RELEASE_REPO_VALUE}"/m' "$FORMULA"
RELEASE_VERSION_VALUE="$VERSION" \
  perl -0pi -e 's/^  RELEASE_VERSION = ".*"$/  RELEASE_VERSION = "$ENV{RELEASE_VERSION_VALUE}"/m' "$FORMULA"
ARM64_SHA256_VALUE="$ARM64_SHA256" \
  perl -0pi -e 's/^  ARM64_SHA256 = "[0-9a-f]{64}"$/  ARM64_SHA256 = "$ENV{ARM64_SHA256_VALUE}"/m' "$FORMULA"
X86_64_SHA256_VALUE="$X86_64_SHA256" \
  perl -0pi -e 's/^  X86_64_SHA256 = "[0-9a-f]{64}"$/  X86_64_SHA256 = "$ENV{X86_64_SHA256_VALUE}"/m' "$FORMULA"

echo "Updated $FORMULA"
echo "  version: $VERSION"
echo "  release repo: $RELEASE_REPO"
echo "  arm64 sha256: $ARM64_SHA256"
echo "  x86_64 sha256: $X86_64_SHA256"
