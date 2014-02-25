require 'formula'

class Pdfgrep < Formula
  homepage 'http://pdfgrep.sourceforge.net/'
  url 'http://downloads.sourceforge.net/project/pdfgrep/1.3.0/pdfgrep-1.3.0.tar.gz'
  sha1 'cac20afdea7aee1602b2c33c3d8d36ec171c30bc'

  head 'https://git.gitorious.org/pdfgrep/pdfgrep.git'

  depends_on 'pkg-config' => :build
  depends_on 'poppler'

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make install"
  end

  test do
    system "#{bin}/pdfgrep", "--version"
  end
end
