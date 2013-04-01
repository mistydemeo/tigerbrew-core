require 'formula'

class Dotwrp < Formula
  homepage 'https://github.com/tenomoto/dotwrp'
  url 'https://github.com/tenomoto/dotwrp/archive/v1.1.tar.gz'
  sha1 'd328705ec424898382956bb8a0be16a680372f05'

  head 'https://github.com/tenomoto/dotwrp.git'

  def install
    ENV.fortran

    # note: fno-underscoring is vital to override the symbols in Accelerate
    system "#{ENV["FC"]} #{ENV["FFLAGS"]} -fno-underscoring -c dotwrp.f90"
    system "ar -cru libdotwrp.a dotwrp.o"
    system "ranlib libdotwrp.a"

    lib.install 'libdotwrp.a'
  end
end
