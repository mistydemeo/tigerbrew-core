# Installs a relatively minimalist version of the GPAC tools. The
# most commonly used tool in this package is the MP4Box metadata
# interleaver, which has relatively few dependencies.
#
# The challenge with building everything is that Gpac depends on
# a much older version of FFMpeg and WxWidgets than the version
# that Brew installs

class Gpac < Formula
  homepage "http://gpac.wp.mines-telecom.fr/"

  stable do
    url "https://github.com/gpac/gpac/archive/v0.5.2.tar.gz"
    sha256 "14de020482fc0452240f368564baa95a71b729980e4f36d94dd75c43ac4d9d5c"
  end

  head "https://github.com/gpac/gpac"

  depends_on "openssl"
  depends_on :x11 => :recommended
  depends_on "pkg-config" => :build
  depends_on "a52dec" => :optional
  depends_on "jpeg" => :optional
  depends_on "faad2" => :optional
  depends_on "libogg" => :optional
  depends_on "libvorbis" => :optional
  depends_on "mad" => :optional
  depends_on "sdl" => :optional
  depends_on "theora" => :optional
  depends_on "ffmpeg" => :optional
  depends_on "openjpeg" => :optional

  def install
    args = ["--disable-wx",
            "--prefix=#{prefix}",
            "--mandir=#{man}"]

    if build.with? "x11"
      # gpac build system is barely functional
      args << "--extra-cflags=-I#{MacOS::X11.include}"
      # Force detection of X libs on 64-bit kernel
      args << "--extra-ldflags=-L#{MacOS::X11.lib}"
    end

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    system "MP4Box", "-h"
  end
end
