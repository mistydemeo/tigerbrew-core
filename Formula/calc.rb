require 'formula'

class Calc < Formula
  homepage 'http://www.isthe.com/chongo/tech/comp/calc/'
  url 'http://www.isthe.com/chongo/src/calc/calc-2.12.4.8.tar.bz2'
  sha1 'c92740e891b88561e8884bfa2238a7591be914ae'

  devel do
    url 'http://www.isthe.com/chongo/src/calc/calc-2.12.4.10.tar.bz2'
    sha1 '25e52d49d8c292283130282c44d9d7ec45a31598'
  end

  depends_on 'readline'

  def install
    ENV.deparallelize

    ENV['EXTRA_CFLAGS'] = ENV.cflags
    ENV['EXTRA_LDFLAGS'] = ENV.ldflags

    readline = Formula.factory('readline')
    inreplace "Makefile" do |s|
      s.change_make_var! "INCDIR", include
      s.change_make_var! "BINDIR", bin
      s.change_make_var! "LIBDIR", lib
      s.change_make_var! "MANDIR", man1
      s.change_make_var! "CALC_SHAREDIR", "#{share}/calc"
      s.change_make_var! "USE_READLINE", "-DUSE_READLINE"
      s.change_make_var! "READLINE_LIB", "-L#{readline.lib} -lreadline"
      s.change_make_var! "READLINE_EXTRAS", "-lhistory -lncurses"
      s.change_make_var! "LIBCALC_SHLIB",
        "-single_module -undefined dynamic_lookup -dynamiclib -install_name ${LIBDIR}/libcalc${LIB_EXT_VERSION}"
      s.change_make_var! "LIBCUSTCALC_SHLIB",
        "-single_module -undefined dynamic_lookup -dynamiclib -install_name ${LIBDIR}/libcustcalc${LIB_EXT_VERSION}"
      s.change_make_var! 'CC',
        "MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} #{ENV.cc}"
      s.change_make_var! 'MACOSX_DEPLOYMENT_TARGET',
        "#{MacOS.version}"
    end

    system "make"
    system "make install"
    libexec.install "#{bin}/cscript"
  end

  test do
    output = `#{bin}/calc 0xA + 1`.strip
    assert_equal "11", output
    assert_equal 0, $?.exitstatus
  end
end
