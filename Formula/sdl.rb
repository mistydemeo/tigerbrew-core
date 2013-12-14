require 'formula'

class Sdl < Formula
  homepage 'http://www.libsdl.org/'
  url 'http://www.libsdl.org/release/SDL-1.2.15.tar.gz'
  sha1 '0c5f193ced810b0d7ce3ab06d808cbb5eef03a2c'

  head do
    url 'http://hg.libsdl.org/SDL', :branch => 'SDL-1.2', :using => :hg

    depends_on :autoconf
    depends_on :automake
    depends_on :libtool
  end

  option 'with-x11-driver', 'Compile with support for X11 video driver'
  option :universal

  if build.with? 'x11-driver'
    depends_on :x11
    depends_on :autoconf
    depends_on :automake
    depends_on :libtool
  end

  def patches
    p = []
    # Fix for a bug preventing SDL from building at all on OSX 10.9 Mavericks
    # Related ticket: https://bugzilla.libsdl.org/show_bug.cgi?id=2085
    p << "http://bugzilla-attachments.libsdl.org/attachment.cgi?id=1320" if MacOS.version >= :mavericks
    # Fix build against recent libX11; requires regenerating configure script
    p << "http://hg.libsdl.org/SDL/raw-rev/91ad7b43317a" if build.with? 'x11-driver'
    p
  end

  def install
    # we have to do this because most build scripts assume that all sdl modules
    # are installed to the same prefix. Consequently SDL stuff cannot be
    # keg-only but I doubt that will be needed.
    inreplace %w[sdl.pc.in sdl-config.in], '@prefix@', HOMEBREW_PREFIX

    ENV.universal_binary if build.universal?

    system "./autogen.sh" if build.head? or build.with? 'x11-driver'

    args = %W[--prefix=#{prefix}]
    args << "--disable-nasm" unless MacOS.version >= :mountain_lion # might work with earlier, might only work with new clang
    # LLVM-based compilers choke on the assembly code packaged with SDL.
    args << '--disable-assembly' if ENV.compiler == :llvm or (ENV.compiler == :clang and MacOS.clang_build_version < 421)
    args << "--without-x" if build.without? 'x11-driver'

    system './configure', *args
    system "make install"

    # Copy source files needed for Ojective-C support.
    libexec.install Dir["src/main/macosx/*"] unless build.head?
  end

  def test
    system "#{bin}/sdl-config", "--version"
  end
end
