require 'formula'

class Openssl < Formula
  homepage 'http://openssl.org'
  url 'https://www.openssl.org/source/openssl-1.0.1i.tar.gz'
  mirror 'http://www.mirrorservice.org/sites/ftp.openssl.org/source/openssl-1.0.1i.tar.gz'
  # This has to be an sha1 because Tiger's system openssl doesn't do sha256;
  # we depend on Homebrew's openssl to calculate sha256 hashes
  sha1 '74eed314fa2c93006df8d26cd9fc630a101abd76'

  bottle do
    sha1 "2ce06eae6acc18420aafe1a0df213d4ef2ca5300" => :tiger_g3
    sha1 "1d2aaeb9cd4125e381fedd0f5cd2bd79e28f17af" => :tiger_altivec
    sha1 "bd6db0aa38a1e8672b8f201c8e6a63d77019e901" => :leopard_g3
    sha1 "a641c4e662d104e5c78d0a0224143e51883f0d7e" => :leopard_altivec
  end

  option :universal
  option "without-check", "Skip build-time tests (not recommended)"

  depends_on "makedepend" => :build

  keg_only :provided_by_osx,
    "The OpenSSL provided by OS X is too old for some software."

  def arch_args
    {
      :x86_64 => %w[darwin64-x86_64-cc enable-ec_nistp_64_gcc_128],
      :i386   => %w[darwin-i386-cc],
      :ppc    => %w[darwin-ppc-cc],
      :ppc64  => %w[darwin64-ppc-cc]
    }
  end

  def configure_args
    args = %W[
      --prefix=#{prefix}
      --openssldir=#{openssldir}
      zlib-dynamic
      shared
      enable-cms
    ]

    args << "no-asm" if MacOS.version == :tiger

    args
  end

  def install
    if build.universal?
      ENV.permit_arch_flags
      archs = Hardware::CPU.universal_archs
    elsif MacOS.prefer_64_bit?
      archs = [Hardware::CPU.arch_64_bit]
    else
      archs = [Hardware::CPU.arch_32_bit]
    end

    dirs = []

    archs.each do |arch|
      if build.universal?
        dir = "build-#{arch}"
        dirs << dir
        mkdir dir
        mkdir "#{dir}/engines"
        system "make", "clean"
      end

      ENV.deparallelize
      system "perl", "./Configure", *(configure_args + arch_args[arch])
      system "make", "depend"
      system "make"
      system "make", "test" if build.with? "check"

      if build.universal?
        cp Dir["*.?.?.?.dylib", "*.a", "apps/openssl"], dir
        cp Dir["engines/**/*.dylib"], "#{dir}/engines"
      end
    end

    system "make", "install", "MANDIR=#{man}", "MANSUFFIX=ssl"

    if build.universal?
      %w[libcrypto libssl].each do |libname|
        system "lipo", "-create", "#{dirs.first}/#{libname}.1.0.0.dylib",
                                  "#{dirs.last}/#{libname}.1.0.0.dylib",
                       "-output", "#{lib}/#{libname}.1.0.0.dylib"
        system "lipo", "-create", "#{dirs.first}/#{libname}.a",
                                  "#{dirs.last}/#{libname}.a",
                       "-output", "#{lib}/#{libname}.a"
      end

      Dir.glob("#{dirs.first}/engines/*.dylib") do |engine|
        libname = File.basename(engine)
        system "lipo", "-create", "#{dirs.first}/engines/#{libname}",
                                  "#{dirs.last}/engines/#{libname}",
                       "-output", "#{lib}/engines/#{libname}"
      end

      system "lipo", "-create", "#{dirs.first}/openssl",
                                "#{dirs.last}/openssl",
                     "-output", "#{bin}/openssl"
    end
  end

  def openssldir
    etc/"openssl"
  end

  def post_install
    keychains = %w[
      /Library/Keychains/System.keychain
      /System/Library/Keychains/SystemRootCertificates.keychain
    ]

    openssldir.mkpath
    (openssldir/"cert.pem").atomic_write `security find-certificate -a -p #{keychains.join(" ")}`
  end if MacOS.version > :leopard

  def caveats; <<-EOS.undent
    To install updated CA certs from Mozilla.org:

        brew install curl-ca-bundle
    EOS
  end

  test do
    (testpath/'testfile.txt').write("This is a test file")
    expected_checksum = "91b7b0b1e27bfbf7bc646946f35fa972c47c2d32"
    system "#{bin}/openssl", 'dgst', '-sha1', '-out', 'checksum.txt', 'testfile.txt'
    open("checksum.txt") do |f|
      checksum = f.read(100).split("=").last.strip
      assert_equal checksum, expected_checksum
    end
  end
end
