require 'formula'

class SnowLeopardOrOlder < Requirement
  fatal true
  def satisfied?
    MacOS.version <= :snow_leopard
  end

  def message; <<-EOS.undent
    This version of ld64 will only build on 10.6 and older.
    It is provided for older versions of OS X.
    EOS
  end
end

class Ld64 < Formula
  homepage 'http://opensource.apple.com/'
  # Latest is 134.9, but it no longer supports building for PPC.
  # 127.2 won't build on Tiger, at least without some patching.
  # Leopard users: if you like, add a 127.2 option or fix the build
  # on Tiger.
  #
  url 'http://opensource.apple.com/tarballs/ld64/ld64-97.17.tar.gz'
  sha1 '7c1d816c2fec02e558f4a528d16d8161f0e379b5'

  resource "makefile" do
    url "https://trac.macports.org/export/123511/trunk/dports/devel/ld64/files/Makefile-97", :using => :nounzip
    sha1 "581688eb31a44b406dfb7476a770d2cff190f2bd"
  end

  depends_on SnowLeopardOrOlder

  # Tiger either includes old versions of these headers,
  # or doesn't ship them at all
  depends_on 'cctools-headers' => :build
  depends_on 'dyld-headers' => :build
  depends_on 'libunwind-headers' => :build

  keg_only :provided_by_osx,
    "ld64 is an updated version of the ld shipped by Apple."

  fails_with :gcc_4_0 do
    build 5370
  end

  # Fixes logic on PPC branch islands
  patch :p0 do
    url "https://trac.macports.org/export/103948/trunk/dports/devel/ld64/files/ld64-97-ppc-branch-island.patch"
    sha1 "e3f42a52e201a40272ca29119bced50a270659b8"
  end

  # Remove LTO support
  patch :p0 do
    url "https://trac.macports.org/export/103949/trunk/dports/devel/ld64/files/ld64-97-no-LTO.patch"
    sha1 "3a6f482f87c08ac6135b7a36fdb131d82daf9ea1"
  end

  # Fix version number
  patch :p0 do
    url "https://trac.macports.org/export/103951/trunk/dports/devel/ld64/files/ld64-version.patch"
    sha1 "42a15f2bd7de9b01d24dba8744cd4a36a2dec87b"
  end

  def install
    buildpath.install resource("makefile")
    mv "Makefile-97", "Makefile"
    inreplace 'src/ld/Options.cpp', '@@VERSION@@', version

    if MacOS.version < :leopard
      # No CommonCrypto
      inreplace 'src/ld/MachOWriterExecutable.hpp' do |s|
        s.gsub! '<CommonCrypto/CommonDigest.h>', '<openssl/md5.h>'
        s.gsub! 'CC_MD5', 'MD5'
      end

      inreplace 'Makefile', "-Wl,-exported_symbol,__mh_execute_header", ""
    end

    args = %W[
      CC=#{ENV.cc}
      CXX=#{ENV.cxx}
      OTHER_CPPFLAGS=#{ENV.cppflags}
      OTHER_LDFLAGS=#{ENV.ldflags}
    ]

    args << 'RC_SUPPORTED_ARCHS="armv6 armv7 i386 x86_64"' if MacOS.version >= :lion
    args << "OTHER_LDFLAGS_LD64=-lcrypto" if MacOS.version < :leopard

    # Macports makefile hardcodes optimization
    inreplace 'Makefile' do |s|
      s.change_make_var! 'CFLAGS', ENV.cflags
      s.change_make_var! 'CXXFLAGS', ENV.cxxflags
    end

    system "make", *args
    system "make", "install", "PREFIX=#{prefix}"
  end
end
