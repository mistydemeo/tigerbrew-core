require "formula"

class Libtasn1 < Formula
  homepage "https://www.gnu.org/software/libtasn1/"
  url "http://ftpmirror.gnu.org/libtasn1/libtasn1-4.1.tar.gz"
  mirror "https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.1.tar.gz"
  sha1 "a4cdf91b6130d29b5b69dca17a1e85053ac54e7b"

  bottle do
    cellar :any
    sha1 "a5e5bb5c2b44a32cd2ae1b5bd636be81456bd1bb" => :mavericks
    sha1 "f12f64690e13b94ea02e10f09329a2d1ad0c08e2" => :mountain_lion
    sha1 "337e0bd70fa5a90f95ff531c9ae53b816ddcad70" => :lion
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make install"
  end
end
