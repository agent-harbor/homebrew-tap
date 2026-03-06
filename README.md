# `agent-harbor/homebrew-tap`

Homebrew tap for the Agent Harbor macOS CLI.

This repository hosts the Homebrew tap metadata for the Agent Harbor macOS CLI.
The formula downloads release artifacts from the public downloads domain rather
than GitHub Releases.

## Install

```bash
brew tap agent-harbor/tap
brew install agent-harbor
```

Or without a prior tap:

```bash
brew install agent-harbor/tap/agent-harbor
```

## What this tap installs

The formula installs:

- `ah`
- `ah-fs-snapshots-daemon`

It also declares a dependency on `tmux`.

## Updating the formula

Release automation, or a maintainer, updates the formula with the current
release version and macOS tarball checksums:

```bash
./scripts/update-formula.sh <version> <arm64-sha256> <x86_64-sha256>
```

Example:

```bash
./scripts/update-formula.sh 0.3.2 \
  abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789 \
  0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
```

By default the formula downloads macOS CLI tarballs from:

- `https://downloads.agent-harbor.com/macos/v<version>/ah-macos-arm64.tar.gz`
- `https://downloads.agent-harbor.com/macos/v<version>/ah-macos-x86_64.tar.gz`

If the downloads domain changes later, update `Formula/agent-harbor.rb` and the
release automation in `agent-harbor-2` together.
