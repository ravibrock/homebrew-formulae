class Mousercli < Formula
  include Language::Python::Virtualenv

  desc "Headless CLI for Mouser"
  homepage "https://github.com/ravibrock/Mouser"
  license "MIT"
  head "https://github.com/ravibrock/Mouser.git", branch: "master"

  depends_on "python@3.12"
  depends_on "hidapi"

  def install
    odie "mousercli is macOS-only" unless OS.mac?

    virtualenv_create(libexec, "python3.12")

    system libexec/"bin/python", "-m", "pip", "install", "-r", buildpath/"requirements.txt"

    libexec.install "main_cli.py", "core"

    (bin/"mouser").write_env_script libexec/"bin/python",
      "#{libexec}/main_cli.py"
  end
end
