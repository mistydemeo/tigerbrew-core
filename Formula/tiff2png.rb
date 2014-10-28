require 'formula'

class Tiff2png < Formula
  homepage 'http://www.libpng.org/pub/png/apps/tiff2png.html'
  url 'ftp://ftp.simplesystems.org/pub/libpng/png/applications/tiff2png/tiff2png-0.91.tar.gz'
  sha1 '3a23abaaadbed8f3d13b88241257fe2078eb61fd'
  revision 1

  depends_on 'libtiff'
  depends_on 'libpng'
  depends_on 'jpeg'

  # libpng 1.5 no longer #includes zlib.h
  patch :DATA

  def install
    system "make", "-f", "Makefile.unx", "CC=#{ENV.cc}",
                                         "OPTIMFLAGS=#{ENV.cflags}",
                                         "LIBTIFF=#{HOMEBREW_PREFIX}/lib",
                                         "TIFFINC=#{HOMEBREW_PREFIX}/include",
                                         "LIBJPEG=#{HOMEBREW_PREFIX}/lib",
                                         "ZLIB=/usr/lib",
                                         "DEBUGFLAGS="
    bin.install 'tiff2png'
  end

  test do
    system "#{bin}/tiff2png", test_fixtures("test.tiff")
  end
end

__END__
diff --git a/tiff2png.c b/tiff2png.c
index 6a06571..f903c0c 100644
--- a/tiff2png.c
+++ b/tiff2png.c
@@ -87,6 +87,7 @@
 #  include "tiffcomp.h"		/* not installed by default */
 #endif
 #include "png.h"
+#include "zlib.h"
 
 #ifdef _MSC_VER   /* works for MSVC 5.0; need finer tuning? */
 #  define strcasecmp _stricmp

