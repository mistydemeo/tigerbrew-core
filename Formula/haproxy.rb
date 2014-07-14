require 'formula'

class Haproxy < Formula
  homepage 'http://haproxy.1wt.eu'
  url 'http://www.haproxy.org/download/1.5/src/haproxy-1.5.1.tar.gz'
  sha1 'ad51666a79ed8a4550274173d01fe6f6c606a109'

  bottle do
    cellar :any
    sha1 "580ff887d5a02173504db0b3ebe89762c4e7d81f" => :mavericks
    sha1 "e259ea47ddb5bb782025cc087892053998dc0f2e" => :mountain_lion
    sha1 "3c6d106a68a731563a9fade671f21bd27d939f33" => :lion
  end

  depends_on 'pcre'

  def install
    args = ["TARGET=generic",
            "USE_KQUEUE=1",
            "USE_POLL=1",
            "USE_PCRE=1",
            "USE_OPENSSL=1",
            "USE_ZLIB=1",
            "ADDLIB=-lcrypto",
    ]

    # We build generic since the Makefile.osx doesn't appear to work
    system "make", "CC=#{ENV.cc}", "CFLAGS=#{ENV.cflags}", "LDFLAGS=#{ENV.ldflags}", *args
    man1.install "doc/haproxy.1"
    bin.install "haproxy"
  end
end
