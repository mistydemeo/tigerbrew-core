require 'formula'

class Pygtkglext < Formula
  homepage 'http://projects.gnome.org/gtkglext/download.html#pygtkglext'
  url 'http://downloads.sourceforge.net/gtkglext/pygtkglext-1.1.0.tar.gz'
  sha1 '2ae3e87e8cdfc3318d8ff0e33b344377cb3df7cb'

  depends_on 'pkg-config' => :build
  depends_on :python
  depends_on 'pygtk'
  depends_on 'gtkglext'
  depends_on 'pygobject'

  def install
    ENV['PYGTK_CODEGEN'] = Formula.factory('pygobject').opt_prefix/'bin/pygobject-codegen-2.0'
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end

  def caveats
    python.standard_caveats if python
  end

  test do
    python do
      system python, "-c", "import pygtk", "pygtk.require('2.0')", "import gtk.gtkgl"
    end
  end
end
