# mousekeys: keyboard-driven mouse control (QMK-style layers), native daemon.
#
# Releases ship a Developer ID-signed bottle. `cellar :any_skip_relocation`
# stops Homebrew from relocating (and thus rewriting and invalidating) the
# signed Mach-O; without a matching bottle, brew builds from source and the
# binary is ad-hoc signed. Fill the bottle sha256 lines from `brew bottle
# --json` at release time (see the mousekeys repo's packaging/RELEASING.md).
class Mousekeys < Formula
  desc "Keyboard-driven mouse control (QMK-style layers), as a native daemon"
  homepage "https://github.com/eishexac/mousekeys"
  url "https://github.com/eishexac/mousekeys/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "a409280ee384b20e8eaa0d8e7e3844b8bc99150844b78e420b94eb4e722e8109"
  license "MIT"
  head "https://github.com/eishexac/mousekeys.git", branch: "dev"

  depends_on xcode: :build
  depends_on :macos

  # Bottles are added at the first release. Build one with:
  #   MOUSEKEYS_CODESIGN_ID="Developer ID Application: <name> (KQ342N2Y27)" \
  #     brew install --build-bottle mousekeys && brew bottle --json mousekeys
  # then paste the generated `bottle do` block here. It must carry
  # `cellar :any_skip_relocation`, or Homebrew relocates and invalidates the
  # Developer ID signature. See the mousekeys repo's packaging/RELEASING.md.

  def install
    system "make", "build"
    bin.install "build/mousekeysd"
    # Reference copy only; the daemon seeds ~/.config/mousekeys/config itself
    # on first run, so the formula never writes to the user's home.
    pkgshare.install "packaging/mousekeys.conf.example"
    # Signing is NOT done here: Homebrew's build sandbox scrubs the
    # environment, so a Developer ID identity can't be passed in. Release
    # bottles are Developer ID-signed by CI (the release workflow signs the
    # installed keg before `brew bottle`). A from-source install is therefore
    # ad-hoc-signed — it runs, but re-prompts for Accessibility on upgrades;
    # install the bottle for the persistent grant.
  end

  # No `service` block: the daemon registers its own login agent. A plain
  # `mousekeysd` run installs the agent, starts it under launchd (the correct
  # Accessibility context), and exits — the menu-bar "Start at Login" toggle
  # manages it thereafter.

  def caveats
    <<~EOS
      Set it up (registers a login agent, starts it, and exits):
        mousekeysd

      First launch asks for Accessibility permission — a macOS requirement no
      installer can grant. Approve it once at:
        System Settings > Privacy & Security > Accessibility
      The daemon waits for the toggle, then runs — now and at every login.
      Manage that from the menu-bar icon (Start at Login).

      Config is created on first run and hot-reloads on save (no restart):
        ~/.config/mousekeys/config
      Additional files in ~/.config/mousekeys/config.d/*.conf are merged in
      sorted order, later keys winning. Regenerate the default any time:
        mousekeysd --print-default-config

      Caps Lock becomes the mouse layer while running and is restored on quit.
      Hold both Shift keys and press Esc to force-quit mouse mode.
    EOS
  end

  test do
    assert_match "mousekeysd #{version}", shell_output("#{bin}/mousekeysd --version")
    assert_match "[layer]", shell_output("#{bin}/mousekeysd --print-default-config")
  end
end
