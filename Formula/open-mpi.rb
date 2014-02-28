require 'formula'

class OpenMpi < Formula
  homepage 'http://www.open-mpi.org/'
  url 'http://www.open-mpi.org/software/ompi/v1.7/downloads/openmpi-1.7.4.tar.bz2'
  sha1 '1e3bf2b6cebfdd3571a2f25bba9aa61aed4bbe85'

  option 'disable-fortran', 'Do not build the Fortran bindings'
  option 'enable-mpi-thread-multiple', 'Enable MPI_THREAD_MULTIPLE'
  option :cxx11

  conflicts_with 'mpich2', :because => 'both install mpi__ compiler wrappers'
  conflicts_with 'lcdf-typetools', :because => 'both install same set of binaries.'

  depends_on :fortran unless build.include? 'disable-fortran'
  depends_on 'libevent'

  def install
    ENV.cxx11 if build.cxx11?

    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-ipv6
      --with-libevent=#{Formula["libevent"].opt_prefix}
    ]
    if build.include? 'disable-fortran'
      args << '--disable-mpi-f77' << '--disable-mpi-f90'
    end

    if build.include? 'enable-mpi-thread-multiple'
      args << '--enable-mpi-thread-multiple'
    end

    system './configure', *args
    system 'make', 'all'
    system 'make', 'check'
    system 'make', 'install'

    # If Fortran bindings were built, there will be a stray `.mod` file
    # (Fortran header) in `lib` that needs to be moved to `include`.
    include.install lib/'mpi.mod' if File.exist? "#{lib}/mpi.mod"

    # Not sure why the wrapped script has a jar extension - adamv
    libexec.install bin/'vtsetup.jar'
    bin.write_jar_script libexec/'vtsetup.jar', 'vtsetup.jar'
  end
end
