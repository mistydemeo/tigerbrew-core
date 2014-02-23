require 'formula'

# Use a mirror because of:
# http://lists.cairographics.org/archives/cairo/2012-September/023454.html

class Cairo < Formula
  homepage 'http://cairographics.org/'
  url 'http://cairographics.org/releases/cairo-1.12.16.tar.xz'
  mirror 'https://downloads.sourceforge.net/project/machomebrew/mirror/cairo-1.12.16.tar.xz'
  sha256 '2505959eb3f1de3e1841023b61585bfd35684b9733c7b6a3643f4f4cbde6d846'

  bottle do
    sha1 "fb623b0b06693dfb659c3dc87bd65d0285a9c0ed" => :mavericks
    sha1 "ae417942cd2b091d183cc02fdb1f70c11d836090" => :mountain_lion
    sha1 "d71a2ed86188601756a49c1dd7264636d90e3966" => :lion
  end

  keg_only :provided_pre_mountain_lion

  option :universal
  # Tiger's X11 is simply way too old
  option 'without-x', 'Build without X11 support' if MacOS.version > :tiger

  depends_on 'pkg-config' => :build
  depends_on 'xz'=> :build
  # harfbuzz requires cairo-ft to build
  depends_on :freetype
  depends_on :fontconfig
  depends_on :libpng
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
