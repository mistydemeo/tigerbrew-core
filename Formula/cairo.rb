require 'formula'

# Use a mirror because of:
# http://lists.cairographics.org/archives/cairo/2012-September/023454.html

class Cairo < Formula
  homepage 'http://cairographics.org/'
  url 'http://cairographics.org/releases/cairo-1.12.16.tar.xz'
  mirror 'https://downloads.sourceforge.net/project/machomebrew/mirror/cairo-1.12.16.tar.xz'
  sha256 '2505959eb3f1de3e1841023b61585bfd35684b9733c7b6a3643f4f4cbde6d846'
  revision 1

  bottle do
    sha1 "10638baaadb72abb460f2693019ad93f95b0c93a" => :mavericks
    sha1 "285f291b386d46d86bd6d0360f9f9121170d72bc" => :mountain_lion
    sha1 "a854c7d9c3cb0736ae09512384dc943425a29b43" => :lion
  end

  keg_only :provided_pre_mountain_lion

  option :universal
  # Tiger's X11 is simply way too old
  option 'without-x', 'Build without X11 support' if MacOS.version > :tiger

  depends_on 'pkg-config' => :build
  depends_on 'freetype'
  depends_on 'fontconfig'
  depends_on 'libpng'
  depends_on 'pixman'
  depends_on 'glib'
  depends_on :x11 if build.with? 'x'

  def install
    ENV.universal_binary if build.universal?

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-gobject=yes
    ]

    if build.without? 'x'
      args << '--enable-xlib=no' << '--enable-xlib-xrender=no'
    else
      args << '--with-x'
    end

    args << '--enable-xcb=no' if MacOS.version <= :leopard

    system "./configure", *args
    system "make install"
  end
end
