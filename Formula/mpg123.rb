require 'formula'

class Mpg123 < Formula
  homepage 'http://www.mpg123.de/'
  url 'http://downloads.sourceforge.net/project/mpg123/mpg123/1.17.0/mpg123-1.17.0.tar.bz2'
  mirror 'http://mpg123.orgis.org/download/mpg123-1.17.0.tar.bz2'
  sha1 '8185f06ab94651adb2fc7a1ab860f0fd154b6f80'

  def install
    args = ["--disable-debug", "--disable-dependency-tracking",
            "--prefix=#{prefix}",
            '--with-default-audio=coreaudio',
            '--with-module-suffix=.so']

    if Hardware::CPU.type == :intel
      if MacOS.prefer_64_bit?
        args << "--with-cpu=x86-64"
      else
        args << "--with-cpu=sse_alone"
      end
    elsif Hardware::CPU.type == :ppc
      args << "--with-cpu=altivec" if Hardware::CPU.altivec?
    end

    system "./configure", *args
    system "make install"
  end
end
