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
  RELEASE_VERSION = "0.3.18"
  ARM64_SHA256 = "caadcb42c84b161c709ec86438646a140e56450053e123cecd02dd5dcaf8fa20"
  X86_64_SHA256 = "7e1dbafa47f7e5f502cb813d3c8b987be37c5dc19ae7a315bffb131ecfb1b88c"

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
