# `agent-harbor/homebrew-tap`

Homebrew tap for the Agent Harbor macOS CLI.

This repository is both:

- the Homebrew tap metadata repo
- the public release-asset host for the macOS CLI tarballs consumed by the formula

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
`agent-harbor/homebrew-tap` GitHub Releases. Each release must attach:

- `ah-macos-arm64.tar.gz`
- `ah-macos-x86_64.tar.gz`

If the artifact host changes later, update `Formula/agent-harbor.rb` and the
release automation together.
