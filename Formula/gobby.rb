require 'formula'

class Gobby < Formula
  homepage 'http://gobby.0x539.de'
  url 'http://releases.0x539.de/gobby/gobby-0.4.94.tar.gz'
  sha1 '921979da611601ee6e220e2396bd2c86f0fb8c66'

  head 'git://git.0x539.de/git/gobby.git'

  depends_on 'pkg-config' => :build
  depends_on 'intltool' => :build
  depends_on 'gtkmm'
  depends_on 'gsasl'
  depends_on 'libxml++'
  depends_on 'gtksourceview'
  depends_on 'gettext'
  depends_on 'hicolor-icon-theme'
  depends_on 'libinfinity'
  depends_on :x11

  def patches
    { :p0 => [ # Fix compilation on clang per MacPorts
      "https://trac.macports.org/export/101720/trunk/dports/x11/gobby/files/patch-code-util-config.hpp.diff"
    ]}
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end
end
