require 'formula'

class Cyassl < Formula
  homepage 'http://yassl.com/yaSSL/Products-cyassl.html'
  url 'https://github.com/cyassl/cyassl/archive/v2.7.2.tar.gz'
  sha256 '4321a0d1cc60fd0a5cbbf3762d8e0c6b0577a0372799e6f450ed3695b140320d'

  head 'https://github.com/cyassl/cyassl.git'

  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'libtool' => :build

  fails_with :clang

  def install
    args = %W[--infodir=#{info}
              --mandir=#{man}
              --prefix=#{prefix}
              --disable-bump
              --disable-fortress
              --disable-ntru
              --disable-sniffer
              --disable-webserver
              --enable-aesccm
              --enable-aesgcm
              --enable-blake2
              --enable-camellia
              --enable-certgen
              --enable-crl
              --enable-crl-monitor
              --enable-dtls
              --enable-ecc
              --enable-filesystem
              --enable-hc128
              --enable-inline
              --enable-keygen
              --enable-md4
              --enable-ocsp
              --enable-opensslextra
              --enable-psk
              --enable-rabbit
              --enable-ripemd
              --enable-sha512
              --enable-sni
    ]

    if MacOS.prefer_64_bit?
      args << '--enable-fastmath' << '--enable-fasthugemath'
    else
      args << '--disable-fastmath' << '--disable-fasthugemath'
    end

    # Extra flag is stated as a needed for the Mac platform.
    # http://yassl.com/yaSSL/Docs-cyassl-manual-2-building-cyassl.html
    # Also, only applies if fastmath is enabled.
    ENV.append_to_cflags '-mdynamic-no-pic' if MacOS.prefer_64_bit?

    # No public release available, Git tag is therefore used.
    system "autoreconf --verbose --install --force"
    system "./configure", *args

    system "make"
    system "make install"
  end
end
