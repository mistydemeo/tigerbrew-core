require 'formula'

class Gle < Formula
  homepage 'http://glx.sourceforge.net/'
  url 'https://downloads.sourceforge.net/glx/gle-graphics-4.2.4cf-src.tar.gz'
  version '4.2.4c'
  sha1 '5528528dfe54c74f69bfad174105d55a3dd90e49'

  depends_on 'pkg-config' => :build
  depends_on :x11
  depends_on 'jpeg' => :optional
  depends_on 'libtiff' => :optional

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--with-arch=#{MacOS.preferred_arch}",
                          "--without-qt"

    inreplace 'Makefile', "MKDIR_P", "mkdir -p"

    system "make"
    ENV.deparallelize
    system "make install"
  end
end
