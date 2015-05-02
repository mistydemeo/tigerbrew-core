require "formula"

class Daemonize < Formula
  homepage "http://software.clapper.org/daemonize/"
  url "https://github.com/bmc/daemonize/archive/release-1.7.6.tar.gz"
  sha1 "5fec633880ef0a81fe0ca9d9eaeeeefd969f5dbd"

  bottle do
    cellar :any
    sha256 "f030b352d61fa673e81d84ee041c6922f3615cb7761b68e090329a406248d322" => :yosemite
    sha256 "a8713e370c1c2677bff6bfd30722eefa79daca3352a6e79d6dc4315b782bea61" => :mavericks
    sha256 "94bb0d065fd5e3a7fe43ae3df279e7eac2c6c65455bf2821981a838789365435" => :mountain_lion
  end

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make install"
  end
end
