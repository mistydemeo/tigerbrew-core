require 'formula'

class Cloog < Formula
  homepage 'http://www.cloog.org/'
  url 'http://www.bastoul.net/cloog/pages/download/count.php3?url=./cloog-0.18.1.tar.gz'
  sha1 '2dc70313e8e2c6610b856d627bce9c9c3f848077'

  bottle do
    cellar :any
    revision 1
    sha1 '38afdce382abcd3c46fb94af7eb72e87d87859d4' => :mavericks
    sha1 'd6984ce335cf7b8eb482cdd4f0301c6583b00073' => :mountain_lion
    sha1 'fd707268c3e5beafa9b98a768f7064d5b9699178' => :lion
  end

  depends_on 'pkg-config' => :build
  depends_on 'gmp'
  depends_on 'isl'

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-gmp=system",
                          "--with-gmp-prefix=#{Formula.factory("gmp").opt_prefix}",
                          "--with-isl=system",
                          "--with-isl-prefix=#{Formula.factory("isl").opt_prefix}"
    system "make install"
  end

  test do
    cloog_source = <<-EOS.undent
      c

      0 2
      0

      1

      1
      0 2
      0 0 0
      0

      0
    EOS

    require 'open3'
    Open3.popen3("#{bin}/cloog", "/dev/stdin") do |stdin, stdout, _|
      stdin.write(cloog_source)
      stdin.close
      assert_match /Generated from \/dev\/stdin by CLooG/, stdout.read
    end
  end
end
