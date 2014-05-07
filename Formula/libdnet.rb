require 'formula'

class Libdnet < Formula
  homepage 'http://code.google.com/p/libdnet/'
  url 'https://libdnet.googlecode.com/files/libdnet-1.12.tgz'
  sha1 '71302be302e84fc19b559e811951b5d600d976f8'

  bottle do
    sha1 "6b1bda90b59e20c8a5243d975ae0d948658cd7ff" => :mavericks
    sha1 "cf3cba764f268c117459cd55a95197d6ff5afd7b" => :mountain_lion
    sha1 "a3ec593982b554c90c23ac4c9a8192e5683b28ea" => :lion
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on :python => :optional

  # Fix use of deprecated macros
  # http://code.google.com/p/libdnet/issues/detail?id=27
  patch :DATA

  def install
    # autoreconf to get '.dylib' extension on shared lib
    ENV.append_path "ACLOCAL_PATH", "config"
    system "autoreconf", "-ivf"

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --mandir=#{man}
    ]
    args << "--with-python" if build.with? "python"
    system "./configure", *args
    system "make install"
  end
end


__END__
diff --git a/configure.in b/configure.in
index 72ac63c..109dc63 100644
--- a/configure.in
+++ b/configure.in
@@ -10,7 +10,7 @@ AC_CONFIG_AUX_DIR(config)
 AC_SUBST(ac_aux_dir)
 
 AM_INIT_AUTOMAKE(libdnet, 1.12)
-AM_CONFIG_HEADER(include/config.h)
+AC_CONFIG_HEADERS(include/config.h)
 
 dnl XXX - stop the insanity!@#$
 AM_MAINTAINER_MODE
