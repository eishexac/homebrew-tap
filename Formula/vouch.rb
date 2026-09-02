# Homebrew formula for vouch. This is the canonical copy; at release it is
# published to github.com/eishexac/homebrew-tap as Formula/vouch.rb with the
# sha256 of the tagged tarball filled in. Install layout matches what
# bin/vouch resolves (bin + lib/vouch + share/vouch); the launcher follows
# its own symlink to find them.
class Vouch < Formula
  desc "SSH certificate authority for a server fleet"
  homepage "https://github.com/eishexac/vouch"
  url "https://github.com/eishexac/vouch/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "be7a51b9fcbd0fb1fcb281d9207bf7f8216d8670683a41f09b4f573f5768b424"
  license "GPL-2.0-only"

  depends_on "step" # the step CLI, for `step ssh login` + bootstrap on devices

  def install
    bin.install "bin/vouch"
    (lib/"vouch").install Dir["libexec/vouch/*"]
    (share/"vouch").install "share/vouch/config.example", "VERSION"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/vouch version").strip
  end
end
