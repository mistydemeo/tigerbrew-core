require 'formula'

class Camlistore < Formula
  homepage 'http://camlistore.org'
  head 'https://camlistore.googlesource.com/camlistore', :using => :git
  url 'https://github.com/bradfitz/camlistore/archive/0.5.tar.gz'
  sha1 'f089410910cdf8c79ab2cf5ac377f2ccbaafe618'

  depends_on 'pkg-config' => :build
  depends_on 'go' => :build

  def install
    ENV['GIT_DIR'] = cached_download+".git"

    system "go", "run", "make.go"
    prefix.install "bin/README"
    prefix.install "bin"
  end

  test do
    system bin/"camget", "-version"
  end
end
