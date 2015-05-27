class Wireshark < Formula
  homepage "https://www.wireshark.org"

  stable do
    url "https://www.wireshark.org/download/src/all-versions/wireshark-1.12.5.tar.bz2"
    mirror "https://1.eu.dl.wireshark.org/src/wireshark-1.12.5.tar.bz2"
    sha256 "d0f177b2ef49e4deae4ff7d3299bdd295ba558a3934ce8ae489b2f13927cbd82"

    # Removes SDK checks that prevent the build from working on CLT-only systems
    # Reported upstream: https://bugs.wireshark.org/bugzilla/show_bug.cgi?id=9290
    patch :DATA

    depends_on "homebrew/dupes/libpcap" => :optional
  end

  bottle do
    sha256 "4eefb6e29162dec6c87ef79880c5b3a8fa6c9515b1c6c1d94208eb0b14b95f06" => :yosemite
    sha256 "a0bf7759f5bdf3092f35c5cbe6375c4ee6e56fe2ae3d4f9a93ed28b5d9e988ae" => :mavericks
    sha256 "b2294c6fe1dc2de324bc834331f5a1cd76f958c65d7d1b40154f7e1cd48656fe" => :mountain_lion
  end

  head do
    url "https://code.wireshark.org/review/wireshark", :using => :git

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  devel do
    url "https://www.wireshark.org/download/src/all-versions/wireshark-1.99.5.tar.bz2"
    mirror "https://1.eu.dl.wireshark.org/src/wireshark-1.99.5.tar.bz2"
    sha256 "d2d5dd1367eb05037651daf7355888f5938d5ca45fcd730fe117605adf9e6c7c"

    depends_on "homebrew/dupes/libpcap" if MacOS.version == :mavericks
  end

  option "with-gtk+3", "Build the wireshark command with gtk+3"
  option "with-gtk+", "Build the wireshark command with gtk+"
  option "with-qt", "Build the wireshark-qt command (can be used with or without either GTK option)"
  option "with-qt5", "Build the wireshark-qt command with qt5 (can be used with or without either GTK option)"
  option "with-headers", "Install Wireshark library headers for plug-in development"

  depends_on "pkg-config" => :build

  depends_on "glib"
  depends_on "gnutls"
  depends_on "libgcrypt"
  depends_on "d-bus"

  depends_on "geoip" => :recommended
  depends_on "c-ares" => :recommended

  depends_on "libsmi" => :optional
  depends_on "lua" => :optional
  depends_on "portaudio" => :optional
  depends_on "qt5" => :optional
  depends_on "qt" => :optional
  depends_on "gtk+3" => :optional
  depends_on "gtk+" => :optional
  depends_on "gnome-icon-theme" if build.with? "gtk+3"

  def install
    no_gui = build.without?("gtk+3") && build.without?("qt") && build.without?("gtk+") && build.without?("qt5")

    args = ["--disable-dependency-tracking",
            "--disable-silent-rules",
            "--prefix=#{prefix}",
            "--with-gnutls"]

    args << "--disable-wireshark" if no_gui
    args << "--disable-gtktest" if build.without?("gtk+3") && build.without?("gtk+")
    args << "--with-qt" if build.with?("qt") || build.with?("qt5")
    args << "--with-gtk3" if build.with? "gtk+3"
    args << "--with-gtk2" if build.with? "gtk+"
    args << "--with-libcap=#{Formula["libpcap"].opt_prefix}" if build.with? "libpcap"

    if build.head?
      args << "--disable-warnings-as-errors"
      system "./autogen.sh"
    end

    system "./configure", *args
    system "make"
    ENV.deparallelize # parallel install fails
    system "make", "install"

    if build.with? "headers"
      (include/"wireshark").install Dir["*.h"]
      (include/"wireshark/epan").install Dir["epan/*.h"]
      (include/"wireshark/epan/crypt").install Dir["epan/crypt/*.h"]
      (include/"wireshark/epan/dfilter").install Dir["epan/dfilter/*.h"]
      (include/"wireshark/epan/dissectors").install Dir["epan/dissectors/*.h"]
      (include/"wireshark/epan/ftypes").install Dir["epan/ftypes/*.h"]
      (include/"wireshark/epan/wmem").install Dir["epan/wmem/*.h"]
      (include/"wireshark/wiretap").install Dir["wiretap/*.h"]
      (include/"wireshark/wsutil").install Dir["wsutil/*.h"]
    end
  end

  def caveats; <<-EOS.undent
    If your list of available capture interfaces is empty
    (default OS X behavior), try the following commands:

      curl https://bugs.wireshark.org/bugzilla/attachment.cgi?id=3373 -o ChmodBPF.tar.gz
      tar zxvf ChmodBPF.tar.gz
      open ChmodBPF/Install\\ ChmodBPF.app

    This adds a launch daemon that changes the permissions of your BPF
    devices so that all users in the 'admin' group - all users with
    'Allow user to administer this computer' turned on - have both read
    and write access to those devices.

    See bug report:
      https://bugs.wireshark.org/bugzilla/show_bug.cgi?id=3760
    EOS
  end

  test do
    system bin/"randpkt", "-b", "100", "-c", "2", "capture.pcap"
    output = shell_output("#{bin}/capinfos -Tmc capture.pcap")
    assert_equal "File name,Number of packets\ncapture.pcap,2\n", output
  end
end

__END__
diff --git a/configure b/configure
index cd41b63..c473fe7 100755
--- a/configure
+++ b/configure
@@ -16703,42 +16703,12 @@ $as_echo "yes" >&6; }
 				break
 			fi
 		done
-		if test -z "$SDKPATH"
-		then
-			{ $as_echo "$as_me:${as_lineno-$LINENO}: result: no" >&5
-$as_echo "no" >&6; }
-			as_fn_error $? "We couldn't find the SDK for OS X $deploy_target" "$LINENO" 5
-		fi
 		{ $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 $as_echo "yes" >&6; }
 		;;
 	esac

 	#
-	# Add a -mmacosx-version-min flag to force tests that
-	# use the compiler, as well as the build itself, not to,
-	# for example, use compiler or linker features not supported
-	# by the minimum targeted version of the OS.
-	#
-	# Add an -isysroot flag to use the SDK.
-	#
-	CFLAGS="-mmacosx-version-min=$deploy_target -isysroot $SDKPATH $CFLAGS"
-	CXXFLAGS="-mmacosx-version-min=$deploy_target -isysroot $SDKPATH $CXXFLAGS"
-	LDFLAGS="-mmacosx-version-min=$deploy_target -isysroot $SDKPATH $LDFLAGS"
-
-	#
-	# Add a -sdkroot flag to use with osx-app.sh.
-	#
-	OSX_APP_FLAGS="-sdkroot $SDKPATH"
-
-	#
-	# XXX - do we need this to build the Wireshark wrapper?
-	# XXX - is this still necessary with the -mmacosx-version-min
-	# flag being set?
-	#
-	OSX_DEPLOY_TARGET="MACOSX_DEPLOYMENT_TARGET=$deploy_target"
-
-	#
 	# In the installer package XML file, give the deployment target
 	# as the minimum version.
 	#

