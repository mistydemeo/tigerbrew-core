require 'formula'

class Lasi < Formula
  homepage 'http://www.unifont.org/lasi/'
  url 'http://downloads.sourceforge.net/project/lasi/lasi/1.1.1%20Source/libLASi-1.1.1.tar.gz'
  sha1 'd17fdebf4bb4a29512e321c7af157a694dc855a0'

  head 'https://lasi.svn.sourceforge.net/svnroot/lasi/trunk'

  depends_on 'cmake' => :build
  depends_on 'pkg-config' => :build
  depends_on 'pango'
  depends_on 'doxygen'

  def install
    # None is valid, but lasi's CMakeFiles doesn't think so for some reason
    args = std_cmake_args - %w{-DCMAKE_BUILD_TYPE=None}

    system "cmake", ".", "-DCMAKE_BUILD_TYPE=Release", *args
    system "make install"
  end
end
