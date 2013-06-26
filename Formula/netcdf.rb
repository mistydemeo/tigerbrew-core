require 'formula'

class NetcdfCXX < Formula
  homepage 'http://www.unidata.ucar.edu/software/netcdf'
  url 'http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-cxx4-4.2.tar.gz'
  sha1 '59628c9f06c211a47517fc00d8b068da159ffa9d'
end

class NetcdfCXX_compat < Formula
  homepage 'http://www.unidata.ucar.edu/software/netcdf'
  url 'http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-cxx-4.2.tar.gz'
  sha1 'bab9b2d873acdddbdbf07ab35481cd0267a3363b'
end

class NetcdfFortran < Formula
  homepage 'http://www.unidata.ucar.edu/software/netcdf'
  url 'http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.2.tar.gz'
  sha1 'f1887314455330f4057bc8eab432065f8f6f74ef'
end

class Netcdf < Formula
  homepage 'http://www.unidata.ucar.edu/software/netcdf'
  url 'http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-4.2.1.1.tar.gz'
  sha1 '76631cb4e6b767c224338415cf6e5f5ff9bd1238'

  depends_on :fortran if build.include? 'enable-fortran'
  depends_on 'hdf5'

  option 'enable-fortran', 'Compile Fortran bindings'
  option 'disable-cxx', "Don't compile C++ bindings"
  option 'enable-cxx-compat', 'Compile C++ bindings for compatibility'

  def install
    if build.include? 'enable-fortran'
      # fix for ifort not accepting the --force-load argument, causing
      # the library libnetcdff.dylib to be missing all the f90 symbols.
      # http://www.unidata.ucar.edu/software/netcdf/docs/known_problems.html#intel-fortran-macosx
      # https://github.com/mxcl/homebrew/issues/13050
      ENV['lt_cv_ld_force_load'] = 'no' if ENV.fc == 'ifort'
    end

    common_args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-static
      --enable-shared
    ]

    args = common_args.clone
    args.concat %w[--enable-netcdf4 --disable-doxygen]

    system './configure', *args
    system 'make install'

    # Add newly created installation to paths so that binding libraries can
    # find the core libs.
    ENV.prepend 'PATH', bin, ':'
    ENV.prepend 'CPPFLAGS', "-I#{include}"
    ENV.prepend 'LDFLAGS', "-L#{lib}"

    NetcdfCXX.new.brew do
      system './configure', *common_args
      system 'make install'
    end unless build.include? 'disable-cxx'

    NetcdfCXX_compat.new.brew do
      system './configure', *common_args
      system 'make install'
    end if build.include? 'enable-cxx-compat'

    NetcdfFortran.new.brew do
      system './configure', *common_args
      system 'make install'
    end if build.include? 'enable-fortran'
  end
end
