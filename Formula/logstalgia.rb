require 'formula'

class Logstalgia < Formula
  homepage 'http://code.google.com/p/logstalgia/'
  url 'https://logstalgia.googlecode.com/files/logstalgia-1.0.3.tar.gz'
  sha1 '9d5db0f3598291b3a7a10b8f4bff9f6164eccadc'

  head do
    url 'https://github.com/acaudwell/Logstalgia.git'

    depends_on :autoconf
    depends_on :automake
    depends_on :libtool
  end

  depends_on 'sdl'
  depends_on :freetype
  depends_on 'pkg-config' => :build
  depends_on 'ftgl'
  depends_on :libpng
  depends_on 'jpeg'
  depends_on 'sdl_image'
  depends_on 'pcre'

  def install
    # For non-/usr/local installs
    ENV.append "CXXFLAGS", "-I#{HOMEBREW_PREFIX}/include"

    # Handle building head.
    system "autoreconf -f -i" if build.head?

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make install"
  end
end
