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
  url 'http://www.cmake.org/files/v2.8/cmake-2.8.12.tar.gz'
  sha1 '93c93d556e702f8c967acf139fd716268ce69f39'

  head 'http://cmake.org/cmake.git'

  # See: https://gist.github.com/shirleyallan/6261775
  fails_with :gcc do
    build 5553
    cause "/Developer/SDKs/MacOSX10.4u.sdk/usr/include/stdarg.h:4:25: error: stdarg.h: No such file or directory"
  end

  bottle do
    cellar :any
    sha1 '5f313308d096d3561fb3dfcab1dfed0fa6fbd2e5' => :mountain_lion
    sha1 '0aa714a1051a0b7e9d8b2d9ca5629e228590744e' => :lion
    sha1 'f0aae0f98c33142608630473582b43d52752f1b5' => :snow_leopard
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
