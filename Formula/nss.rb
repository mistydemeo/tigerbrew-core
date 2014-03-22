require 'formula'

class Nss < Formula
  homepage "https://developer.mozilla.org/docs/NSS"
  url "https://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/NSS_3_16_RTM/src/nss-3.16-with-nspr-4.10.4.tar.gz"
  sha1 "8ae6ddec43556b4deb949dc889123ff1d09ab737"
  version "3.16"

  bottle do
    cellar :any
    sha1 "08ea6d10ebe317330129e03c184a0aaa59b300b0" => :mavericks
    sha1 "3fd67a639a8fcdb253f8fe982a5ecf6f1ea25c6b" => :mountain_lion
    sha1 "a4153f7a673f3f4703a9e4142958039e7b24bc51" => :lion
  end

  depends_on "nspr"

  keg_only "NSS installs a libssl which conflicts with OpenSSL."

  def install
    ENV.deparallelize
    cd "nss"

    args = [
      "BUILD_OPT=1",
      "NSS_USE_SYSTEM_SQLITE=1",
      "NSPR_INCLUDE_DIR=#{HOMEBREW_PREFIX}/include/nspr",
      "NSPR_LIB_DIR=#{HOMEBREW_PREFIX}/lib"
    ]
    args << "USE_64=1" if MacOS.prefer_64_bit?

    # Remove the broken (for anyone but Firefox) install_name
    inreplace "coreconf/Darwin.mk", "-install_name @executable_path", "-install_name #{lib}"
    inreplace "lib/freebl/config.mk", "@executable_path", lib

    system "make", "nss_build_all", *args

    # We need to use cp here because all files get cross-linked into the dist
    # hierarchy, and Homebrew's Pathname.install moves the symlink into the keg
    # rather than copying the referenced file.
    cd "../dist"
    bin.mkdir
    Dir["Darwin*/bin/*"].each do |file|
      cp file, bin unless file.include? ".dylib"
    end

    include.mkdir
    include_target = include + "nss"
    include_target.mkdir
    ["dbm", "nss"].each do |dir|
      Dir["public/#{dir}/*"].each do |file|
        cp file, include_target
      end
    end

    lib.mkdir
    libexec.mkdir
    Dir["Darwin*/lib/*"].each do |file|
      cp file, lib unless file.include? ".chk"
      cp file, libexec if file.include? ".chk"
    end

    (lib+"pkgconfig/nss.pc").write pc_file
  end

  test do
    # See: http://www.mozilla.org/projects/security/pki/nss/tools/certutil.html
    (testpath/"passwd").write("It's a secret to everyone.")
    system "#{bin}/certutil", "-N", "-d", pwd, "-f", "passwd"
    system "#{bin}/certutil", "-L", "-d", pwd
  end

  def pc_file; <<-EOS.undent
    prefix=#{opt_prefix}
    exec_prefix=${prefix}
    libdir=${exec_prefix}/lib
    includedir=${prefix}/include/nss

    Name: NSS
    Description: Mozilla Network Security Services
    Version: #{version}
    Requires: nspr
    Libs: -L${libdir} -lnss3 -lnssutil3 -lsmime3 -lssl3
    Cflags: -I${includedir}
    EOS
  end
end
