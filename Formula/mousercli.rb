class Mousercli < Formula
  include Language::Python::Virtualenv

  desc "Headless CLI for Mouser"
  homepage "https://github.com/ravibrock/Mouser"
  license "MIT"
  head "https://github.com/ravibrock/Mouser.git", branch: "master"

  depends_on :macos
  depends_on "python@3.12"

  # native deps
  depends_on "hidapi"

  # rust-backed dep (rpds-py)
  depends_on "rust" => :build

  resource "attrs" do
    url "https://files.pythonhosted.org/packages/9a/8e/82a0fe20a541c03148528be8cac2408564a6c9a0cc7e9171802bc1d26985/attrs-26.1.0.tar.gz"
    sha256 "d03ceb89cb322a8fd706d4fb91940737b6642aa36998fe130a9bc96c985eff32"
  end

  resource "hidapi" do
    url "https://files.pythonhosted.org/packages/74/f6/caad9ed701fbb9223eb9e0b41a5514390769b4cb3084a2704ab69e9df0fe/hidapi-0.15.0.tar.gz"
    sha256 "ecbc265cbe8b7b88755f421e0ba25f084091ec550c2b90ff9e8ddd4fcd540311"
  end

  resource "jsonschema-specifications" do
    url "https://files.pythonhosted.org/packages/19/74/a633ee74eb36c44aa6d1095e7cc5569bebf04342ee146178e2d36600708b/jsonschema_specifications-2025.9.1.tar.gz"
    sha256 "b540987f239e745613c7a9176f3edb72b832a4ac465cf02712288397832b5e8d"
  end

  resource "jsonschema" do
    url "https://files.pythonhosted.org/packages/b3/fc/e067678238fa451312d4c62bf6e6cf5ec56375422aee02f9cb5f909b3047/jsonschema-4.26.0.tar.gz"
    sha256 "0c26707e2efad8aa1bfc5b7ce170f3fccc2e4918ff85989ba9ffa9facb2be326"
  end

  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/05/8e/961c0007c59b8dd7729d542c61a4d537767a59645b82a0b521206e1e25c2/pyyaml-6.0.3.tar.gz"
    sha256 "d76623373421df22fb4cf8817020cbb7ef15c725b9d5e45f17e189bfc384190f"
  end

  resource "pyobjc-core" do
    url "https://files.pythonhosted.org/packages/64/5a/6b15e499de73050f4a2c88fff664ae154307d25dc04da8fb38998a428358/pyobjc_core-12.1-cp312-cp312-macosx_10_13_universal2.whl"
    sha256 "818bcc6723561f207e5b5453efe9703f34bc8781d11ce9b8be286bb415eb4962"
  end

  resource "pyobjc-framework-Cocoa" do
    url "https://files.pythonhosted.org/packages/95/bf/ee4f27ec3920d5c6fc63c63e797c5b2cc4e20fe439217085d01ea5b63856/pyobjc_framework_cocoa-12.1-cp312-cp312-macosx_10_13_universal2.whl"
    sha256 "547c182837214b7ec4796dac5aee3aa25abc665757b75d7f44f83c994bcb0858"
  end

  resource "pyobjc-framework-Quartz" do
    url "https://files.pythonhosted.org/packages/e9/9b/780f057e5962f690f23fdff1083a4cfda5a96d5b4d3bb49505cac4f624f2/pyobjc_framework_quartz-12.1-cp312-cp312-macosx_10_13_universal2.whl"
    sha256 "7730cdce46c7e985535b5a42c31381af4aa6556e5642dc55b5e6597595e57a16"
  end

  resource "referencing" do
    url "https://files.pythonhosted.org/packages/22/f5/df4e9027acead3ecc63e50fe1e36aca1523e1719559c499951bb4b53188f/referencing-0.37.0.tar.gz"
    sha256 "44aefc3142c5b842538163acb373e24cce6632bd54bdb01b21ad5863489f50d8"
  end

  resource "rpds-py" do
    url "https://files.pythonhosted.org/packages/20/af/3f2f423103f1113b36230496629986e0ef7e199d2aa8392452b484b38ced/rpds_py-0.30.0.tar.gz"
    sha256 "dd8ff7cf90014af0c0f787eea34794ebf6415242ee1d6fa91eaba725cc441e84"
  end

  resource "typing-extensions" do
    url "https://files.pythonhosted.org/packages/72/94/1a15dd82efb362ac84269196e94cf00f187f7ed21c242792a923cdb1c61f/typing_extensions-4.15.0.tar.gz"
    sha256 "0cea48d173cc12fa28ecabc3b837ea3cf6f38c6d1136f85cbaaf598984861466"
  end

  def install
    venv_root = libexec/"venv"
    source_root = libexec/"src"
    venv = virtualenv_create(venv_root, "python3.12")

    python_resources = resources.to_a.reject do |resource|
      %w[pyobjc-core pyobjc-framework-Cocoa pyobjc-framework-Quartz].include?(resource.name)
    end
    venv.pip_install python_resources

    pyobjc_core_wheel = buildpath/"pyobjc_core-12.1-cp312-cp312-macosx_10_13_universal2.whl"
    pyobjc_cocoa_wheel = buildpath/"pyobjc_framework_cocoa-12.1-cp312-cp312-macosx_10_13_universal2.whl"
    pyobjc_quartz_wheel = buildpath/"pyobjc_framework_quartz-12.1-cp312-cp312-macosx_10_13_universal2.whl"
    cp resource("pyobjc-core").cached_download, pyobjc_core_wheel
    cp resource("pyobjc-framework-Cocoa").cached_download, pyobjc_cocoa_wheel
    cp resource("pyobjc-framework-Quartz").cached_download, pyobjc_quartz_wheel

    venv.pip_install pyobjc_core_wheel
    venv.pip_install pyobjc_cocoa_wheel
    venv.pip_install pyobjc_quartz_wheel

    source_root.install buildpath.children

    (bin/"mousercli").write <<~EOS
      #!/bin/bash
      export PYTHONPATH="#{source_root}:$PYTHONPATH"
      exec "#{venv_root}/bin/python" "#{source_root}/main_cli.py" "$@"
    EOS
    (bin/"mousercli").chmod 0555
  end

  test do
    output = shell_output("#{bin}/mousercli export")
    assert_match "\"profiles\"", output
  end
end
