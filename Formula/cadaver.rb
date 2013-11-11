require 'formula'

class Cadaver < Formula
  homepage 'http://www.webdav.org/cadaver/'
  url 'http://www.webdav.org/cadaver/cadaver-0.23.3.tar.gz'
  sha1 '4ad8ea2341b77e7dee26b46e4a8a496f1a2962cd'

  depends_on 'pkg-config' => :build
  depends_on 'gettext'
  depends_on 'readline'
  depends_on 'neon'

  def patches
    # enable build with the latest neon 0.30
    DATA
  end

  def install
    neon_prefix = Formula.factory('neon').opt_prefix

    system "./configure", "--prefix=#{prefix}",
                          "--with-neon=#{neon_prefix}",
                          "--with-ssl"
    cd 'lib/intl' do
      system "make"
    end
    system "make install"
  end
end

__END__
--- cadaver-0.23.3-orig/configure	2009-12-16 01:36:26.000000000 +0300
+++ cadaver-0.23.3/configure	2013-11-04 22:44:00.000000000 +0400
@@ -10328,7 +10328,7 @@
 $as_echo "$ne_cv_lib_neon" >&6; }
     if test "$ne_cv_lib_neon" = "yes"; then
        ne_cv_lib_neonver=no
-       for v in 27 28 29; do
+       for v in 27 28 29 30; do
           case $ne_libver in
           0.$v.*) ne_cv_lib_neonver=yes ;;
           esac
@@ -10975,8 +10975,8 @@
     fi
 
 else
-    { $as_echo "$as_me:$LINENO: incompatible neon library version $ne_libver: wanted 0.27 28 29" >&5
-$as_echo "$as_me: incompatible neon library version $ne_libver: wanted 0.27 28 29" >&6;}
+    { $as_echo "$as_me:$LINENO: incompatible neon library version $ne_libver: wanted 0.27 28 29 30" >&5
+$as_echo "$as_me: incompatible neon library version $ne_libver: wanted 0.27 28 29 30" >&6;}
     neon_got_library=no
 fi
 
