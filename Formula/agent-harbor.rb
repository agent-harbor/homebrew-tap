# Homebrew formula for Agent Harbor CLI.
#
# This tap hosts the standalone macOS CLI tarballs produced by the main
# Agent Harbor release pipeline.
#
# Installation:
#   brew install agent-harbor/tap/agent-harbor
#
# This file is intentionally templated with constants so release automation can
# update only the version and checksums without rewriting the rest of the formula.

class AgentHarbor < Formula
  DOWNLOADS_BASE_URL = "https://github.com/agent-harbor/homebrew-tap/releases/download"
  RELEASE_VERSION = "0.3.17"
  ARM64_SHA256 = "cb1bb1216e04cf04ba4829eb9f44a232275472e71e8a5c7ba3c4d2be0dfd006b"
  X86_64_SHA256 = "127d65c270413f2e00803680f96cd11927b6959ccfe96a841fee1472bc9e49b2"

  desc "AI coding agent orchestration platform"
  homepage "https://agent-harbor.com"
  license "AGPL-3.0-only"
  version RELEASE_VERSION
  depends_on "tmux"

  # Placeholder URL so Homebrew can parse the formula before the first release
  # updates the constants above.
  url "#{DOWNLOADS_BASE_URL}/v#{RELEASE_VERSION}/ah-macos-arm64.tar.gz"
  sha256 ARM64_SHA256

  on_arm do
    url "#{DOWNLOADS_BASE_URL}/v#{RELEASE_VERSION}/ah-macos-arm64.tar.gz"
    sha256 ARM64_SHA256
  end

  on_intel do
    url "#{DOWNLOADS_BASE_URL}/v#{RELEASE_VERSION}/ah-macos-x86_64.tar.gz"
    sha256 X86_64_SHA256
  end

  def install
    bin.install "ah"
    bin.install "ah-fs-snapshots-daemon"

    generate_completions_from_executable(bin/"ah", "completions", shells: [:bash, :zsh, :fish])
  end

  test do
    assert_match "ah", shell_output("#{bin}/ah --version")
  end
end
