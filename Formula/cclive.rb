require 'formula'

class Cclive < Formula
  homepage 'http://cclive.sourceforge.net/'
  url 'http://sourceforge.net/projects/cclive/files/0.7/cclive-0.7.12.tar.xz'
  sha1 'e921063f538032cf573793042b097cd35f1722f1'

  depends_on 'pkg-config' => :build
  depends_on 'xz' => :build
  depends_on 'quvi'
  depends_on 'boost'
  depends_on 'pcre'

  # Fix linking against Boost during configure. See:
  # https://trac.macports.org/ticket/29982
  def patches
    {:p0 =>
      "https://trac.macports.org/export/82481/trunk/dports/net/cclive/files/patch-configure.diff"
    }
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end
end
