require 'formula'

class Libxmp < Formula
  homepage 'http://xmp.sourceforge.net'
  url 'http://downloads.sourceforge.net/project/xmp/libxmp/4.1.4/libxmp-4.1.4.tar.gz'
  sha1 'cb4b54ff2a24cf19d336c8360612788028727aaf'
  head 'git://git.code.sf.net/p/xmp/libxmp'

  depends_on :autoconf if build.head?
  # build tries to pass -compatibility-version, which Tiger's ld doesn't grok
  # https://github.com/cmatsuoka/libxmp/issues/1
  depends_on :ld64

  def install
    system "autoconf" if build.head?
    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end
end
