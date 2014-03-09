require 'formula'

class Ghc < Formula
  homepage "http://haskell.org/ghc/"
  url "http://www.haskell.org/ghc/dist/7.6.3/ghc-7.6.3-src.tar.bz2"
  sha1 "8938e1ef08b37a4caa071fa169e79a3001d065ff"

  bottle do
    revision 2
    sha1 "a6ceeb3f1f9ba2cf0454dc9d45dce69f8a5ae736" => :mavericks
    sha1 "d91ee56c8066bae5173f705e83e15dbb8842f67f" => :mountain_lion
    sha1 "1569f19cdad2675cbff328c0e259d6b8573e9d11" => :lion
  end

  option "tests", "Verify the build using the testsuite."

  devel do
    # http://www.haskell.org/ghc/dist/7.8.1-rc1/README.osx.html
    # This block should largely translate over for 7.8.1 when GM.
    url "http://www.haskell.org/ghc/dist/7.8.1-rc1/ghc-7.8.20140130-src.tar.bz2"
    sha1 "b9c4d76ff71225fe58bdc4e53d7c659643463b5a"

    # Upstream documentation says lion, but brew test-bot 10.7 fails.
    depends_on :macos => :mountain_lion

    resource "binary" do
      url "http://www.haskell.org/ghc/dist/7.8.1-rc1/ghc-7.8.20140130-x86_64-apple-darwin-lion.tar.bz2"
      sha1 "9026d889b160fbf56f97ec1e91576a20e5eec725"
    end

    resource "testsuite" do
      url "http://www.haskell.org/ghc/dist/7.8.1-rc1/ghc-7.8.20140130-testsuite.tar.bz2"
      sha1 "17b1d486c1111633bcfa940b9bf940194cf09bc9"
    end
  end

  # These don't work inside of a `stable do` block
  if build.stable?
    env :std

    fails_with :clang do
      cause <<-EOS.undent
        Building with Clang configures GHC to use Clang as its preprocessor,
        which causes subsequent GHC-based builds to fail.
      EOS
    end
  end

  stable do
    # http://hackage.haskell.org/trac/ghc/ticket/6009
    depends_on :macos => :snow_leopard
    depends_on "apple-gcc42" if MacOS.version >= :mountain_lion
    depends_on "gmp"

    option "32-bit"

    resource "binary" do
      url "http://www.haskell.org/ghc/dist/7.4.2/ghc-7.4.2-x86_64-apple-darwin.tar.bz2"
      sha1 "7c655701672f4b223980c3a1068a59b9fbd08825"
    end

    resource "binary32" do
      url "http://www.haskell.org/ghc/dist/7.4.2/ghc-7.4.2-i386-apple-darwin.tar.bz2"
      sha1 "60f749893332d7c22bb4905004a67510992d8ef6"
    end

    resource "testsuite" do
      url "https://github.com/ghc/testsuite/archive/ghc-7.6.3-release.tar.gz"
      sha1 "6a1973ae3cccdb2f720606032ae84ffee8680ca1"
    end
  end

  def patches
    if build.stable?
      # Fixes 7.6.3 compilation on 10.9
      DATA if MacOS.version >= :mavericks
    end
  end

  def install
    # Move the main tarball contents into a subdirectory
    (buildpath+"Ghcsource").install Dir["*"]

    if (not build.stable?) or (Hardware.is_64_bit? and not build.build_32_bit?)
      binary_resource = "binary"
    else
      binary_resource = "binary32"
    end

    resource(binary_resource).stage do
      # Define where the subformula will temporarily install itself
      subprefix = buildpath+"subfo"

      # ensure configure does not use Xcode 5 "gcc" which is actually clang
      args = ["--prefix=#{subprefix}"]
      args << "--with-gcc=#{ENV.cc}"

      system "./configure", *args
      # -j1 fixes an intermittent race condition
      system "make", "-j1", "install"
      ENV.prepend_path "PATH", subprefix/"bin"
    end

    cd "Ghcsource" do
      # Fix an assertion when linking ghc with llvm-gcc
      # https://github.com/Homebrew/homebrew/issues/13650
      ENV["LD"] = "ld"

      if Hardware.is_64_bit? and not build.build_32_bit?
        arch = "x86_64"
      else
        ENV.m32 # Need to force this to fix build error on internal libgmp_ar.
        arch = "i386"
      end

      # ensure configure does not use Xcode 5 "gcc" which is actually clang
      args = ["--prefix=#{prefix}", "--build=#{arch}-apple-darwin"]
      args << "--with-gcc=#{ENV.cc}"

      system "./configure", *args
      system "make"

      if build.include? "tests"
        resource("testsuite").stage do
          (buildpath+"Ghcsource/config").install Dir["config/*"]
          (buildpath+"Ghcsource/driver").install Dir["driver/*"]
          (buildpath+"Ghcsource/mk").install Dir["mk/*"]
          (buildpath+"Ghcsource/tests").install Dir["tests/*"]
          (buildpath+"Ghcsource/timeout").install Dir["timeout/*"]
          cd (buildpath+"Ghcsource/tests") do
            system "make", "CLEANUP=1", "THREADS=#{ENV.make_jobs}", "fast"
          end
        end
      end

      system "make"
      # -j1 fixes an intermittent race condition
      system "make", "-j1", "install"
    end
  end

  def caveats; <<-EOS.undent
    This brew is for GHC only; you might also be interested in haskell-platform.
    EOS
  end

  test do
    hello = (testpath/"hello.hs")
    hello.write('main = putStrLn "Hello Homebrew"')
    output = `echo "main" | '#{bin}/ghci' #{hello}`
    assert $?.success?
    assert_match /Hello Homebrew/i, output
  end
end

__END__
diff --git a/includes/HsFFI.h b/includes/HsFFI.h
index 652fbea..a21811e 100644
--- a/includes/HsFFI.h
+++ b/includes/HsFFI.h
@@ -21,7 +21,7 @@ extern "C" {
 #include "stg/Types.h"

 /* get limits for integral types */
-#ifdef HAVE_STDINT_H
+#if defined HAVE_STDINT_H && !defined USE_INTTYPES_H_FOR_RTS_PROBES_D
 /* ISO C 99 says:
  * "C++ implementations should define these macros only when
  * __STDC_LIMIT_MACROS is defined before <stdint.h> is included."
diff --git a/rts/RtsProbes.d b/rts/RtsProbes.d
index 13f40f8..226f881 100644
--- a/rts/RtsProbes.d
+++ b/rts/RtsProbes.d
@@ -6,6 +6,12 @@
  *
  * ---------------------------------------------------------------------------*/

+#ifdef __APPLE__ && __MACH__
+# if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_9
+#  define USE_INTTYPES_H_FOR_RTS_PROBES_D
+# endif
+#endif
+
 #include "HsFFI.h"
 #include "rts/EventLogFormat.h"

diff --git a/utils/mkdirhier/mkdirhier.sh b/utils/mkdirhier/mkdirhier.sh
index 4c5d5f7..80762f4 100644
--- a/utils/mkdirhier/mkdirhier.sh
+++ b/utils/mkdirhier/mkdirhier.sh
@@ -1,4 +1,4 @@
 #!/bin/sh

-mkdir -p ${1+"$@"}
+mkdir -p ${1+"./$@"}
