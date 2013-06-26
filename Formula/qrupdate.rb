require 'formula'

class Qrupdate < Formula
  homepage 'http://sourceforge.net/projects/qrupdate/'
  url 'http://downloads.sourceforge.net/qrupdate/qrupdate-1.1.2.tar.gz'
  sha1 'f7403b646ace20f4a2b080b4933a1e9152fac526'

  depends_on :fortran
  depends_on 'dotwrp'

  def install
    ENV.j1
    ENV['PREFIX'] = prefix
    inreplace 'Makeconf' do |s|
      s.gsub! /^(FC=).*/,     "\\1#{HOMEBREW_PREFIX}/bin/gfortran"
      s.gsub! /^(FFLAGS=).*/, "\\1#{ENV.fcflags}"
      s.gsub! /^(BLAS=).*/,   "\\1#{ENV.ldflags} -ldotwrp -framework Accelerate"
      s.gsub! /^(LAPACK=).*/, "\\1#{ENV.ldflags} -ldotwrp -framework Accelerate"
    end
    cd "./src"
    inreplace 'Makefile' do |s|
      s.gsub! 'install -D', 'install'
    end
    lib.mkpath
    system 'make install'
  end
end
