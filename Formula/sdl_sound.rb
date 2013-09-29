require 'formula'

class SdlSound < Formula
  homepage 'http://icculus.org/SDL_sound/'
  url 'http://icculus.org/SDL_sound/downloads/SDL_sound-1.0.3.tar.gz'
  sha1 '1984bc20b2c756dc71107a5a0a8cebfe07e58cb1'

  head do
    url 'http://hg.icculus.org/icculus/SDL_sound', :using => :hg

    depends_on :automake
    depends_on :libtool
  end

  depends_on 'pkg-config' => :build
  depends_on 'sdl'
  depends_on 'flac' => :optional
  depends_on 'libmikmod' => :optional
  depends_on 'libogg' => :optional
  depends_on 'libvorbis' => :optional
  depends_on 'speex' => :optional
  depends_on 'physfs' => :optional

  def install
    if build.head?
      # Set the environment and call autoreconf, because boostrap.sh
      # uses /usr/bin/glibtoolize and a non-standard flag to automake.
      ENV['LIBTOOLIZE'] = 'glibtoolize'
      ENV['ACLOCAL'] = "aclocal -I #{HOMEBREW_PREFIX}/share/aclocal"
      ENV['AUTOMAKE'] = 'automake --foreign'
      system "autoreconf -ivf"
    end

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-sdltest"
    system "make"
    system "make check"
    system "make install"
  end
end
