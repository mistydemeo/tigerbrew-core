require 'formula'

class Curl < Formula
  homepage 'http://curl.haxx.se/'
  url 'http://curl.haxx.se/download/curl-7.37.1.tar.gz'
  mirror 'ftp://ftp.sunet.se/pub/www/utilities/curl/curl-7.37.1.tar.gz'
  sha256 'a32492a38c10a097344892f5fd2041e54698cb909696852311b1161e4aa979f3'
  revision 1

  bottle do
    cellar :any
    sha1 "ffeb3b46f0d8c1dab1673f76b1315e916927c6ea" => :tiger_g3
    sha1 "8caa6577a9aca6f4e7bd2ae3da556499d036a07b" => :tiger_altivec
    sha1 "3151b227168988c91a14b5aa4256204e0af45c44" => :leopard_g3
    sha1 "11e8c7e5362072036073a8feb9f8be94498933c5" => :leopard_altivec
  end

  keg_only :provided_by_osx

  option 'with-idn', 'Build with support for Internationalized Domain Names'
  option 'with-rtmp', 'Build with RTMP support'
  option 'with-ssh', 'Build with scp and sftp support'
  option 'with-ares', 'Build with C-Ares async DNS support'
  option 'with-gssapi', 'Build with GSSAPI/Kerberos authentication support.'
  option 'with-libmetalink', 'Build with libmetalink support.'

  if MacOS.version >= :mountain_lion
    option 'with-openssl', 'Build with OpenSSL instead of Secure Transport'
    depends_on 'openssl' => :optional
  else
    depends_on 'openssl'
  end

  depends_on 'pkg-config' => :build
  depends_on 'libidn' if build.with? 'idn'
  depends_on 'libmetalink' => :optional
  depends_on 'libssh2' if build.with? 'ssh'
  depends_on 'c-ares' if build.with? 'ares'
  depends_on 'curl-ca-bundle' if MacOS.version < :snow_leopard
  depends_on 'rtmpdump' if build.with? 'rtmp'

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]

    if MacOS.version < :mountain_lion or build.with? "openssl"
      args << "--with-ssl=#{Formula["openssl"].opt_prefix}"
    else
      args << "--with-darwinssl"
    end

    args << (build.with?("ssh") ? "--with-libssh2" : "--without-libssh2")
    args << (build.with?("idn") ? "--with-libidn" : "--without-libidn")
    args << (build.with?("libmetalink") ? "--with-libmetalink" : "--without-libmetalink")
    args << (build.with?("gssapi") ? "--with-gssapi" : "--without-gssapi")
    args << (build.with?("rtmp") ? "--with-librtmp" : "--without-librtmp")

    if build.with? "ares"
      args << "--enable-ares=#{Formula["c-ares"].opt_prefix}"
    else
      args << "--disable-ares"
    end

    # Tiger/Leopard ship with a horrendously outdated set of certs,
    # breaking any software that relies on curl, e.g. git
    args << "--with-ca-bundle=#{HOMEBREW_PREFIX}/share/ca-bundle.crt" if MacOS.version < :snow_leopard

    system "./configure", *args
    system "make install"
  end

  test do
    # Fetch the curl tarball and see that the checksum matches.
    # This requires a network connection, but so does Homebrew in general.
    filename = (testpath/"test.tar.gz")
    system "#{bin}/curl", stable.url, "-o", filename
    filename.verify_checksum stable.checksum
  end
end
