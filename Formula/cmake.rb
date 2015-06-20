class Cmake < Formula
  desc "Cross-platform make"
  homepage "http://www.cmake.org/"
  url "http://www.cmake.org/files/v3.2/cmake-3.2.3.tar.gz"
  sha256 "a1ebcaf6d288eb4c966714ea457e3b9677cdfde78820d0f088712d7320850297"
  head "http://cmake.org/cmake.git"

  # See: https://gist.github.com/shirleyallan/6261775
  fails_with :gcc do
    build 5553
    cause "/Developer/SDKs/MacOSX10.4u.sdk/usr/include/stdarg.h:4:25: error: stdarg.h: No such file or directory"
  end

  bottle do
    cellar :any
    sha256 "b11776b17cd2e58a16c074187d0e2c02c5c124b611c56e09e8ccc8473e7644ec" => :tiger_altivec
    sha256 "6dafc5ac1ceb467ea3ce64f22076bcaf627e532c407c3a1d908e5b9ec1b8dafe" => :leopard_g3
    sha256 "6d04cbc26ab4034a6ade7eed07074a29e13236c3e28499f246cd534017d59f60" => :leopard_altivec
  end

  option "without-docs", "Don't build man pages"

  depends_on :python => :build if MacOS.version <= :snow_leopard && build.with?("docs")

  # The `with-qt` GUI option was removed due to circular dependencies if
  # CMake is built with Qt support and Qt is built with MySQL support as MySQL uses CMake.
  # For the GUI application please instead use brew install caskroom/cask/cmake.

  resource "sphinx" do
    url "https://pypi.python.org/packages/source/S/Sphinx/Sphinx-1.2.3.tar.gz"
    sha256 "94933b64e2fe0807da0612c574a021c0dac28c7bd3c4a23723ae5a39ea8f3d04"
  end

  resource "docutils" do
    url "https://pypi.python.org/packages/source/d/docutils/docutils-0.12.tar.gz"
    sha256 "c7db717810ab6965f66c8cf0398a98c9d8df982da39b4cd7f162911eb89596fa"
  end

  resource "pygments" do
    url "https://pypi.python.org/packages/source/P/Pygments/Pygments-2.0.2.tar.gz"
    sha256 "7320919084e6dac8f4540638a46447a3bd730fca172afc17d2c03eed22cf4f51"
  end

  resource "jinja2" do
    url "https://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.7.3.tar.gz"
    sha256 "2e24ac5d004db5714976a04ac0e80c6df6e47e98c354cb2c0d82f8879d4f8fdb"
  end

  resource "markupsafe" do
    url "https://pypi.python.org/packages/source/M/MarkupSafe/MarkupSafe-0.23.tar.gz"
    sha256 "a4ec1aff59b95a14b45eb2e23761a0179e98319da5a7eb76b56ea8cdc7b871c3"
  end

  patch do
    # fix for older bash-completion versions
    # Use Github because upstream git changes sha and breaks from-source download.
    url "https://github.com/Kitware/CMake/commit/2ecf168f1909.diff"
    sha256 "d3f8cd71d0b6ce23a22c55145114012da916f2e42af71cbbad35090d0aeb4f68"
  end

  def install
    if build.with? "docs"
      ENV.prepend_create_path "PYTHONPATH", buildpath+"sphinx/lib/python2.7/site-packages"
      resources.each do |r|
        r.stage do
          system "python", *Language::Python.setup_install_args(buildpath/"sphinx")
        end
      end

      # There is an existing issue around OS X & Python locale setting
      # See http://bugs.python.org/issue18378#msg215215 for explanation
      ENV["LC_ALL"] = "en_US.UTF-8"
    end

    args = %W[
      --prefix=#{prefix}
      --no-system-libs
      --parallel=#{ENV.make_jobs}
      --datadir=/share/cmake
      --docdir=/share/doc/cmake
      --mandir=/share/man
      --system-zlib
      --system-bzip2
    ]

    args << (MacOS.version < :leopard ? "--no-system-curl" : "--system-curl")

    if build.with? "docs"
      args << "--sphinx-man" << "--sphinx-build=#{buildpath}/sphinx/bin/sphinx-build"
    end

    system "./bootstrap", *args
    system "make"
    system "make", "install"

    cd "Auxiliary/bash-completion/" do
      bash_completion.install "ctest", "cmake", "cpack"
    end
  end

  test do
    (testpath/"CMakeLists.txt").write("find_package(Ruby)")
    system "#{bin}/cmake", "."
  end
end
