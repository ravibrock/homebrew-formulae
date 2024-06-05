class Bdcli < Formula
  desc "BetterDiscord CLI installer"
  homepage "https://github.com/BetterDiscord/cli"
  head "https://github.com/BetterDiscord/cli.git", branch: "main"

  depends_on "go" => :build

  def install
    system "go", "build", "-o", "bdcli"
    bin.install "bdcli"
  end

  def caveats
    <<~EOS
      You need to have BetterDiscord installed. If it is not, run:
        brew install betterdiscord-installer
    EOS
  end
end
