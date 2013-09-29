require 'formula'

class Osxfuse < Formula
  homepage 'http://osxfuse.github.io'
  url 'https://github.com/osxfuse/osxfuse.git', :tag => 'osxfuse-2.6.1_1'

  head 'https://github.com/osxfuse/osxfuse.git', :branch => 'osxfuse-2'

  bottle do
    sha1 'cecee3f4d3d790d4277a4520b988cd8d26eeca90' => :mountain_lion
    sha1 'f2e691264528e5364bc2dede5e8874a75f657b6e' => :lion
    sha1 '40e05305257de14c5dda8058de5ad14440e87dde' => :snow_leopard
  end

  depends_on :macos => :snow_leopard
  depends_on :xcode
  depends_on :autoconf
  depends_on :automake
  depends_on 'gettext' => :build
  depends_on 'libtool' => :build

  def install
    # Do not override Xcode build settings
    ENV.remove_cc_etc

    if MacOS::Xcode.provides_autotools?
      # Xcode version of aclocal does not respect ACLOCAL_PATH
      ENV['ACLOCAL'] = 'aclocal ' + ENV['ACLOCAL_PATH'].split(':').map {|p| '-I' + p}.join(' ')
    end

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

      sudo /bin/cp -RfX #{prefix}/Library/Filesystems/osxfusefs.fs /Library/Filesystems
      sudo chmod +s /Library/Filesystems/osxfusefs.fs/Support/load_osxfusefs
    EOS
  end
end
