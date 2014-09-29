require "formula"

class Irssi < Formula
  homepage "http://irssi.org/"
  url "http://irssi.org/files/irssi-0.8.16.tar.bz2"
  sha1 "631dd70b6d3872c5f81c1a46a6872fef5bd65ffb"
  revision 1

  bottle do
    revision 1
    sha1 "501da22e37c201fcb96f86105855db29c9111de4" => :mavericks
    sha1 "71dc87d1e4a08bcba6969ee2faa674ea61dd9dcd" => :mountain_lion
    sha1 "1efa0d2f3ed9dccfa2b01f52eb3c01a3c27d1303" => :lion
  end

  option "without-perl", "Build without perl support"

  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "openssl" => :optional

  devel do
    url "http://irssi.org/files/irssi-0.8.17-rc1.tar.gz"
    sha1 "583870b51062503437590ab52186a4c6b38591d4"
  end

  # Fix Perl build flags and paths in man page
  patch :DATA

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --with-bot
      --with-proxy
      --enable-ipv6
      --with-socks
      --with-ncurses=#{MacOS.sdk_path}/usr
    ]

    if build.with? "perl"
      args << "--with-perl=yes"
      args << "--with-perl-lib=#{lib}/perl5/site_perl"
    else
      args << "--with-perl=no"
    end

    args << "--enable-ssl" if build.with? "openssl"

    system "./configure", *args

    # "make" and "make install" must be done separately on some systems
    system "make"
    system "make", "install"
  end
end

__END__
--- a/configure	2009-12-03 19:35:07.000000000 -0800
+++ b/configure	2009-12-03 19:35:33.000000000 -0800
@@ -27419,7 +27419,7 @@
 	if test -z "$perlpath"; then
 		perl_check_error="perl binary not found"
 	else
-		PERL_CFLAGS=`$perlpath -MExtUtils::Embed -e ccopts 2>/dev/null`
+		PERL_CFLAGS=`$perlpath -MExtUtils::Embed -e ccopts 2>/dev/null | $SED -e 's/-arch [^ ]\{1,\}//g'`
 	fi

 	if test "x$ac_cv_c_compiler_gnu" = "xyes" -a -z "`echo $host_os|grep 'bsd\|linux'`"; then
@@ -27437,7 +27437,7 @@
 $as_echo "not found, building without Perl" >&6; }
 		want_perl=no
 	else
-		PERL_LDFLAGS=`$perlpath -MExtUtils::Embed -e ldopts 2>/dev/null`
+		PERL_LDFLAGS=`$perlpath -MExtUtils::Embed -e ldopts 2>/dev/null | $SED -e 's/-arch [^ ]\{1,\}//g'`

 		if test "x$DYNLIB_MODULES" = "xno" -a "$want_perl" != "static"; then
 						want_perl=static

diff --git a/docs/irssi.1 b/docs/irssi.1
index 62c2844..482cd96 100644
--- a/docs/irssi.1
+++ b/docs/irssi.1
@@ -65,10 +65,10 @@ display brief usage message.
 .SH SEE ALSO
 .B Irssi
 has been supplied with a huge amount of documentation. Check /help or look
-at the files contained by /usr/share/doc/irssi*
+at the files contained by HOMEBREW_PREFIX/share/doc/irssi*
 .SH FILES
 .TP
-.I /etc/irssi.conf
+.I HOMEBREW_PREFIX/etc/irssi.conf
 Global configuration file
 .TP
 .I ~/.irssi/config
@@ -83,13 +83,13 @@ Default irssi theme
 .I ~/.irssi/away.log
 Logged messages in away status
 .TP
-.I /usr/share/irssi/help/
+.I HOMEBREW_PREFIX/share/irssi/help/
 Directory including many help files
 .TP
-.I /usr/share/irssi/scripts/
+.I HOMEBREW_PREFIX/share/irssi/scripts/
 Global scripts directory
 .TP
-.I /usr/share/irssi/themes/
+.I HOMEBREW_PREFIX/share/irssi/themes/
 Global themes directory
 .TP
 .I ~/.irssi/scripts/
