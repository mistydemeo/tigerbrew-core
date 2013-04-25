require 'formula'

class Libusbx < Formula
  homepage 'http://libusbx.org'
  url 'http://sourceforge.net/projects/libusbx/files/releases/1.0.15/source/libusbx-1.0.15.tar.bz2'
  sha1 '1ca868f775093b0109d9240cb3ccd36367764dc6'

  head 'https://github.com/libusbx/libusbx.git'

  conflicts_with 'libusb',
    :because => 'both provide libusb compatible libraries'

  if build.head?
    depends_on :automake
    depends_on :libtool
  end

  option :universal
  option 'no-runtime-logging', 'Build without runtime logging functionality'
  option 'with-default-log-level-debug' 'Build with default runtime log level of debug (instead of none)'

  def install
    ENV.universal_binary if build.universal?
    system "./autogen.sh" if build.head?
    args = %W[--disable-dependency-tracking --prefix=#{prefix}]
    args << "--disable-log" if build.include? 'no-runtime-logging'
    args << "--enable-debug-log" if build.include? 'with-default-log-level-debug'
    system "./configure", *args
    system "make install"
  end
end
