require 'formula'

class Rhash < Formula
  homepage 'http://rhash.anz.ru/'
  url 'http://downloads.sourceforge.net/project/rhash/rhash/1.2.10/rhash-1.2.10-src.tar.gz'
  sha1 '130f55faf3f13760ef0ab6a25e52db5052064c63'

  depends_on :macos => :lion

  def install
    system 'make', 'install', "PREFIX=",
                              "DESTDIR=#{prefix}",
                              "CC=#{ENV.cc}"
  end
end
