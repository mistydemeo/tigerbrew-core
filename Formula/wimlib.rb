require 'formula'

class Wimlib < Formula
  homepage 'http://sourceforge.net/projects/wimlib/'
  url 'http://downloads.sourceforge.net/project/wimlib/wimlib-1.5.1.tar.gz'
  sha1 '797632bda0fe2da3716c1aea3891646fbc5de93b'

  depends_on 'pkg-config' => :build
  depends_on 'ntfs-3g'

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--without-fuse", # requires librt, unavailable on OSX
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "wiminfo", "--help"
  end
end
