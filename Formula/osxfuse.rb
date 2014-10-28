require "formula"

class Osxfuse < Formula
  homepage "http://osxfuse.github.io"
  url "https://github.com/osxfuse/osxfuse.git", :tag => "osxfuse-2.7.2"

  head "https://github.com/osxfuse/osxfuse.git", :branch => "osxfuse-2"

  bottle do
    sha1 "2e226a7b4d9370fb5406f83b81d797d740df2cf1" => :yosemite
    sha1 "e91d507a3ecbf606ed63084ad78783e67e01fa05" => :mavericks
    sha1 "e9420d4352325ff6761a5ec3f174c77ded42cba3" => :mountain_lion
  end

  depends_on :macos => :snow_leopard
  depends_on :xcode => :build
  depends_on ConflictsWithBinaryOsxfuse
  depends_on UnsignedKextRequirement
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "gettext" => :build

  conflicts_with "fuse4x", :because => "both install `fuse.pc`"

  def install
    # Do not override Xcode build settings
    ENV.remove_cc_etc

    system "./build.sh", "-t", "homebrew", "-f", prefix
  end

  def caveats; <<-EOS.undent
    If upgrading from a previous version of osxfuse, the previous kernel extension
    will need to be unloaded before installing the new version. First, check that
    no FUSE-based file systems are running:

      mount -t osxfusefs

    Unmount all FUSE file systems and then unload the kernel extension:

      sudo kextunload -b com.github.osxfuse.filesystems.osxfusefs

    The new osxfuse file system bundle needs to be installed by the root user:

      sudo /bin/cp -RfX #{opt_prefix}/Library/Filesystems/osxfusefs.fs /Library/Filesystems/
      sudo chmod +s /Library/Filesystems/osxfusefs.fs/Support/load_osxfusefs
    EOS
  end
end
