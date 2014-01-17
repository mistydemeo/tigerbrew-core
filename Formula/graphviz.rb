require 'formula'

class Graphviz < Formula
  homepage 'http://graphviz.org/'
  url 'http://graphviz.org/pub/graphviz/stable/SOURCES/graphviz-2.34.0.tar.gz'
  sha1 '5a0c00bebe7f4c7a04523db21f40966dc9f0d441'

  devel do
    url 'http://graphviz.org/pub/graphviz/development/SOURCES/graphviz-2.35.20131215.0545.tar.gz'
    sha1 '6eb9c3b6f842ae094feaa37a3e91c8d572b72e38'
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
  depends_on 'pango' if build.include? 'with-pangocairo'
  depends_on 'swig' if build.include? 'with-bindings'
  depends_on 'gts' => :optional
  depends_on :freetype if build.include? 'with-freetype' or MacOS::X11.installed?
  depends_on :x11 if build.include? 'with-x' or MacOS::X11.installed?
  depends_on :xcode if build.include? 'with-app'

  fails_with :clang do
    build 318
  end

  def patches
    p = {:p0 =>
      "https://trac.macports.org/export/103168/trunk/dports/graphics/graphviz/files/patch-project.pbxproj.diff",
     }

     # The following patch is already upstream and can be removed in the next release.
     if build.stable?
       p[:p1] = "https://gist.github.com/mvertes/7929246/raw/2093e77bbed7ca0f4092f478cae870e021cbe5af/graphviz-2.34.0-dotty-patch"
     end
     return p
  end

  def install
    ENV.universal_binary if build.universal?
    args = ["--disable-debug",
            "--disable-dependency-tracking",
            "--prefix=#{prefix}",
            "--without-qt",
            "--with-quartz"]
    args << "--with-gts" if build.with? 'gts'
    args << "--disable-swig" unless build.include? 'with-bindings'
    args << "--without-pangocairo" unless build.include? 'with-pangocairo'
    args << "--without-freetype2" unless build.include? 'with-freetype' or MacOS::X11.installed?
    args << "--without-x" unless build.include? 'with-x' or MacOS::X11.installed?

    system "./configure", *args
    system "make install"

    if build.include? 'with-app'
      cd "macosx" do
        system "xcodebuild", "-configuration", "Release", "SYMROOT=build", "PREFIX=#{prefix}", "ONLY_ACTIVE_ARCH=YES"
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

  def caveats
    if build.include? 'with-app'
      <<-EOS
        Graphviz.app was installed in:
          #{prefix}

        To symlink into ~/Applications, you can do:
          brew linkapps
        EOS
    end
  end
end
