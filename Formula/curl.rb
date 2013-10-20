require 'formula'

class Curl < Formula
  homepage 'http://curl.haxx.se/'
  url 'http://curl.haxx.se/download/curl-7.33.0.tar.gz'
  mirror 'ftp://ftp.sunet.se/pub/www/utilities/curl/curl-7.33.0.tar.gz'
  sha256 '7450a9c72bd27dd89dc6996aeadaf354fa49bc3c05998d8507e4ab29d4a95172'

  keg_only :provided_by_osx,
    "The libcurl shipped before Snow Leopard is too old for CouchDB to use."

  option 'with-ssh', 'Build with scp and sftp support'
  option 'with-ares', 'Build with C-Ares async DNS support'
  option 'with-ssl', 'Build with Homebrew OpenSSL instead of the system version'
  option 'with-darwinssl', 'Build with Secure Transport for SSL support'

  depends_on 'pkg-config' => :build

  depends_on 'libmetalink' => :optional
  depends_on 'libssh2' if build.with? 'ssh'
  depends_on 'c-ares' if build.with? 'ares'
  depends_on 'openssl' if build.with?('ssl') || MacOS.version < :snow_leopard
  depends_on 'curl-ca-bundle' if MacOS.version < :snow_leopard

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]

    args << "--with-libssh2" if build.with? 'ssh'
    args << "--with-libmetalink" if build.with? 'libmetalink'
    args << "--enable-ares=#{Formula.factory("c-ares").opt_prefix}" if build.with? 'ares'
    args << "--with-ssl=#{Formula.factory("openssl").opt_prefix}" if build.with?('ssl') || MacOS.version < :snow_leopard
    args << "--with-darwinssl" if build.with? 'darwinssl'

    # Tiger/Leopard ship with a horrendously outdated set of certs,
    # breaking any software that relies on curl, e.g. git
    args << "--with-ca-bundle=#{HOMEBREW_PREFIX}/share/ca-bundle.crt" if MacOS.version < :snow_leopard

    system "./configure", *args
    system "make install"
  end
end
