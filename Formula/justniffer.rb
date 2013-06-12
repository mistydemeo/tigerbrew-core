require 'formula'

class Justniffer < Formula
  homepage 'http://justniffer.sourceforge.net/'
  url 'http://downloads.sourceforge.net/project/justniffer/justniffer/justniffer%200.5.11/justniffer_0.5.11.tar.gz'
  sha1 '3f3222361794a6f79f47567753550995c318a037'

  depends_on "boost"

  fails_with :clang do
    build 425
    cause <<-EOS.undent
          Symbols declared inline in headers are then expected by the linker.
          Probably declaring them static would fix it properly.
          EOS
  end

  # Patch lib/libnids-1.21_patched/configure.gnu so that CFLAGS and/or
  # CXXFLAGS with multiple words doesn't cause an error -- e.g.:
  #
  # === configuring in lib/libnids-1.21_patched
  # (/private/tmp/homebrew-justniffer-0.5.11-yNmj/justniffer-0.5.11/lib/libnids-1.21_patched)
  # configure: running /bin/sh ./configure.gnu --disable-option-checking
  # '--prefix=/usr/local/Cellar/justniffer/0.5.11'  'CXX=/usr/bin/llvm-g++'
  # 'CXXFLAGS=-O3 -w -pipe -march=core2 -msse4' 'CC=/usr/bin/llvm-gcc'
  # 'CFLAGS=-O3 -w -pipe -march=core2 -msse4' --cache-file=/dev/null--srcdir=.
  # configure: error: unrecognized option: `-w'
  # Try `./configure --help' for more information
  # configure: error: ./configure.gnu failed for lib/libnids-1.21_patched
  #
  # I submitted this patch to the upstream author, Oreste Notelli, on
  # 2011-12-22, so this patch will probably not be necessary with future
  # justniffer versions after 0.5.11.
  def patches
    DATA
  end

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end

  test do
    require 'open3'
    Open3.popen3("#{bin}/justniffer", "--version") do |_, stdout, _|
      assert_match /justniffer #{Regexp.escape(version)}/, stdout.read
    end
  end

  def caveats; <<-EOS.undent
    Sample invocation to get you started:
      justniffer -i en1 -p "port 80"

    "en1" is my wireless inteface; "en0" is Ethernet; see output of ifconfig
    EOS
  end
end


__END__
--- a/lib/libnids-1.21_patched/configure.gnu	2011-12-21 22:48:23.000000000 -0800
+++ b/lib/libnids-1.21_patched/configure.gnu	2011-12-21 22:54:37.000000000 -0800
@@ -1,3 +1,3 @@
 #!/bin/sh

-./configure --disable-libnet --disable-libglib $@
\ No newline at end of file
+./configure --disable-libnet --disable-libglib "$@"
