require 'formula'

class SqliteFunctions < Formula
  url 'http://www.sqlite.org/contrib/download/extension-functions.c?get=25', :using  => :nounzip
  sha1 'c68fa706d6d9ff98608044c00212473f9c14892f'
  version '2010-01-06'
end

class SqliteDocs < Formula
  url 'http://www.sqlite.org/2013/sqlite-doc-3071602.zip'
  version '3.7.16.2'
  sha1 '998df3d9ada4a4a8a048bcf20613d1d02be77731'
end

class Sqlite < Formula
  homepage 'http://sqlite.org/'
  url 'http://sqlite.org/2013/sqlite-autoconf-3071602.tar.gz'
  version '3.7.16.2'
  sha1 '85bf857cf86f34831d55d7ba97606dba581b8d62'

  depends_on 'readline' => :recommended

  option :universal
  option 'with-docs', 'Install HTML documentation'
  option 'without-rtree', 'Disable the R*Tree index module'
  option 'with-fts', 'Enable the FTS module'
  option 'with-functions', 'Enable more math and string functions for SQL queries'

  keg_only :provided_by_osx, "OS X already provides (an older) sqlite3."

  def install
    # sqlite segfaults on Tiger/PPC with our gcc-4.2
    # obviously we need a newer GCC stat!
    ENV.no_optimization if ENV.compiler == :gcc && MacOS.version == :tiger

    ENV.append 'CPPFLAGS', "-DSQLITE_ENABLE_RTREE" unless build.include? "without-rtree"
    ENV.append 'CPPFLAGS', "-DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS" if build.include? "with-fts"

    # enable these options by default
    ENV.append 'CPPFLAGS', "-DSQLITE_ENABLE_COLUMN_METADATA"
    ENV.append 'CPPFLAGS', "-DSQLITE_ENABLE_STAT3"

    # prevent 'undefined symbol _OSAtomicCompareAndSwapPtrBarrier' error
    # see: http://comments.gmane.org/gmane.comp.db.sqlite.general/71258
    ENV.append 'CPPFLAGS', "-DSQLITE_WITHOUT_ZONEMALLOC" if MacOS.version == :tiger

    ENV.universal_binary if build.universal?

    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking", "--enable-dynamic-extensions"
    system "make install"

    if build.include? "with-functions"
      SqliteFunctions.new.brew { mv 'extension-functions.c?get=25', buildpath/'extension-functions.c' }
      system ENV.cc, "-fno-common",
                     "-dynamiclib",
                     "extension-functions.c",
                     "-o", "libsqlitefunctions.dylib",
                     *ENV.cflags.split
      lib.install "libsqlitefunctions.dylib"
    end

    SqliteDocs.new.brew { doc.install Dir['*'] } if build.include? "with-docs"
  end

  def caveats
    if build.include? 'with-functions' then <<-EOS.undent
      Usage instructions for applications calling the sqlite3 API functions:

        In your application, call sqlite3_enable_load_extension(db,1) to
        allow loading external libraries.  Then load the library libsqlitefunctions
        using sqlite3_load_extension; the third argument should be 0.
        See http://www.sqlite.org/cvstrac/wiki?p=LoadableExtensions.
        Select statements may now use these functions, as in
        SELECT cos(radians(inclination)) FROM satsum WHERE satnum = 25544;

      Usage instructions for the sqlite3 program:

        If the program is built so that loading extensions is permitted,
        the following will work:
         sqlite> SELECT load_extension('#{lib}/libsqlitefunctions.dylib');
         sqlite> select cos(radians(45));
         0.707106781186548
      EOS
    end
  end
end
