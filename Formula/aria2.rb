require 'formula'

class Aria2 < Formula
  homepage 'http://aria2.sourceforge.net/'
  url 'http://downloads.sourceforge.net/project/aria2/stable/aria2-1.18.1/aria2-1.18.1.tar.bz2'
  sha1 '050f521848353fe90568059768d73a5a6f7ff869'

  option 'with-appletls', 'Build with Secure Transport for SSL support'

  depends_on 'pkg-config' => :build
  depends_on 'gnutls' unless build.with? 'appletls'
  depends_on 'curl-ca-bundle' => :recommended
  depends_on :macos => :lion # Needs a c++11 compiler

  def install
    args = %W[--disable-dependency-tracking --prefix=#{prefix}]
    args << "--with-ca-bundle=#{HOMEBREW_PREFIX}/share/ca-bundle.crt" if build.with? 'curl-ca-bundle'
    if build.with? 'appletls'
      args << "--with-appletls"
    else
      args << "--without-appletls"
    end

    system "./configure", *args
    system "make install"

    bash_completion.install "doc/bash_completion/aria2c"
  end
end
