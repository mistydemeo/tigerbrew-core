require 'formula'

class Ettercap < Formula
  homepage 'http://ettercap.github.io/ettercap/'
  url 'https://downloads.sourceforge.net/project/ettercap/ettercap/0.7.6-Locard/ettercap-0.7.6.tar.gz'
  sha1 '55818952a8c28beb1b650f3ccc9600a2d784a18f'

  depends_on 'cmake' => :build
  depends_on 'ghostscript' => :build
  depends_on 'pcre'
  depends_on 'libnet'
  depends_on 'curl' # require libcurl >= 7.26.0

  # fixes absence of strndup function on 10.6 and lower; merged upstream
  def patches
    if MacOS.version < :lion
      "https://github.com/Ettercap/ettercap/commit/1692218693ed419465466299c8c76da41c37c945.patch"
    end
  end

  def install
    libnet = Formula['libnet'].opt_lib

    args = ['..'] + std_cmake_args + [
      "-DINSTALL_SYSCONFDIR=#{etc}",
      '-DENABLE_GTK=OFF',
      "-DHAVE_LIBNET:FILEPATH=#{libnet}/libnet.dylib"
    ]

    mkdir "build" do
      system "cmake", *args
      system "make install"
    end
  end
end
