# Generated for v1.0.0. Edits here are overwritten by the next release.
#
# No version stanza: Homebrew reads it from the archive names, and declaring
# it as well fails `brew audit --strict` as redundant.
class SgDr < Formula
  desc "Recover StackGuardian-managed infrastructure when StackGuardian is unavailable"
  homepage "https://github.com/StackGuardian/sg-dr"
  license "Apache-2.0"

  on_macos do
    on_intel do
      url "https://github.com/StackGuardian/sg-dr/releases/download/v1.0.0/sg-dr_1.0.0_darwin_amd64.tar.gz"
      sha256 "686606972d4fe960fb9c2196123b1905ab3831b519a51ef8ec968d55482a36c8"
    end
    on_arm do
      url "https://github.com/StackGuardian/sg-dr/releases/download/v1.0.0/sg-dr_1.0.0_darwin_arm64.tar.gz"
      sha256 "1f332c78dbc931328615ce316ed2c835f2c1aee27ce71bef31ca2b132c6f02bc"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/StackGuardian/sg-dr/releases/download/v1.0.0/sg-dr_1.0.0_linux_amd64.tar.gz"
      sha256 "3162a9a2b5e6cacfab9da54902a9afe383d162304f2ba103f208dfc67bfcca7e"
    end
    on_arm do
      url "https://github.com/StackGuardian/sg-dr/releases/download/v1.0.0/sg-dr_1.0.0_linux_arm64.tar.gz"
      sha256 "ac9d2fdd1a27f664eb31a91eca40d12bfe0543049c7e66a5fca7d5c1997c5ee3"
    end
  end

  def install
    bin.install "sg-dr"
  end

  test do
    assert_match "sg-dr #{version}", shell_output("#{bin}/sg-dr --version")

    # Recovery cannot proceed without an organization, and saying so is the
    # behaviour worth testing: it proves the binary runs and parses flags.
    assert_match "no organization",
                 shell_output("#{bin}/sg-dr recover 2>&1", 1)
  end
end
