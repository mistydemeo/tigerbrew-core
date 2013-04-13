require 'formula'

class TokyoCabinet < Formula
  homepage 'http://fallabs.com/tokyocabinet/'
  url 'http://fallabs.com/tokyocabinet/tokyocabinet-1.4.47.tar.gz'
  sha1 '18608ac2e6e469e20d1c36ae1117661bb47901c4'

  def install
    # libtool chokes on -w with gcc-4.0
    ENV.enable_warnings if MacOS.default_compiler == :gcc_4_0

    args = %W[--prefix=#{prefix}]
    args << "--enable-fastest" unless Hardware::CPU.type == :ppc

    system "./configure", *args
    system "make"
    system "make install"
  end
end
