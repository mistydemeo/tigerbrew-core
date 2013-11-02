require 'formula'

class Libgcrypt < Formula
  homepage 'http://gnupg.org/'
  url 'ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.5.3.tar.bz2'
  sha1 '2c6553cc17f2a1616d512d6870fe95edf6b0e26e'

  depends_on 'libgpg-error'

  option :universal

  fails_with :clang do
    build 77
    cause "basic test fails"
  end

  def patches
    if ENV.compiler == :clang and MacOS.clang_build_version < 500
      { :p0 => "https://trac.macports.org/export/85232/trunk/dports/devel/libgcrypt/files/clang-asm.patch" }
    end
  end

  def cflags
    cflags = ENV.cflags.to_s
    cflags += ' -std=gnu89 -fheinous-gnu-extensions' if ENV.compiler == :clang
    cflags
  end

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-asm",
                          "--with-gpg-error-prefix=#{HOMEBREW_PREFIX}"
    # Parallel builds work, but only when run as separate steps
    system "make", "CFLAGS=#{cflags}"
    system "make check"
    system "make install"
  end
end
