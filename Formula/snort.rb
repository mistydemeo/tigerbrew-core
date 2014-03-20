require 'formula'

class Snort < Formula
  homepage 'http://www.snort.org'
  url 'http://www.snort.org/dl/snort-current/snort-2.9.6.0.tar.gz'
  sha1 '0c143f202b2e55b00d87b859fc3fe4ff5d0d9b38'

  depends_on 'daq'
  depends_on 'libdnet'
  depends_on 'pcre'

  option 'enable-debug', "Compile Snort with --enable-debug and --enable-debug-msgs"

  def install
    args = %W[--prefix=#{prefix}
              --disable-dependency-tracking
              --enable-gre
              --enable-mpls
              --enable-targetbased
              --enable-ppm
              --enable-perfprofiling
              --enable-zlib
              --enable-active-response
              --enable-normalizer
              --enable-reload
              --enable-react
              --enable-flexresp3]

    if build.include? 'enable-debug'
      args << "--enable-debug"
      args << "--enable-debug-msgs"
    else
      args << "--disable-debug"
    end

    system "./configure", *args
    system "make install"
  end

  def caveats; <<-EOS.undent
    For snort to be functional, you need to update the permissions for /dev/bpf*
    so that they can be read by non-root users.  This can be done manually using:
        sudo chmod 644 /dev/bpf*
    or you could create a startup item to do this for you.
    EOS
  end
end
