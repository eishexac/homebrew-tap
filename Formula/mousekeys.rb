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
  sha256 "0000000000000000000000000000000000000000000000000000000000000000" # TODO: fill at release
  license "MIT"
  head "https://github.com/eishexac/mousekeys.git", branch: "dev"

  depends_on :macos
  depends_on xcode: :build

  bottle do
    root_url "https://github.com/eishexac/mousekeys/releases/download/v#{version}"
    cellar :any_skip_relocation
    # sha256 cellar: :any_skip_relocation, arm64_sequoia: "..."
    # sha256 cellar: :any_skip_relocation, arm64_sonoma:   "..."
  end

  def install
    system "make", "build"
    bin.install "build/mousekeysd"
    # Reference copy only; the daemon seeds ~/.config/mousekeys/config itself
    # on first run, so the formula never writes to the user's home.
    pkgshare.install "packaging/mousekeys.conf.example"

    # Developer ID signing for distributable bottles: a stable identity lets
    # the macOS Accessibility grant survive upgrades. A from-source install
    # leaves this unset and the binary stays ad-hoc (still runs; re-prompts
    # for Accessibility on each new version).
    id = ENV["MOUSEKEYS_CODESIGN_ID"]
    if id && !id.empty?
      system "codesign", "--force", "--options", "runtime", "--timestamp",
             "--sign", id, bin/"mousekeysd"
    end
  end

  # Homebrew generates and loads the LaunchAgent from this block. Started
  # without sudo it installs to ~/Library/LaunchAgents and runs in the user's
  # GUI session, which the event tap and menu-bar icon require. No -c: the
  # daemon reads ~/.config/mousekeys/ (config + config.d/*.conf) itself,
  # honoring $XDG_CONFIG_HOME.
  service do
    run [opt_bin/"mousekeysd"]
    keep_alive true
    run_type :immediate
    process_type :interactive
    log_path var/"log/mousekeys.log"
    error_log_path var/"log/mousekeys.log"
  end

  def caveats
    <<~EOS
      Start it (registers the login agent and runs it now):
        brew services start mousekeys

      First launch asks for Accessibility permission — a macOS requirement no
      installer can skip. Approve it once at:
        System Settings > Privacy & Security > Accessibility
      The daemon waits for the toggle and then starts automatically.

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
