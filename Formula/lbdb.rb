require 'formula'

# Originally:
#   homepage 'http://www.spinnaker.de/lbdb/'

class Lbdb < Formula
  homepage 'https://github.com/tgray/lbdb/'
  url 'https://github.com/tgray/lbdb/archive/v0.38.1.tar.gz'
  sha1 '6593d81a29d791da9347d7ee053be98ed0cf95fd'

  head 'https://github.com/tgray/lbdb.git'

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end

  def caveats; <<-EOS.undent
    lbdb from <http://www.spinnaker.de/lbdb/> doesn't build on OS X because the
    XCode project file is not compatible with XCode 4 or OS X 10.7.  This
    version of lbdb has been modified to fix this.  A query was sent to the
    upstream maintainer to see if he was interested in the patch, but so far,
    there has been no response.

    The homepage of this version is <https://github.com/tgray/lbdb/>
    EOS
  end
end
