require 'formula'

class FbClient < Formula
  homepage 'https://paste.xinu.at'
  url 'https://paste.xinu.at/data/client/fb-1.1.4.tar.gz'
  sha1 '03483b5cdda9d27121941ddd10ffd20967f3f63b'

  def install
    system "make", "PREFIX=#{prefix}", "install"
  end
end
