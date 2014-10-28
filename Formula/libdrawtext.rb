require 'formula'

class Libdrawtext < Formula
  homepage 'http://nuclear.mutantstargoat.com/sw/libdrawtext/'
  url 'http://nuclear.mutantstargoat.com/sw/libdrawtext/libdrawtext-0.1.tar.gz'
  sha1 '0d7166bbb1479553abf82b71a56ec565d861fe81'

  bottle do
    cellar :any
    revision 1
    sha1 "c47c111bbdfed919e38bb696023beba72b61cc81" => :yosemite
    sha1 "efecf132c3279015cfe8227aa94aa900baa8adbd" => :mavericks
    sha1 "267ce6e5aaec21b65190151bdee2496d64620c6d" => :mountain_lion
  end

  depends_on 'pkg-config' => :build
  depends_on 'freetype'
  depends_on 'glew'

  def install
    system "./configure", "--disable-dbg", "--enable-opt",
           "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end
end
