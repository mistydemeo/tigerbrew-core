require 'formula'

class Poppler < Formula
  homepage 'http://poppler.freedesktop.org'
  url 'http://poppler.freedesktop.org/poppler-0.26.4.tar.xz'
  sha1 '26ff3310cb4866829030c73070df4ae9aa4f6cac'

  bottle do
    sha1 "6634b3885414fddfec33f2070e6b27a63ef63372" => :mavericks
    sha1 "89893811796e5b7d949364859ac98d98ba436406" => :mountain_lion
    sha1 "669ae1aeece7b6a643b52a3bfa4e0cc4114b2211" => :lion
  end

  option 'with-qt4', 'Build Qt backend'
  option 'with-lcms2', 'Use color management system'

  depends_on 'pkg-config' => :build
  depends_on 'cairo'
  depends_on 'fontconfig'
  depends_on 'freetype'
  depends_on 'gettext'
  depends_on 'glib'
  depends_on 'gobject-introspection'
  depends_on 'jpeg'
  depends_on 'libpng'
  depends_on 'libtiff'
  depends_on 'openjpeg'

  depends_on 'qt' if build.with? 'qt4'
  depends_on 'little-cms2' if build.with? 'lcms2'

  conflicts_with 'pdftohtml', :because => 'both install `pdftohtml` binaries'

  conflicts_with 'pdf2image', 'xpdf',
    :because => 'poppler, pdf2image, and xpdf install conflicting executables'

  resource 'font-data' do
    url 'http://poppler.freedesktop.org/poppler-data-0.4.7.tar.gz'
    sha1 '556a5bebd0eb743e0d91819ba11fd79947d8c674'
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-xpdf-headers
      --enable-poppler-glib
      --disable-gtk-test
      --enable-introspection=yes
    ]

    if build.with? "qt4"
      args << "--enable-poppler-qt4"
    else
      args << "--disable-poppler-qt4"
    end

    args << "--enable-cms=lcms2" if build.with? "lcms2"

    system "./configure", *args
    system "make install"
    resource('font-data').stage { system "make", "install", "prefix=#{prefix}" }
  end
end
