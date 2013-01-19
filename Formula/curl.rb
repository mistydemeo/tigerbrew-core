require 'formula'

class Curl < Formula
  homepage 'http://curl.haxx.se/'
  url 'http://curl.haxx.se/download/curl-7.28.1.tar.gz'
  sha256 '78dce7cfff51ec5725442b92c00550b4e0ca2f45ad242223850a312cd9160509'

  keg_only :provided_by_osx,
    "The libcurl shipped before Snow Leopard is too old for CouchDB to use."

  option 'with-ssh', 'Build with scp and sftp support'
  option 'with-libmetalink', 'Build with Metalink support'
  option 'with-ares', 'Build with C-Ares async DNS support'
  option 'with-ssl', 'Build with Homebrew OpenSSL instead of the system version'

  depends_on 'pkg-config' => :build
  depends_on 'libssh2' if build.include? 'with-ssh'
  depends_on 'libmetalink' if build.include? 'with-libmetalink'
  depends_on 'c-ares' if build.include? 'with-ares'
  depends_on 'openssl' if build.include?('with-ssl') || MacOS.version < :snow_leopard

  depends_on 'curl-ca-bundle' if MacOS.version < :snow_leopard

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]

    args << "--with-libssh2" if build.include? 'with-ssh'
    args << "--with-libmetalink" if build.include? 'with-libmetalink'
    args << "--enable-ares=#{Formula.factory("c-ares").opt_prefix}" if build.include? 'with-ares'
    args << "--with-ssl=#{Formula.factory("openssl").opt_prefix}" if build.include?('with-ssl') || MacOS.version < :snow_leopard

    # Tiger/Leopard ship with a horrendously outdated set of certs,
    # breaking any software that relies on curl, e.g. git
    args << "--with-ca-bundle=#{HOMEBREW_PREFIX}/share/ca-bundle.crt" if MacOS.version < :snow_leopard

    system "./configure", *args
    system "make install"
  end
end
