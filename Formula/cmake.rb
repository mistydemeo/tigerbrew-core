require 'formula'

class NoExpatFramework < Requirement
  def expat_framework
    '/Library/Frameworks/expat.framework'
  end

  satisfy :build_env => false do
    not File.exist? expat_framework
  end

  def message; <<-EOS.undent
    Detected #{expat_framework}

    This will be picked up by CMake's build system and likely cause the
    build to fail, trying to link to a 32-bit version of expat.

    You may need to move this file out of the way to compile CMake.
    EOS
  end
end

class Cmake < Formula
  homepage 'http://www.cmake.org/'
  url 'http://www.cmake.org/files/v3.0/cmake-3.0.1.tar.gz'
  sha1 'b7e4acaa7fc7adf54c1b465c712e5ea473b8b74f'

  head 'http://cmake.org/cmake.git'

  # See: https://gist.github.com/shirleyallan/6261775
  fails_with :gcc do
    build 5553
    cause "/Developer/SDKs/MacOSX10.4u.sdk/usr/include/stdarg.h:4:25: error: stdarg.h: No such file or directory"
  end

  bottle do
    cellar :any
    sha1 "7e4815ddbd283d7754dae04d585995a0ba68e38f" => :mavericks
    sha1 "5a9299d20fbbdbfe594baeec10fe448d40c2d05f" => :mountain_lion
    sha1 "dba7684d1d65423df75fd28f459525eb08590232" => :lion
  end

  depends_on NoExpatFramework

  def install
    args = %W[
      --prefix=#{prefix}
      --system-libs
      --no-system-libarchive
      --datadir=/share/cmake
      --docdir=/share/doc/cmake
      --mandir=/share/man
    ]

    system "./bootstrap", *args
    system "make"
    system "make install"
  end

  test do
    (testpath/'CMakeLists.txt').write('find_package(Ruby)')
    system "#{bin}/cmake", '.'
  end
end
