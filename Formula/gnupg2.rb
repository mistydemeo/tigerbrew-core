require "formula"

class Gnupg2 < Formula
  homepage "https://www.gnupg.org/"
  url "ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-2.0.26.tar.bz2"
  mirror "ftp://ftp.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gnupg/gnupg-2.0.26.tar.bz2"
  mirror "ftp://mirror.tje.me.uk/pub/mirrors/ftp.gnupg.org/gnupg/gnupg-2.0.26.tar.bz2"
  sha1 "3ff5b38152c919724fd09cf2f17df704272ba192"
  revision 1

  bottle do
    revision 2
    sha1 "ccbafc88773f15b92e7ab931ec1be83fb27b58c2" => :yosemite
    sha1 "1735c876de43f9635e191e6b1f1ed3f1ae04068d" => :mavericks
    sha1 "ad0e8129ffbaf615f8b43aa93b89eb1cdc517f1f" => :mountain_lion
  end

  option "8192", "Build with support for private keys of up to 8192 bits"

  # /usr/bin/ld: multiple definitions of symbol _memrchr
  # https://github.com/mistydemeo/tigerbrew/issues/107
  depends_on :ld64
  depends_on "libgpg-error"
  depends_on "libgcrypt"
  depends_on "libksba"
  depends_on "libassuan"
  depends_on "pinentry"
  depends_on "pth"
  depends_on "gpg-agent"
  depends_on "curl" if MacOS.version <= :mavericks
  depends_on "dirmngr" => :recommended
  depends_on "libusb-compat" => :recommended
  depends_on "readline" => :optional

  def install
    # Adjust package name to fit our scheme of packaging both gnupg 1.x and
    # 2.x, and gpg-agent separately, and adjust tests to fit this scheme
    inreplace "configure" do |s|
      s.gsub! "PACKAGE_NAME='gnupg'", "PACKAGE_NAME='gnupg2'"
      s.gsub! "PACKAGE_TARNAME='gnupg'", "PACKAGE_TARNAME='gnupg2'"
    end
    inreplace "tests/openpgp/Makefile.in" do |s|
      s.gsub! "required_pgms = ../../g10/gpg2 ../../agent/gpg-agent",
              "required_pgms = ../../g10/gpg2"
      s.gsub! "../../agent/gpg-agent --quiet --daemon sh",
              "gpg-agent --quiet --daemon sh"
    end
    inreplace "tools/gpgkey2ssh.c", "gpg --list-keys", "gpg2 --list-keys"

    inreplace "g10/keygen.c", "max=4096", "max=8192" if build.include? "8192"

    (var/"run").mkpath

    ENV.append "LDFLAGS", "-lresolv"

    ENV["gl_cv_absolute_stdint_h"] = "#{MacOS.sdk_path}/usr/include/stdint.h"

    agent = Formula["gpg-agent"].opt_prefix

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sbindir=#{bin}
      --enable-symcryptrun
      --disable-agent
      --with-agent-pgm=#{agent}/bin/gpg-agent
      --with-protect-tool-pgm=#{agent}/libexec/gpg-protect-tool
    ]

    if build.with? "readline"
      args << "--with-readline=#{Formula["readline"].opt_prefix}"
    end

    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"

    # Conflicts with a manpage from the 1.x formula, and
    # gpg-zip isn't installed by this formula anyway
    rm man1/"gpg-zip.1"
  end
end
