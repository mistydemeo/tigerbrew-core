require "formula"

# Note that x.even are stable releases, x.odd are devel releases
class Libuv < Formula
  homepage "https://github.com/joyent/libuv"
  url "https://github.com/joyent/libuv/archive/v0.10.21.tar.gz"
  sha1 "883bb240d84e1db11b22b5b0dfdd117ed6bc6318"

  bottle do
    cellar :any
    sha1 "d5791cfcd21caedadd5621de7228a1dc7cd83006" => :mavericks
    sha1 "69f380f49bbec2d1066e74bfda73aad797395af2" => :mountain_lion
    sha1 "789d58edabb28ca47bc8072000e935a0c958780e" => :lion
  end

  head do
    url "https://github.com/joyent/libuv.git", :branch => "master"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  devel do
    url "https://github.com/joyent/libuv/archive/v0.11.29.tar.gz"
    sha1 '234eb9fe9a1b8de53333674e16e40a72efc991a1'

    depends_on "pkg-config" => :build
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?

    if build.stable?
      system "make", "libuv.dylib"
      prefix.install "include"
      lib.install "libuv.dylib"
    else
      system "./autogen.sh"
      system "./configure", "--disable-dependency-tracking",
                            "--prefix=#{prefix}"
      system "make", "install"
    end
  end
end
