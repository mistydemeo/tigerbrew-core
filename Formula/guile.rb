require 'formula'

class Guile < Formula
  homepage 'http://www.gnu.org/software/guile/'
  url 'http://ftpmirror.gnu.org/guile/guile-1.8.8.tar.gz'
  mirror 'http://ftp.gnu.org/gnu/guile/guile-1.8.8.tar.gz'
  sha1 '548d6927aeda332b117f8fc5e4e82c39a05704f9'

  devel do
    url 'http://ftpmirror.gnu.org/guile/guile-2.0.9.tar.gz'
    mirror 'http://ftp.gnu.org/gnu/guile/guile-2.0.9.tar.gz'
    sha1 'fc5d770e8b1d364b2f222a8f8c96ccf740b2956f'
  end

  head 'git://git.sv.gnu.org/guile.git'

  if build.head?
    depends_on 'automake' => :build
    depends_on 'gettext' => :build
  end

  depends_on 'pkg-config' => :build
  depends_on :libtool
  depends_on 'libffi'
  depends_on 'libunistring'
  depends_on 'bdw-gc'
  depends_on 'gmp'

  # GNU Readline is required; libedit won't work.
  depends_on 'readline'

  fails_with :llvm do
    build 2336
    cause "Segfaults during compilation"
  end

  fails_with :clang do
    build 211
    cause "Segfaults during compilation"
  end if build.devel?

  def install
    system './autogen.sh' if build.head?

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-libreadline-prefix=#{Formula.factory('readline').prefix}"
    system "make install"

    # A really messed up workaround required on OS X --mkhl
    lib.cd { Dir["*.dylib"].each {|p| ln_sf p, File.basename(p, ".dylib")+".so" }}
  end
end
