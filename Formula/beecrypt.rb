require "formula"

class Beecrypt < Formula
  homepage "http://beecrypt.sourceforge.net"
  url "https://downloads.sourceforge.net/project/beecrypt/beecrypt/4.2.1/beecrypt-4.2.1.tar.gz"
  sha256 "286f1f56080d1a6b1d024003a5fa2158f4ff82cae0c6829d3c476a4b5898c55d"
  revision 1

  bottle do
    cellar :any
    sha1 "8ccefc8dd0550ad157854be5217c9d3aebcd8275" => :mavericks
    sha1 "67e8a03aeab78969d859e4cb7fcdf44b37fe5966" => :mountain_lion
    sha1 "22a47abf61584481e5c3fa03de13fda568e046e1" => :lion
  end

  depends_on "icu4c"
  depends_on "libtool" => :build

  # fix build with newer clang, gcc 4.7 (https://bugs.gentoo.org/show_bug.cgi?id=413951)
  patch :p0, :DATA

  def install
    cp Dir["#{Formula["libtool"].opt_share}/libtool/config/config.*"], buildpath
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-openmp",
                          "--without-java",
                          "--without-python"
    system "make"
    system "make check"
    system "make install"
  end
end

__END__
--- include/beecrypt/c++/util/AbstractSet.h~	2009-06-17 13:05:55.000000000 +0200
+++ include/beecrypt/c++/util/AbstractSet.h	2012-06-03 17:45:55.229399461 +0200
@@ -56,7 +56,7 @@
 					if (c->size() != size())
 						return false;
 
-					return containsAll(*c);
+					return this->containsAll(*c);
 				}
 				return false;
 			}
