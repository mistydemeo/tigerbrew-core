require 'formula'

class OpenMpi < Formula
  homepage 'http://www.open-mpi.org/'
  url 'http://www.open-mpi.org/software/ompi/v1.6/downloads/openmpi-1.6.4.tar.bz2'
  sha1 '38095d3453519177272f488d5058a98f7ebdbf10'

  devel do
    url 'http://www.open-mpi.org/software/ompi/v1.7/downloads/openmpi-1.7.1.tar.bz2'
    sha1 '35d166e2a1d8b88c44d61eaabb5086e2425c8eb8'
  end

  option 'disable-fortran', 'Do not build the Fortran bindings'
  option 'test', 'Verify the build with make check'
  option 'enable-mpi-thread-multiple', 'Enable MPI_THREAD_MULTIPLE'

  conflicts_with 'mpich2', :because => 'both install mpi__ compiler wrappers'

  # Reported upstream at version 1.6, both issues
  # http://www.open-mpi.org/community/lists/devel/2012/05/11003.php
  # http://www.open-mpi.org/community/lists/devel/2012/08/11362.php
  fails_with :clang do
    build 421
    cause 'fails make check on Lion and ML'
  end if not build.devel?

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --enable-ipv6
    ]
    if build.include? 'disable-fortran'
      args << '--disable-mpi-f77' << '--disable-mpi-f90'
    else
      ENV.fortran
    end

    if build.include? 'enable-mpi-thread-multiple'
      args << '--enable-mpi-thread-multiple'
    end

    system './configure', *args
    system 'make V=1 all'
    system 'make V=1 check' if build.include? 'test'
    system 'make install'

    # If Fortran bindings were built, there will be a stray `.mod` file
    # (Fortran header) in `lib` that needs to be moved to `include`.
    include.install lib/'mpi.mod' if File.exists? "#{lib}/mpi.mod"

    # Not sure why the wrapped script has a jar extension - adamv
    libexec.install bin/'vtsetup.jar'
    bin.write_jar_script libexec/'vtsetup.jar', 'vtsetup.jar'
  end
end
