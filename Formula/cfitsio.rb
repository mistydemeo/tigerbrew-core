require 'formula'

class CfitsioExamples < Formula
  url 'http://heasarc.gsfc.nasa.gov/docs/software/fitsio/cexamples/cexamples.zip'
  version '2012.09.24'
  sha1 '668ffa9a65a66c9f1d7f4241867e1e8adf653231'
end

class Cfitsio < Formula
  homepage 'http://heasarc.gsfc.nasa.gov/docs/software/fitsio/fitsio.html'
  url 'ftp://heasarc.gsfc.nasa.gov/software/fitsio/c/cfitsio3350.tar.gz'
  sha1 '4870380013d089e1e9b8994d74f15482decffc1c'
  version '3.350'

  option 'with-examples', "Compile and install example programs"

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make shared"
    system "make install"

    if build.include? 'with-examples'
      system "make fpack funpack"
      bin.install 'fpack', 'funpack'

      # fetch, compile and install examples programs
      CfitsioExamples.new.brew do
        Dir['*.c'].each do |f|
          # compressed_fits.c does not work (obsolete function call)
          next if f == 'compress_fits.c'
          system ENV.cc, f, "-I#{include}", "-L#{lib}", "-lcfitsio", "-lm", "-o", "#{bin}/#{f.sub('.c', '')}"
        end
      end
    end
  end
end
