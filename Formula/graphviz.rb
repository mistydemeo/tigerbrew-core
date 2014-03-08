require 'formula'

class Graphviz < Formula
  homepage 'http://graphviz.org/'
  url 'http://graphviz.org/pub/graphviz/stable/SOURCES/graphviz-2.36.0.tar.gz'
  sha1 'a41e9f1cbcc9a24651e14dd15a4cda3d912d7d19'

  devel do
    url 'http://graphviz.org/pub/graphviz/development/SOURCES/graphviz-2.37.20140227.0545.tar.gz'
    sha1 'a0e05602d5c81baff936e0d2bf21ed255c3586db'
  end

  # To find Ruby and Co.
  env :std

  option :universal
  option 'with-bindings', 'Build Perl/Python/Ruby/etc. bindings'
  option 'with-pangocairo', 'Build with Pango/Cairo for alternate PDF output'
  option 'with-freetype', 'Build with FreeType support'
  option 'with-x', 'Build with X11 support'
  option 'with-app', 'Build GraphViz.app (requires full XCode install)'
  option 'with-gts', 'Build with GNU GTS support (required by prism)'

  depends_on :libpng

  depends_on 'pkg-config' => :build
  depends_on 'pango' if build.with? "pangocairo"
  depends_on 'swig' if build.with? "bindings"
  depends_on 'gts' => :optional
  depends_on "librsvg" => :optional
  depends_on :freetype if build.with? "freetype" or MacOS::X11.installed?
  depends_on :x11 if build.with? "x" or MacOS::X11.installed?
  depends_on :xcode if build.with? "app"

  fails_with :clang do
    build 318
  end

  def patches
    p = {:p0 =>
      "https://trac.macports.org/export/103168/trunk/dports/graphics/graphviz/files/patch-project.pbxproj.diff",
     }
  end

  def install
    ENV.universal_binary if build.universal?
    args = ["--disable-debug",
            "--disable-dependency-tracking",
            "--prefix=#{prefix}",
            "--without-qt",
            "--with-quartz"]
    args << "--with-gts" if build.with? 'gts'
    args << "--disable-swig" if build.without? "bindings"
    args << "--without-pangocairo" if build.without? "pangocairo"
    args << "--without-freetype2" if build.without? "freetype" or MacOS::X11.installed?
    args << "--without-x" if build.without? "x" or MacOS::X11.installed?
    args << "--without-rsvg" if build.without? "librsvg"

    system "./configure", *args
    system "make install"

    if build.with? "app"
      cd "macosx" do
        xcodebuild "-configuration", "Release", "SYMROOT=build", "PREFIX=#{prefix}", "ONLY_ACTIVE_ARCH=YES"
      end
      prefix.install "macosx/build/Release/Graphviz.app"
    end

    (bin+'gvmap.sh').unlink
  end

  test do
    (testpath/'sample.dot').write <<-EOS.undent
    digraph G {
      a -> b
    }
    EOS

    system "#{bin}/dot", "-Tpdf", "-o", "sample.pdf", "sample.dot"
  end
end
