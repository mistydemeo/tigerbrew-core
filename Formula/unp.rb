require 'formula'

class Unp < Formula
  homepage 'http://packages.debian.org/source/stable/unp'
  url 'http://mirrors.kernel.org/debian/pool/main/u/unp/unp_2.0~pre4.tar.gz'
  mirror 'http://ftp.us.debian.org/debian/pool/main/u/unp/unp_2.0~pre4.tar.gz'
  sha1 '6c07989297a1f15bd629bd64ff02d6cd13919775'
  version '2.0-pre4'

  devel do
    url 'http://mirrors.kernel.org/debian/pool/main/u/unp/unp_2.0~pre7+nmu1.tar.bz2'
    mirror 'http://ftp.us.debian.org/debian/pool/main/u/unp/unp_2.0~pre7+nmu1.tar.bz2'
    sha1 'b91f4cbc4720b3aace147652ac2043cf74668244'
    version '2.0-pre7-nmu1'
  end

  depends_on 'p7zip'

  def install
    bin.install %w[unp ucat]
    man1.install "debian/unp.1"
    bash_completion.install 'bash_completion.d/unp'
    %w[ COPYING CHANGELOG ].each { |f| rm f }
    mv 'debian/README.Debian', 'README'
    mv 'debian/copyright', 'COPYING'
    mv 'debian/changelog', 'ChangeLog'
  end
end
