require 'formula'

class SbclBootstrapBinaries < Formula
  url 'http://downloads.sourceforge.net/project/sbcl/sbcl/1.1.0/sbcl-1.1.0-x86-64-darwin-binary.tar.bz2'
  sha1 'ed2069e124027c43926728c48d604efbb4e33950'
  version "1.1.0"
end

class Sbcl < Formula
  homepage 'http://www.sbcl.org/'
  url 'http://downloads.sourceforge.net/project/sbcl/sbcl/1.1.11/sbcl-1.1.11-source.tar.bz2'
  sha1 '6c6e5366cf3de088c1ee2903de4c250af43c49d5'

  head 'git://sbcl.git.sourceforge.net/gitroot/sbcl/sbcl.git'

  bottle do
    sha1 'ce4c2d31115b6daac9665754826c410d05a68ab4' => :mountain_lion
    sha1 '7c2fe7e01cdf42dbd6c295622d861730615c6eed' => :lion
    sha1 'ed81454325e6b318b5ef0d60bf11a5aaea7eb51c' => :snow_leopard
  end

  fails_with :llvm do
    build 2334
    cause "Compilation fails with LLVM."
  end

  option "32-bit"
  option "without-threads", "Build SBCL without support for native threads"
  option "with-ldb", "Include low-level debugger in the build"
  option "with-internal-xref", "Include XREF information for SBCL internals (increases core size by 5-6MB)"

  def patches
    { :p0 => [
        "https://trac.macports.org/export/88830/trunk/dports/lang/sbcl/files/patch-base-target-features.diff",
        "https://trac.macports.org/export/88830/trunk/dports/lang/sbcl/files/patch-make-doc.diff",
        "https://trac.macports.org/export/88830/trunk/dports/lang/sbcl/files/patch-posix-tests.diff",
        "https://trac.macports.org/export/88830/trunk/dports/lang/sbcl/files/patch-use-mach-exception-handler.diff"
    ]}
  end

  def write_features
    features = []
    features << ":sb-thread" unless build.include? "without-threads"
    features << ":sb-ldb" if build.include? "with-ldb"
    features << ":sb-xref-for-internals" if build.include? "with-internal-xref"

    File.open("customize-target-features.lisp", "w") do |file|
      file.puts "(lambda (list)"
      features.each do |f|
        file.puts "  (pushnew #{f} list)"
      end
      file.puts "  list)"
    end
  end

  def install
    write_features

    # Remove non-ASCII values from environment as they cause build failures
    # More information: http://bugs.gentoo.org/show_bug.cgi?id=174702
    ENV.delete_if do |key, value|
      value =~ /[\x80-\xff]/n
    end

    SbclBootstrapBinaries.new.brew do
      # We only need the binaries for bootstrapping, so don't install anything:
      command = Dir.pwd + "/src/runtime/sbcl"
      core = Dir.pwd + "/output/sbcl.core"
      xc_cmdline = "#{command} --core #{core} --disable-debugger --no-userinit --no-sysinit"

      cd buildpath do
        ENV['SBCL_ARCH'] = 'x86' if build.build_32_bit?
        system "./make.sh", "--prefix=#{prefix}", "--xc-host=#{xc_cmdline}"
      end
    end

    ENV['INSTALL_ROOT'] = prefix
    system "sh install.sh"
  end

  test do
    system "#{bin}/sbcl", "--version"
  end
end
