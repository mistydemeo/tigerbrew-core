require 'formula'

class Sysbench < Formula
  homepage 'http://sysbench.sourceforge.net/'
  url 'http://downloads.sourceforge.net/project/sysbench/sysbench/0.4.12/sysbench-0.4.12.tar.gz'
  sha1 '3f346e8b29b738711546970b027bbb7359d4672a'

  depends_on 'automake'
  depends_on :mysql       => :recommended
  depends_on :postgresql  => :optional

  def install
    inreplace 'configure.ac', 'AC_PROG_LIBTOOL', 'AC_PROG_RANLIB'

    system "./autogen.sh"

    args = ["--prefix=#{prefix}"]
    args << "--with-mysql" if build.with? 'mysql'
    args << "--with-psql" if build.with? 'postgresql'

    system "./configure", *args
    system "make install"
  end
end
