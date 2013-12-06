require 'formula'

class Isl < Formula
  homepage 'http://freecode.com/projects/isl'
  # Note: Always use tarball instead of git tag for stable version.
  #
  # Currently isl detects its version using source code directory name
  # and update isl_version() function accordingly.  All other names will
  # result in isl_version() function returning "UNKNOWN" and hence break
  # package detection.
  url 'http://isl.gforge.inria.fr/isl-0.12.1.tar.bz2'
  sha1 'a54e80a32bc3e06327053d77d6a81516d4f4b21f'

  bottle do
    cellar :any
    revision 1
    sha1 '21be0afcb4a8e12113895acc3feb918491631492' => :mavericks
    sha1 'bec8efe48e2df6b2bc208d0b5e12131becc2d6dd' => :mountain_lion
    sha1 'd83758ab5ea858564f5821c59716e584d3877cfd' => :lion
  end

  head do
    url 'http://repo.or.cz/r/isl.git'

    depends_on :autoconf => :build
    depends_on :automake => :build
    depends_on :libtool => :build
  end

  depends_on 'gmp'

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-gmp=system",
                          "--with-gmp-prefix=#{Formula.factory("gmp").opt_prefix}"
    system "make"
    system "make", "install"
    (share/"gdb/auto-load").install Dir["#{lib}/*-gdb.py"]
  end
end
