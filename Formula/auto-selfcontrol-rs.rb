class AutoSelfcontrolRs < Formula
  desc "Allows installation of auto-selfcontrol-rs with Homebrew"
  homepage "https://github.com/AlexanderDickie/auto-selfcontrol-rs"
  head "https://github.com/AlexanderDickie/auto-selfcontrol-rs.git", branch: "master"

  depends_on "rust" => :build

  def install
    system "cargo", "build", "--release", "--bin", "auto-selfcontrol-rs"
    bin.install "target/release/auto-selfcontrol-rs" => "autosc"
  end

  def caveats
    <<~EOS
      You need to have SelfControl installed. If it is not, run:
        brew cask install selfcontrol
      On startup, run:
        autosc --write_example_config
      Then, edit ~/.config/auto-selfcontrol-rs/config.aoml to your liking and run:
        autosc --deploy
    EOS
  end
end
