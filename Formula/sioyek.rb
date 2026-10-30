class Sioyek < Formula
  desc "PDF viewer with a focus on technical books and research papers"
  homepage "https://github.com/ahrm/sioyek"
  license "GPL-3.0-only"
  head "https://github.com/ahrm/sioyek.git", branch: "development"

  depends_on "pkg-config" => :build
  depends_on :macos
  depends_on "qt"

  def install
    cd "mupdf" do
      system "make", "HAVE_GLUT=no", "build=release", "-j#{ENV.make_jobs}"
    end

    inreplace "pdf_viewer_build_config.pro",
              /QMAKE_MACOSX_DEPLOYMENT_TARGET = \d+/,
              "QMAKE_MACOSX_DEPLOYMENT_TARGET = #{MacOS.version.major}"

    system "qmake", "CONFIG+=non_portable", "pdf_viewer_build_config.pro"
    system "make", "-j#{ENV.make_jobs}"

    resources = "sioyek.app/Contents/Resources"
    cp_r "pdf_viewer/shaders", "#{resources}/shaders"
    cp %w[
      pdf_viewer/prefs.config
      pdf_viewer/prefs_user.config
      pdf_viewer/keys.config
      pdf_viewer/keys_user.config
      tutorial.pdf
    ], resources

    prefix.install "sioyek.app"
    bin.write_exec_script prefix/"sioyek.app/Contents/MacOS/sioyek"
  end

  def caveats
    <<~EOS
      To make sioyek available in /Applications, run:
        ln -sf #{opt_prefix}/sioyek.app /Applications/sioyek.app
    EOS
  end

  test do
    assert_match "sioyek", shell_output("#{bin}/sioyek --version")
  end
end
