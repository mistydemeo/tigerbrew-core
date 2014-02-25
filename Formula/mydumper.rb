require 'formula'

class Mydumper < Formula
  homepage 'https://launchpad.net/mydumper'
  url 'https://launchpad.net/mydumper/0.5/0.5.2/+download/mydumper-0.5.2.tar.gz'
  sha1 '1eb1a341635c252f9f4cf611af544e0c94b1687d'

  depends_on 'pkg-config' => :build
  depends_on 'cmake' => :build
  depends_on :mysql
  depends_on 'glib'
  depends_on 'pcre'

  def install
    system "cmake", ".", *std_cmake_args
    system "make install"
  end

  test do
    system "#{bin}/mydumper", "--version"
  end
end
