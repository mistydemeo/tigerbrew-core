require 'formula'

class Abook < Formula
  homepage 'http://abook.sourceforge.net/'
  url 'https://downloads.sourceforge.net/abook/abook-0.5.6.tar.gz'
  sha1 '79f04f2264c8bd81bbc952b6560c86d69b21615d'

  devel do
    url 'https://abook.sourceforge.net/devel/abook-0.6.0pre2.tar.gz'
    sha1 '42a939fba43e51aa011fa185113c12ec4bc1e1ec'
  end

  depends_on 'readline'

  def patches
    if build.devel?
      # Remove `inline` from function implementation for clang compatibility
      DATA
    end
  end

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make install"
  end
end

__END__
diff --git a/database.c b/database.c
index 7c47ab6..53bdb9f 100644
--- a/database.c
+++ b/database.c
@@ -762,7 +762,7 @@ item_duplicate(list_item dest, list_item src)
  */
 
 /* quick lookup by "standard" field number */
-inline int
+int
 field_id(int i)
 {
 	assert((i >= 0) && (i < ITEM_FIELDS));
