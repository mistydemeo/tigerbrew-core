require 'formula'

class Gtkx3 < Formula
  homepage 'http://gtk.org/'
  url 'http://ftp.gnome.org/pub/gnome/sources/gtk+/3.10/gtk+-3.10.5.tar.xz'
  sha256 '3191f6d8e8cdf0bac1a8ed6388acc67a15acf5e276161c9b93a305938d29ccc7'

  depends_on :x11 => '2.5' # needs XInput2, introduced in libXi 1.3
  depends_on 'pkg-config' => :build
  depends_on 'xz' => :build
  depends_on 'glib'
  depends_on 'jpeg'
  depends_on 'libtiff'
  depends_on 'gdk-pixbuf'
  depends_on 'pango'
  depends_on 'cairo' => 'with-glib'
  depends_on 'jasper' => :optional
  depends_on 'atk'
  depends_on 'at-spi2-atk'
  depends_on 'gobject-introspection'

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

  def test
    system "#{bin}/gtk3-demo"
  end
end
