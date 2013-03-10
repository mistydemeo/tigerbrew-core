require 'formula'

class Audiofile < Formula
  homepage 'http://www.68k.org/~michael/audiofile/'
  url 'https://github.com/downloads/mpruett/audiofile/audiofile-0.3.4.tar.gz'
  sha1 'e6f664b0d551df35ce0c10e38e5617bcd4605335'

  option 'with-lcov', 'Enable Code Coverage support using lcov'
  option 'with-check', 'Run the test suite during install ~30sec'

  depends_on 'lcov' => :optional

  def install
    args = ["--disable-dependency-tracking", "--prefix=#{prefix}"]
    args << '--enable-coverage' if build.with? 'lcov'
    system "./configure", *args
    system "make"
    system "make check" if build.with? 'check'
    system "make install"
  end

  test do
    inn  = '/System/Library/Sounds/Glass.aiff'
    out  = 'Glass.wav'
    conv_bin = "#{bin}/sfconvert"
    info_bin = "#{bin}/sfinfo"

    unless File.exist?(conv_bin) and File.exist?(inn) and File.exist?(info_bin)
      opoo <<-EOS.undent
        One of the following files could not be located, and so
        the test was not executed:
           #{inn}
           #{conv_bin}
           #{info_bin}

        Audiofile can also be tested at build-time:
          brew install -v audiofile --with-check
      EOS
      return
    end

    system conv_bin, inn, out, 'format', 'wave'
    system info_bin, '--short', '--reporterror', out
  end
end
