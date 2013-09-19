require 'formula'

class Osxutils < Formula
  homepage 'https://github.com/vasi/osxutils'
  url 'https://github.com/vasi/osxutils/archive/v1.8.tar.gz'
  sha1 'c3d20da36ecfae3abff07f482a572b3680a12b6d'

  head 'https://github.com/vasi/osxutils.git'

  conflicts_with 'leptonica',
    :because => "both leptonica and osxutils ship a `fileinfo` executable."

  def install
    system 'make'
    system 'make', "PREFIX=#{prefix}", 'install'
  end
end
