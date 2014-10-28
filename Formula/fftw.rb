require 'formula'

class Fftw < Formula
  homepage 'http://www.fftw.org'
  url 'http://www.fftw.org/fftw-3.3.4.tar.gz'
  sha1 'fd508bac8ac13b3a46152c54b7ac885b69734262'

  bottle do
    cellar :any
    revision 1
    sha1 "edf0ba7f313d219a9f2b397a1418ee2121327959" => :yosemite
    sha1 "f68bcfc985833b9680c61f057d6bde80ae80fcb1" => :mavericks
    sha1 "c458d7f414aeca2ab980901815991edbe81007e5" => :mountain_lion
  end

  option "with-fortran", "Enable Fortran bindings"
  option :universal
  option "with-mpi", "Enable MPI parallel transforms"

  depends_on :fortran => :optional
  depends_on :mpi => [:cc, :optional]

  def install
    args = ["--enable-shared",
            "--disable-debug",
            "--prefix=#{prefix}",
            "--enable-threads",
            "--disable-dependency-tracking"]
    simd_args = ["--enable-sse2"]
    simd_args << "--enable-avx" if ENV.compiler == :clang and Hardware::CPU.avx? and !build.bottle?

    args << "--disable-fortran" if build.without? "fortran"
    args << "--enable-mpi" if build.with? "mpi"

    # Decide which SIMD options we need
    simd_single = []
    simd_double = []

    if Hardware.cpu_type == :intel
      simd_single << "--enable-sse"
      simd_double << "--enable-sse2"
    elsif Hardware::CPU.altivec?
      simd_single << "--enable-altivec" # altivec seems to only work with single precision
    end

    ENV.universal_binary if build.universal?

    # single precision
    # enable-sse only works with single
    # similarly altivec only works with single precision
    system "./configure", "--enable-single",
                          simd_single,
                          *args
    system "make install"

    # clean up so we can compile the double precision variant
    system "make clean"

    # double precision
    # enable-sse2 only works with double precision (default)
    system "./configure", simd_double, *args
    system "make install"

    # clean up so we can compile the long-double precision variant
    system "make clean"

    # long-double precision
    # no SIMD optimization available
    system "./configure", "--enable-long-double", *args
    system "make install"
  end

  test do
    # Adapted from the sample usage provided in the documentation:
    # http://www.fftw.org/fftw3_doc/Complex-One_002dDimensional-DFTs.html
    (testpath/'fftw.c').write <<-TEST_SCRIPT.undent
      #include <fftw3.h>

      int main(int argc, char* *argv)
      {
          fftw_complex *in, *out;
          fftw_plan p;
          long N = 1;
          in = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * N);
          out = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * N);
          p = fftw_plan_dft_1d(N, in, out, FFTW_FORWARD, FFTW_ESTIMATE);
          fftw_execute(p); /* repeat as needed */
          fftw_destroy_plan(p);
          fftw_free(in); fftw_free(out);
          return 0;
      }
    TEST_SCRIPT

    system ENV.cc, '-o', 'fftw', 'fftw.c', '-lfftw3', *ENV.cflags.to_s.split
    system './fftw'
  end
end
