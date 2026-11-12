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
  RELEASE_VERSION = "0.6.17"
  ARM64_SHA256 = "9bc9dd802e6223a114acff2df8c02afea7840645452ffa8e3836ea145c23cbd7"
  X86_64_SHA256 = ""

  desc "AI coding agent orchestration platform"
  homepage "https://agent-harbor.com"
  license "AGPL-3.0-only"
  version RELEASE_VERSION
  depends_on "tmux"
  # An empty X86_64_SHA256 means the release ships Apple Silicon only (macOS
  # releases are arm64-only since v0.4.0; ONNX Runtime has no x86_64 prebuilt).
  depends_on arch: :arm64 if X86_64_SHA256.empty?

  # Placeholder URL so Homebrew can parse the formula before the first release
  # updates the constants above.
  url "#{DOWNLOADS_BASE_URL}/v#{RELEASE_VERSION}/ah-macos-arm64.tar.gz"
  sha256 ARM64_SHA256

  on_arm do
    url "#{DOWNLOADS_BASE_URL}/v#{RELEASE_VERSION}/ah-macos-arm64.tar.gz"
    sha256 ARM64_SHA256
  end

  on_intel do
    unless X86_64_SHA256.empty?
      url "#{DOWNLOADS_BASE_URL}/v#{RELEASE_VERSION}/ah-macos-x86_64.tar.gz"
      sha256 X86_64_SHA256
    end
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
