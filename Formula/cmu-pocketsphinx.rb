require 'formula'

class CmuPocketsphinx < Formula
  homepage 'http://cmusphinx.sourceforge.net/'
  url 'http://downloads.sourceforge.net/project/cmusphinx/pocketsphinx/0.8/pocketsphinx-0.8.tar.gz'
  sha1 'd9efdd0baddd2e47c2ba559caaca62ffa0c0eede'

  depends_on 'pkg-config' => :build
  depends_on 'cmu-sphinxbase'

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end
end
