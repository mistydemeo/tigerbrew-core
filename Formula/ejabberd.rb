require 'formula'

class Ejabberd < Formula
  homepage 'http://www.ejabberd.im'
  url "http://www.process-one.net/downloads/ejabberd/2.1.13/ejabberd-2.1.13.tgz"
  sha1 '6343186be2e84824d2da32e36110b72d6673730e'

  depends_on "openssl" if MacOS.version <= :leopard
  depends_on "erlang"

  option "32-bit"
  option 'with-odbc', "Build with ODBC support"

  def install
    ENV['TARGET_DIR'] = ENV['DESTDIR'] = "#{lib}/ejabberd/erlang/lib/ejabberd-#{version}"
    ENV['MAN_DIR'] = man
    ENV['SBIN_DIR'] = sbin

    if build.build_32_bit?
      %w{ CFLAGS LDFLAGS }.each do |compiler_flag|
        ENV.remove compiler_flag, "-arch #{Hardware::CPU.arch_64_bit}"
        ENV.append compiler_flag, "-arch #{Hardware::CPU.arch_32_bit}"
      end
    end

    cd "src" do
      args = ["--prefix=#{prefix}",
              "--sysconfdir=#{etc}",
              "--localstatedir=#{var}"]

      if MacOS.version <= :leopard
        openssl = Formula['openssl']
        args << "--with-openssl=#{openssl.prefix}"
      end

      args << "--enable-odbc" if build.with? "odbc"

      system "./configure", *args
      system "make"
      system "make install"
    end

    (etc+"ejabberd").mkpath
    (var+"lib/ejabberd").mkpath
    (var+"spool/ejabberd").mkpath
  end

  def caveats; <<-EOS.undent
    If you face nodedown problems, concat your machine name to:
      /private/etc/hosts
    after 'localhost'.
    EOS
  end
end
