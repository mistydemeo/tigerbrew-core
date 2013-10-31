require 'formula'

class Bullet < Formula
  homepage 'http://bulletphysics.org/wordpress/'
  url 'http://bullet.googlecode.com/files/bullet-2.82-r2704.tgz'
  version '2.82'
  sha1 'a0867257b9b18e9829bbeb4c6c5872a5b29d1d33'
  head 'http://bullet.googlecode.com/svn/trunk/'

  depends_on 'cmake' => :build

  option :universal
  option 'framework',        'Build Frameworks'
  option 'shared',           'Build shared libraries'
  option 'build-demo',       'Build demo applications'
  option 'build-extra',      'Build extra library'
  option 'double-precision', 'Use double precision'

  def install
    args = []

    if build.include? "framework"
      args << "-DBUILD_SHARED_LIBS=ON" << "-DFRAMEWORK=ON"
      args << "-DCMAKE_INSTALL_PREFIX=#{frameworks}"
      args << "-DCMAKE_INSTALL_NAME_DIR=#{frameworks}"
    else
      args << "-DBUILD_SHARED_LIBS=ON" if build.include? "shared"
      args << "-DCMAKE_INSTALL_PREFIX=#{prefix}"
    end

    args << "-DCMAKE_OSX_ARCHITECTURES='#{Hardware::CPU.universal_archs.as_cmake_arch_flags}" if build.universal?
    args << "-DBUILD_DEMOS=OFF" if not build.include? "build-demo"
    args << "-DBUILD_EXTRAS=OFF" if not build.include? "build-extra"
    args << "-DINSTALL_EXTRA_LIBS=ON" if build.include? "build-extra"
    args << "-DUSE_DOUBLE_PRECISION=ON" if build.include? "double-precision"

    system "cmake", *args
    system "make"
    system "make install"

    prefix.install 'Demos' if build.include? "build-demo"
    prefix.install 'Extras' if build.include? "build-extra"
  end
end
