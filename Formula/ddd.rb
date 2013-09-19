require 'formula'

class Ddd < Formula
  homepage 'http://www.gnu.org/s/ddd/'
  url 'http://ftpmirror.gnu.org/ddd/ddd-3.3.12.tar.gz'
  mirror 'http://ftp.gnu.org/gnu/ddd/ddd-3.3.12.tar.gz'
  sha1 'b91d2dfb1145af409138bd34517a898341724e56'

  depends_on 'lesstif'
  depends_on :x11

  def patches
    if MacOS.version >= :mavericks
      # Needed for OSX 10.9 DP6 build failure:
      # https://savannah.gnu.org/patch/?8178
      { :p0 => 'https://savannah.gnu.org/patch/download.php?file_id=29114' }
    end
  end

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--enable-builtin-app-defaults",
                          "--enable-builtin-manual",
                          "--prefix=#{prefix}"

    # From MacPorts:
    # make will build the executable "ddd" and the X resource file "Ddd" in the same directory,
    # as HFS+ is case-insensitive by default, this will loosely FAIL
    system "make EXEEXT=exe"

    ENV.deparallelize
    system "make install EXEEXT=exe"

    mv bin/'dddexe', bin/'ddd'
  end
end
