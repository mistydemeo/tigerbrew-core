require 'formula'

class Libgetdata < Formula
  homepage 'http://getdata.sourceforge.net/'
  url 'http://sourceforge.net/projects/getdata/files/getdata/0.8.4/getdata-0.8.4.tar.bz2'
  sha1 'fe50cc6a0a0be719a6ce06acc3beea19fcda13ce'

  option 'with-fortran', 'Build Fortran 77 bindings'
  option 'with-perl', 'Build Perl binding'
  option 'lzma', 'Build with LZMA compression support'
  option 'zzip', 'Build with zzip compression support'

  depends_on 'xz' if build.include? 'lzma'
  depends_on 'libzzip' if build.include? 'zzip'

  def install
    ENV.fortran if build.with? 'fortran'
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]

    args << "--disable-perl" unless build.include?('with-perl')

    system "./configure", *args
    system "make"
    system "make", "install"
  end
end
