# `agent-harbor/homebrew-tap`

Homebrew tap for the Agent Harbor macOS CLI.

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

By default the formula downloads release assets from
`blocksense-network/agent-harbor`. If the release artifact host changes, update
`Formula/agent-harbor.rb` accordingly.
