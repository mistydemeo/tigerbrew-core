require 'formula'

class Duti < Formula
  homepage 'http://duti.org/'
  head 'https://github.com/fitterhappier/duti.git'
  url 'https://github.com/fitterhappier/duti/archive/duti-1.5.2.tar.gz'
  sha1 '1833c0a56646a132fa09bcb31c557d4393f19a3b'

  depends_on :autoconf

  def install
    system "autoreconf", "-vfi"
    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end

  def test
    system "#{bin}/duti", "-x", "txt"
  end
end
