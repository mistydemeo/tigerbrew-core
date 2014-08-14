require "formula"

class Gnupg2 < Formula
  homepage "https://www.gnupg.org/"
  url "ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-2.0.26.tar.bz2"
  mirror "ftp://ftp.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gnupg/gnupg-2.0.26.tar.bz2"
  sha1 "3ff5b38152c919724fd09cf2f17df704272ba192"

  bottle do
    sha1 "09e5e2acda47c02836d8a1b874f805bec9d9acbf" => :mavericks
    sha1 "1300333cdd1c047179434370aa710a949f72be1c" => :mountain_lion
    sha1 "4fecb9820b713e81271fb47499fd88c1568890e7" => :lion
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
  depends_on "dirmngr" => :recommended
  depends_on "libusb-compat" => :recommended
  depends_on "readline" => :optional

  # Adjust package name to fit our scheme of packaging both gnupg 1.x and
  # 2.x, and gpg-agent separately, and adjust tests to fit this scheme
  patch :DATA

  def install
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
    system "make check"
    system "make install"

    # Conflicts with a manpage from the 1.x formula, and
    # gpg-zip isn't installed by this formula anyway
    rm man1/"gpg-zip.1"
  end
end

__END__
diff --git a/configure b/configure
index c022805..97b19dc 100755
--- a/configure
+++ b/configure
@@ -578,8 +578,8 @@ MFLAGS=
 MAKEFLAGS=
 
 # Identity of this package.
-PACKAGE_NAME='gnupg'
-PACKAGE_TARNAME='gnupg'
+PACKAGE_NAME='gnupg2'
+PACKAGE_TARNAME='gnupg2'
 PACKAGE_VERSION='2.0.26'
 PACKAGE_STRING='gnupg 2.0.26'
 PACKAGE_BUGREPORT='http://bugs.gnupg.org'
diff --git a/tests/openpgp/Makefile.in b/tests/openpgp/Makefile.in
index c9ceb2d..f58c96e 100644
--- a/tests/openpgp/Makefile.in
+++ b/tests/openpgp/Makefile.in
@@ -312,11 +312,10 @@ GPG_IMPORT = ../../g10/gpg2 --homedir . \
 
 
 # Programs required before we can run these tests.
-required_pgms = ../../g10/gpg2 ../../agent/gpg-agent \
-                ../../tools/gpg-connect-agent
+required_pgms = ../../g10/gpg2 ../../tools/gpg-connect-agent
 
 TESTS_ENVIRONMENT = GNUPGHOME=$(abs_builddir) GPG_AGENT_INFO= LC_ALL=C \
-		    ../../agent/gpg-agent --quiet --daemon sh
+		    gpg-agent --quiet --daemon sh
 
 TESTS = version.test mds.test \
 	decrypt.test decrypt-dsa.test \
