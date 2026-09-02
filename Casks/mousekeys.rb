# mousekeys — a Developer ID-signed .app shipped as a Cask. Built and kept up to
# date by the mousekeys release workflow, which fills in the version and sha256.
#
# The .app is the product: it carries the daemon at Contents/MacOS/mousekeys and,
# as a registered bundle, macOS lists it in Accessibility and Login Items on its
# own. It is Developer ID-signed (and notarized when notary secrets are set), so
# the Accessibility grant survives upgrades.
cask "mousekeys" do
  version "0.1.0"
  sha256 "b253bcccb8d1f86981c3ef3221e508522e02b7b8a3f1e7a1e5677de87fe53e42"

  url "https://github.com/eishexac/mousekeys/releases/download/v#{version}/mousekeys-#{version}.zip"
  name "mousekeys"
  desc "Keyboard-driven mouse control (QMK-style layers)"
  homepage "https://github.com/eishexac/mousekeys"

  depends_on macos: ">= :ventura"  # SMAppService login item needs macOS 13+

  app "mousekeys.app"

  caveats <<~EOS
    First launch asks for Accessibility permission — a macOS requirement no
    installer can grant. Approve mousekeys at:
      System Settings > Privacy & Security > Accessibility

    Then tap Caps Lock to enter mouse mode. Manage it from the menu-bar icon
    (Start at Login, Edit Config, Reload Config, Quit).

    Config is created on first run and hot-reloads on save (no restart):
      ~/.config/mousekeys/config
    Drop-ins in ~/.config/mousekeys/config.d/*.conf are merged in sorted order.
  EOS
end
