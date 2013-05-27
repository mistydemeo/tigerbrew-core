require 'formula'

class Gfortran < Formula
  homepage 'http://gcc.gnu.org/wiki/GFortran'
  url 'http://ftpmirror.gnu.org/gcc/gcc-4.8.0/gcc-4.8.0.tar.bz2'
  mirror 'http://ftp.gnu.org/gnu/gcc/gcc-4.8.0/gcc-4.8.0.tar.bz2'
  sha1 'b4ee6e9bdebc65223f95067d0cc1a634b59dad72'

  bottle do
    revision 1
    sha1 '4dfa4f828e425441d927da0d72a5beb7298560fb' => :mountain_lion
    sha1 'ea69a0174218e72118e0e0b0002658aff7a7fede' => :lion
    sha1 '046e1092fdf4bbc4e8b75db750fbc95f39c2c7cb' => :snow_leopard
  end

  option 'enable-profiled-build', 'Make use of profile guided optimization when bootstrapping GCC'
  option 'check', 'Run the make check fortran. This is for maintainers.'

  depends_on 'gmp'
  depends_on 'libmpc'
  depends_on 'mpfr'
  depends_on 'cloog'
  depends_on 'isl'

  # http://gcc.gnu.org/install/test.html
  depends_on 'dejagnu' if build.include? 'check'

  def install
    # Sandbox the GCC lib, libexec and include directories so they don't wander
    # around telling small children there is no Santa Claus. This results in a
    # partially keg-only brew following suggestions outlined in the "How to
    # install multiple versions of GCC" section of the GCC FAQ:
    #     http://gcc.gnu.org/faq.html#multiple
    gfortran_prefix = prefix/'gfortran'

    args = [
      # Sandbox everything...
      "--prefix=#{gfortran_prefix}",
      # ...except the stuff in share...
      "--datarootdir=#{share}",
      # ...and the binaries...
      "--bindir=#{bin}",
      "--enable-languages=fortran",
      "--with-system-zlib",
      # ...opt_prefix survives upgrades and works even if `brew unlink gmp`
      "--with-gmp=#{Formula.factory('gmp').opt_prefix}",
      "--with-mpfr=#{Formula.factory('mpfr').opt_prefix}",
      "--with-mpc=#{Formula.factory('libmpc').opt_prefix}",
      "--with-cloog=#{Formula.factory('cloog').opt_prefix}",
      "--with-isl=#{Formula.factory('isl').opt_prefix}",
      # ...we build the stage 1 gcc with clang (which is know to fail checks)
      "--enable-checking=release",
      "--disable-stage1-checking",
      # ...speed up build by ignoring cxx
      "--disable-build-poststage1-with-cxx",
      "--disable-libstdcxx-pc",
      # ...disable translations avoid conflict with brew install gcc --enable-nls
      '--disable-nls'
    ]

    mkdir 'build' do
      unless MacOS::CLT.installed?
        # For Xcode-only systems, we need to tell the sysroot path.
        # 'native-system-header's will be appended
        args << "--with-native-system-header-dir=/usr/include"
        args << "--with-sysroot=#{MacOS.sdk_path}"
      end

      system '../configure', *args

      if build.include? 'enable-profiled-build'
        # Takes longer to build, may bug out. Provided for those who want to
        # optimise all the way to 11.
        system 'make profiledbootstrap'
      else
        system 'make bootstrap'
      end

      system "make"
      system "make check-fortran" if build.include? 'check'
      system 'make install'
    end

    # This package installs a whole GCC suite. Removing non-fortran components:
    bin.children.reject{ |p| p.basename.to_s.match(/gfortran/) }.each{ |p| rm p }
    man1.children.reject{ |p| p.basename.to_s.match(/gfortran/) }.each{ |p| rm p }
    man7.rmtree  # dupes: fsf fundraising and gpl
    # (share/'locale').rmtree
    (share/"gcc-#{version}").rmtree # dupes: libstdc++ pretty printer, will be added by gcc* formula
  end

  test do
    fixture = <<-EOS.undent
      integer,parameter::m=10000
      real::a(m), b(m)
      real::fact=0.5

      do concurrent (i=1:m)
        a(i) = a(i) + fact*b(i)
      end do
      print *, "done"
      end
    EOS
    Pathname('in.f90').write(fixture)
    system "#{bin}/gfortran -c in.f90"
    system "#{bin}/gfortran -o test in.o"
    `./test`.strip =='done'
  end

  def caveats; <<-EOS.undent
    Brews that require a Fortran compiler should not use:
      depends_on 'gfortran'

    The preferred method of declaring Fortran support is to use:
      def install
        ...
        ENV.fortran
        ...
      end

    EOS
  end
end
