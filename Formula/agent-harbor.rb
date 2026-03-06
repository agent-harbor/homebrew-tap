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
  DOWNLOADS_BASE_URL = "https://downloads.agent-harbor.com/macos"
  RELEASE_VERSION = "0.0.0"
  ARM64_SHA256 = "0000000000000000000000000000000000000000000000000000000000000000"
  X86_64_SHA256 = "0000000000000000000000000000000000000000000000000000000000000000"

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
