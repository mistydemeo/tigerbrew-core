require 'formula'

class Hunspell < Formula
  homepage 'http://hunspell.sourceforge.net/'
  url 'http://downloads.sourceforge.net/hunspell/hunspell-1.3.2.tar.gz'
  sha1 '902c76d2b55a22610e2227abc4fd26cbe606a51c'

  depends_on 'readline'

  def patches
    # hunspell does not prepend $HOME to all USEROODIRs
    # http://sourceforge.net/p/hunspell/bugs/236/
    { :p0 => DATA }
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-ui",
                          "--with-readline"
    system "make"
    ENV.deparallelize
    system "make install"
  end
end

__END__
--- src/tools/hunspell.cxx.old	2013-08-02 18:21:49.000000000 +0200
+++ src/tools/hunspell.cxx	2013-08-02 18:20:27.000000000 +0200
@@ -28,7 +28,7 @@
 #ifdef WIN32
 
 #define LIBDIR "C:\\Hunspell\\"
-#define USEROOODIR "Application Data\\OpenOffice.org 2\\user\\wordbook"
+#define USEROOODIR { "Application Data\\OpenOffice.org 2\\user\\wordbook" }
 #define OOODIR \
     "C:\\Program files\\OpenOffice.org 2.4\\share\\dict\\ooo\\;" \
     "C:\\Program files\\OpenOffice.org 2.3\\share\\dict\\ooo\\;" \
@@ -65,11 +65,11 @@
     "/usr/share/myspell:" \
     "/usr/share/myspell/dicts:" \
     "/Library/Spelling"
-#define USEROOODIR \
-    ".openoffice.org/3/user/wordbook:" \
-    ".openoffice.org2/user/wordbook:" \
-    ".openoffice.org2.0/user/wordbook:" \
-    "Library/Spelling"
+#define USEROOODIR { \
+    ".openoffice.org/3/user/wordbook:", \
+    ".openoffice.org2/user/wordbook:", \
+    ".openoffice.org2.0/user/wordbook:", \
+    "Library/Spelling" }
 #define OOODIR \
     "/opt/openoffice.org/basis3.0/share/dict/ooo:" \
     "/usr/lib/openoffice.org/basis3.0/share/dict/ooo:" \
@@ -1664,7 +1664,10 @@
 	path = add(path, PATHSEP);          // <- check path in root directory
 	if (getenv("DICPATH")) path = add(add(path, getenv("DICPATH")), PATHSEP);
 	path = add(add(path, LIBDIR), PATHSEP);
-	if (HOME) path = add(add(add(add(path, HOME), DIRSEP), USEROOODIR), PATHSEP);
+  const char* userooodir[] = USEROOODIR;
+  for (int i = 0; i < (sizeof(userooodir) / sizeof(userooodir[0])); i++) {
+    if (HOME) path = add(add(add(add(path, HOME), DIRSEP), userooodir[i]), PATHSEP);
+  }
 	path = add(path, OOODIR);
 
 	if (showpath) {
