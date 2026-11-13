# Copyright 2026 Schelling Point Labs Inc
# SPDX-License-Identifier: AGPL-3.0-only

# Homebrew cask for the full Agent Harbor macOS app (DMG).
#
# This cask is designed to live in the agent-harbor/homebrew-tap
# repository. During development it lives in-repo at packaging/homebrew/
# and is synced to the tap repository by the release pipeline.
#
# Installation: brew install --cask agent-harbor/tap/agent-harbor
#
# Apple Silicon only (specs/Packaging.md, PKG-AREQ4): a release carries one
# arm64 DMG, so the cask has one URL and one checksum and `depends_on arch:
# :arm64`. scripts/stage-homebrew-tap-release-assets.sh replaces the
# placeholder version and checksum. Keep any mention of other CPU names out of
# this file: the channel probe reads the published cask for one.
#
# See: https://docs.brew.sh/Cask-Cookbook

cask "agent-harbor" do
  version "0.6.17"
  sha256 "a224e132b96b513c78aa66755d83b962ba895e80e4dfe405da00785913077a11"

  url "https://downloads.agent-harbor.com/macos/v#{version}/AgentHarbor-#{version}-arm64.dmg"
  name "Agent Harbor"
  desc "AI coding agent orchestration platform"
  homepage "https://agent-harbor.com"

  depends_on arch: :arm64
  depends_on macos: ">= :sequoia"

  app "Agent Harbor.app"

  # This is a stable launcher, not the runner payload. It resolves the active
  # version under ~/Library/Application Support/Agent Harbor/current before
  # falling back to the app bundle source for first-launch bootstrap.
  binary "#{appdir}/Agent Harbor.app/Contents/Resources/cli/ah-launcher",
         target: "ah"

  postflight do
    # RLP-AREQ2/RLP-AREQ3 (specs/Remote-LLM-Proxy-Trust.md § Installation
    # hooks): as the installing user, create the local LLM proxy's device CA
    # with its private key in the login Keychain, and trust it (and, on an
    # enrolled device, the remote proxy's CA) for SSL. Administrator rights come
    # from the macOS authorization prompt; `--yes` never deletes a key file. A
    # failure does not fail the installation: `ah health` reports it and names
    # `ah health fix-proxy-trust`.
    system_command "#{appdir}/Agent Harbor.app/Contents/Resources/cli/ah-launcher",
                   args:         ["health", "fix-proxy-trust", "--yes"],
                   must_succeed: false

    ohai "To enable the AgentHarborFS filesystem extension:"
    ohai "  Open System Settings → General → Login Items & Extensions"
    ohai "  Click ⓘ next to \"File System Extensions\" → Enable \"AgentHarborFSKitExtension\""
  end

  # Packaging.md "Installed Services vs. Activated Modes": uninstall MUST remove
  # the uninstalling user's per-user login registration, because nothing else
  # will. These three LaunchAgents are the only login items Agent Harbor ever
  # writes — `ah daemon autostart enable`, `ah-background install`, and
  # `ah server install --launch-at-login` — and all three live under the user's
  # own ~/Library/LaunchAgents, which is why no install step ever created them.
  zap trash:     [
        "~/Library/Application Support/Agent Harbor",
        "~/Library/Preferences/com.agentharbor.AgentHarbor.plist",
        "~/Library/Caches/com.agentharbor.AgentHarbor",
        "~/Library/LaunchAgents/com.agent-harbor.daemon.plist",
        "~/Library/LaunchAgents/com.agent-harbor.background.plist",
        "~/Library/LaunchAgents/com.agent-harbor.tier1.plist",
        "~/Library/LaunchAgents/com.agent-harbor.server.plist",
      ],
      launchctl: [
        "com.agent-harbor.daemon",
        "com.agent-harbor.background",
        "com.agent-harbor.tier1",
        "com.agent-harbor.server",
      ]
end
