require 'formula'

class GnuTar < Formula
  homepage 'http://www.gnu.org/software/tar/'
  url 'http://ftpmirror.gnu.org/tar/tar-1.27.tar.gz'
  mirror 'http://ftp.gnu.org/gnu/tar/tar-1.27.tar.gz'
  sha1 '790cf784589a9fcc1ced33517e71051e3642642f'

  bottle do
    sha1 "0145c9b2b1b4d54b03afa85514c44dc9755b5afe" => :mavericks
    sha1 "3816d5a949aada9ed280d524187ab05a4ab28447" => :mountain_lion
    sha1 "4d9843926d6dc0bb2f19c6e94d537a1f1618986b" => :lion
  end

  def install
    args = ["--prefix=#{prefix}", "--mandir=#{man}"]
    args << "--program-prefix=g"

    system "./configure", *args
    system "make install"

    # Symlink the executable into libexec/gnubin as "tar"
    (libexec/'gnubin').install_symlink bin/"gtar" => "tar"
  end

  def caveats; <<-EOS.undent
    gnu-tar has been installed as 'gtar'.

    If you really need to use it as 'tar', you can add a 'gnubin' directory
    to your PATH from your bashrc like:

        PATH="#{opt_libexec}/gnubin:$PATH"
    EOS
  end
end
