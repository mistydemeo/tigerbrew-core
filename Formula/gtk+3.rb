require 'formula'

class Gtkx3 < Formula
  homepage 'http://gtk.org/'
  url 'http://ftp.gnome.org/pub/gnome/sources/gtk+/3.14/gtk+-3.14.0.tar.xz'
  sha256 '68d6b57d15c16808d0045e96b303f3dd439cc22a9c06fdffb07025cd713a82bc'

  bottle do
    sha1 "bfe498bdaca8659ef6a980336eebd3b5c2bbf3ab" => :mavericks
    sha1 "242ee85238ebd48a20509d2352c8c02a07f01f9e" => :mountain_lion
    sha1 "579061b56ed5f3fb1efe0cb9cea03ef3d2ecc62e" => :lion
  end

  depends_on :x11 => '2.5' # needs XInput2, introduced in libXi 1.3
  depends_on :macos => :leopard # Tiger's X11 is too old
  depends_on 'pkg-config' => :build
  depends_on 'glib'
  depends_on 'jpeg'
  depends_on 'libtiff'
  depends_on 'gdk-pixbuf'
  depends_on 'pango'
  depends_on 'cairo'
  depends_on 'jasper' => :optional
  depends_on 'atk'
  depends_on 'at-spi2-atk'
  depends_on 'gobject-introspection'
  depends_on 'gsettings-desktop-schemas' => :recommended

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-glibtest",
                          "--enable-introspection=yes",
                          "--enable-x11-backend",
                          "--disable-schemas-compile"
    system "make install"
    # Prevent a conflict between this and Gtk+2
    mv bin/'gtk-update-icon-cache', bin/'gtk3-update-icon-cache'
  end

  def post_install
    system "#{Formula["glib"].opt_bin}/glib-compile-schemas", "#{HOMEBREW_PREFIX}/share/glib-2.0/schemas"
  end
end
