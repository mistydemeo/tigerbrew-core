require 'formula'

# Use a mirror because of:
# http://lists.cairographics.org/archives/cairo/2012-September/023454.html

class Cairo < Formula
  homepage 'http://cairographics.org/'
  url 'http://cairographics.org/releases/cairo-1.12.10.tar.xz'
  mirror 'http://ftp-nyc.osuosl.org/pub/gentoo/distfiles/cairo-1.12.10.tar.xz'
  mirror 'ftp://anduin.linuxfromscratch.org/BLFS/conglomeration/cairo/cairo-1.12.10.tar.xz'
  sha256 'f1581aef210f6caa9cf42875fb66ab3b47a32db9436bdfa9913b9bbd5034b03b'

  keg_only :provided_pre_mountain_lion

  option :universal
  option 'without-x', 'Build without X11 support'

  env :std if build.universal?

  depends_on :libpng
  depends_on 'pixman'
  depends_on 'pkg-config' => :build
  depends_on 'xz'=> :build
  depends_on 'glib' unless build.include? 'without-x'
  depends_on :x11 unless build.include? 'without-x'

  def install
    ENV.universal_binary if build.universal?

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]

    if build.include? 'without-x'
      args << '--enable-xlib=no' << '--enable-xlib-xrender=no'
    else
      args << '--with-x'
    end

    args << '--enable-xcb=no' if MacOS.version == :leopard

    system "./configure", *args
    system "make install"
  end
end
