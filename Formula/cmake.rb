require "formula"

class NoExpatFramework < Requirement
  def expat_framework
    "/Library/Frameworks/expat.framework"
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
  homepage "http://www.cmake.org/"
  url "http://www.cmake.org/files/v3.0/cmake-3.0.2.tar.gz"
  sha1 "379472e3578902a1d6f8b68a9987773151d6f21a"

  head "http://cmake.org/cmake.git"

  # See: https://gist.github.com/shirleyallan/6261775
  fails_with :gcc do
    build 5553
    cause "/Developer/SDKs/MacOSX10.4u.sdk/usr/include/stdarg.h:4:25: error: stdarg.h: No such file or directory"
  end

  bottle do
    cellar :any
    sha1 "4b8b26f60d28c85c0119cb9ab136c5b40f8db570" => :mavericks
    sha1 "a7bc77aa9b9855e5d4081ec689bb62c89be7c25d" => :mountain_lion
    sha1 "842240c9febb4123918cf62a3cea5ca4207ad860" => :lion
  end

  depends_on :python => :build if MacOS.version <= :snow_leopard

  resource "sphinx" do
    url "https://pypi.python.org/packages/source/S/Sphinx/Sphinx-1.2.3.tar.gz"
    sha1 "3a11f130c63b057532ca37fe49c8967d0cbae1d5"
  end

  depends_on NoExpatFramework

  def install
    resource("sphinx").stage do
      ENV.prepend_create_path "PYTHONPATH", buildpath+"sphinx/lib/python2.7/site-packages"
      system "python", "setup.py", "install", "--prefix=#{buildpath}/sphinx"
    end
    ENV.prepend_path "PATH", "#{buildpath}/sphinx/bin"

    args = %W[
      --prefix=#{prefix}
      --system-libs
      --no-system-libarchive
      --sphinx-man
      --datadir=/share/cmake
      --docdir=/share/doc/cmake
      --mandir=/share/man
    ]

    system "./bootstrap", *args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"CMakeLists.txt").write("find_package(Ruby)")
    system "#{bin}/cmake", "."
  end
end
