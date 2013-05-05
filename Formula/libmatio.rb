require 'formula'

class Libmatio < Formula
  homepage 'http://matio.sourceforge.net'
  url 'http://downloads.sourceforge.net/project/matio/matio/1.5.1/matio-1.5.1.tar.bz2'
  sha1 '12b8ed59688b2f41903ddc3e7975f21f10fe42bb'

  option :universal
  option 'with-hdf5', 'Enable support for newer MAT files that use the HDF5-format'

  depends_on 'hdf5' => :optional

  def install
    ENV.universal_binary if build.universal?
    args = %W[
      --prefix=#{prefix}
      --with-zlib=/usr
      --enable-extended-sparse=yes
    ]

    if build.with? 'hdf5'
      args << "--with-hdf5=#{HOMEBREW_PREFIX}" << "--enable-mat73=yes"
    else
      args << "--with-hdf5=no"
    end

    system "./configure", *args
    system "make"
    system "make install"
  end
end
