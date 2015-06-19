class Cloog < Formula
  desc "Generate code for scanning Z-polyhedra"
  homepage "http://www.cloog.org/"
  url "http://www.bastoul.net/cloog/pages/download/count.php3?url=./cloog-0.18.3.tar.gz"
  sha256 "460c6c740acb8cdfbfbb387156b627cf731b3837605f2ec0001d079d89c69734"

  bottle do
    cellar :any
    sha1 "e169f6e0745ddcb4ab3460afc4b51ec3dd8bfb28" => :tiger_altivec
    sha1 "f7945f830390060dce393f4137220d599485200e" => :leopard_g3
    sha1 "64402d3c088200a45ee65d0ac4aa37cc968d98d1" => :leopard_altivec
  end

  head do
    url "http://repo.or.cz/r/cloog.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "gmp"
  depends_on "isl"

  def install
    system "./autogen.sh" if build.head?

    args = [
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--prefix=#{prefix}",
      "--with-gmp=system",
      "--with-gmp-prefix=#{Formula["gmp"].opt_prefix}",
      "--with-isl=system",
      "--with-isl-prefix=#{Formula["isl"].opt_prefix}"
    ]

    args << "--with-osl=bundled" if build.head?

    system "./configure", *args
    system "make", "install"
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

    output = pipe_output("#{bin}/cloog /dev/stdin", cloog_source)
    assert_match %r{Generated from /dev/stdin by CLooG}, output
  end
end
