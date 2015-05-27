class Fontforge < Formula
  homepage "https://fontforge.github.io"
  url "https://github.com/fontforge/fontforge/archive/20150430.tar.gz"
  sha256 "430c6d02611c7ca948df743e9241994efe37eda25f81a94aeadd9b6dd286ff37"
  head "https://github.com/fontforge/fontforge.git"

  bottle do
    sha256 "db55b0a73b4851077da8dfd48c39675f05eaf437323acccf56602779b21cf414" => :yosemite
    sha256 "dd876ff9dc19e6a1dba1a83cc1d9c106813a08f98675543359d99b14b2691510" => :mavericks
    sha256 "bf152c19b04f3ad0ba87e179dfe0bba44c9c770def473698603d9a831f9b3ef0" => :mountain_lion
  end

  option "with-giflib", "Build with GIF support"
  option "with-extra-tools", "Build with additional font tools"

  deprecated_option "with-x" => "with-x11"
  deprecated_option "with-gif" => "with-giflib"

  # Autotools are required to build from source in all releases.
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkg-config" => :build
  depends_on "libtool" => :run
  depends_on "gettext"
  depends_on "pango"
  depends_on "zeromq"
  depends_on "czmq"
  depends_on "cairo"
  depends_on "libpng" => :recommended
  depends_on "jpeg" => :recommended
  depends_on "libtiff" => :recommended
  depends_on "giflib" => :optional
  depends_on "libspiro" => :optional
  depends_on :x11 => :optional
  depends_on :python if MacOS.version <= :snow_leopard

  # This may be causing font-display glitches and needs further isolation & fixing.
  # https://github.com/fontforge/fontforge/issues/2083
  # https://github.com/Homebrew/homebrew/issues/37803
  depends_on "fontconfig"

  fails_with :llvm do
    build 2336
    cause "Compiling cvexportdlg.c fails with error: initializer element is not constant"
  end

  def install
    if MacOS.version <= :snow_leopard || !build.bottle?
      pydir = "#{%x(python-config --prefix).chomp}"
    else
      pydir = "#{%x(/usr/bin/python-config --prefix).chomp}"
    end

    args = %W[
      --prefix=#{prefix}
      --disable-silent-rules
      --disable-dependency-tracking
      --with-pythonbinary=#{pydir}/bin/python2.7
    ]

    if build.with? "x11"
      args << "--with-x"
    else
      args << "--without-x"
    end

    args << "--without-libpng" if build.without? "libpng"
    args << "--without-libjpeg" if build.without? "jpeg"
    args << "--without-libtiff" if build.without? "libtiff"
    args << "--without-giflib" if build.without? "giflib"
    args << "--without-libspiro" if build.without? "libspiro"

    # Fix linker error; see: https://trac.macports.org/ticket/25012
    ENV.append "LDFLAGS", "-lintl"

    # Reset ARCHFLAGS to match how we build
    ENV["ARCHFLAGS"] = "-arch #{MacOS.preferred_arch}"

    # And for finding the correct Python, not always Homebrew's.
    ENV.prepend "CFLAGS", "-I#{pydir}/include"
    ENV.prepend "LDFLAGS", "-L#{pydir}/lib"
    ENV.prepend_path "PKG_CONFIG_PATH", "#{pydir}/lib/pkgconfig"

    # Bootstrap in every build: https://github.com/fontforge/fontforge/issues/1806
    system "./bootstrap"
    system "./configure", *args
    system "make"
    system "make", "install"

    if build.with? "extra-tools"
      cd "contrib/fonttools" do
        system "make"
        bin.install Dir["*"].select { |f| File.executable? f }
      end
    end

    # The name is case-sensitive. Don't downcase it when linking.
    ln_s "#{share}/fontforge/osx/FontForge.app", prefix if build.with? "x11"
  end

  test do
    system bin/"fontforge", "-version"
  end
end
