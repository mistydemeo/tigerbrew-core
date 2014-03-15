require 'formula'

class Pygobject < Formula
  homepage 'http://live.gnome.org/PyGObject'
  url 'http://ftp.gnome.org/pub/GNOME/sources/pygobject/2.28/pygobject-2.28.6.tar.bz2'
  sha1 '4eda7d2b97f495a2ad7d4cdc234d08ca5408d9d5'

  depends_on 'pkg-config' => :build
  depends_on 'glib'
  depends_on :python

  option :universal

  # https://bugzilla.gnome.org/show_bug.cgi?id=668522
  patch do
    url "http://git.gnome.org/browse/pygobject/patch/gio/gio-types.defs?id=42d01f060c5d764baa881d13c103d68897163a49"
    sha1 "20e39f1e0b6631ac81e0776d13f2b5403e991d0a"
  end

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-introspection"
    system "make install"
  end
end
