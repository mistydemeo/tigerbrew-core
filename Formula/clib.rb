require "formula"

class Clib < Formula
  homepage "https://github.com/clibs/clib"
  url "https://github.com/clibs/clib/archive/1.1.1.tar.gz"
  sha1 "0b4c59f7f281e8c43d212e789b7b7c81002301e3"

  bottle do
    cellar :any
    sha1 "10a397578f2b73b308a5d0303e58a293537f985e" => :mavericks
    sha1 "b685a52f56d730a8e9bc3ed17b3e1af623b7ca1b" => :mountain_lion
    sha1 "6797bfb01ff5d24f774e77ebd0d99bd3ec7fb610" => :lion
  end

  def install
    ENV["PREFIX"] = prefix
    system "make", "install"
  end

  test do
    system "#{bin}/clib", "install", "stephenmathieson/rot13.c"
  end
end
