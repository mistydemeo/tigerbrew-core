require 'formula'

class Libpar2 < Formula
  homepage 'http://parchive.sourceforge.net/'
  url 'https://downloads.sourceforge.net/project/parchive/libpar2/0.2/libpar2-0.2.tar.gz'
  sha1 '4b3da928ea6097a8299aadafa703fc6d59bdfb4b'

  def patches
    # Patch libpar2 - bugfixes and ability to cancel par2 repair
    "https://gist.github.com/raw/4576230/e722f2113195ee9b8ee67c1c424aa3f2085b1066/libpar2-0.2-nzbget.patch"
  end
end

class Nzbget < Formula
  homepage 'http://sourceforge.net/projects/nzbget/'
  url 'https://downloads.sourceforge.net/project/nzbget/nzbget-stable/12.0/nzbget-12.0.tar.gz'
  sha1 'b7f3037ca664f09c28ab359cf6091d876d63ba5f'

  head 'https://nzbget.svn.sourceforge.net/svnroot/nzbget/trunk'

  depends_on 'pkg-config' => :build
  depends_on 'libsigc++'

  fails_with :clang do
    build 500
    cause "Clang older than 5.1 requires flexible array members to be trivially destructible"
  end

  def install
    # Install libpar2 privately
    libpar2_prefix = libexec/'libpar2'
    Libpar2.new('libpar2').brew do
      system "./configure", "--disable-debug", "--disable-dependency-tracking",
                            "--prefix=#{libpar2_prefix}"
      system "make install"
    end

    # Tell configure where libpar2 is, and tell it to use OpenSSL
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-libpar2-includes=#{libpar2_prefix}/include",
                          "--with-libpar2-libraries=#{libpar2_prefix}/lib",
                          "--with-tlslib=OpenSSL"
    system "make"
    ENV.j1
    system "make install"
    system "make install-conf"
  end
end
