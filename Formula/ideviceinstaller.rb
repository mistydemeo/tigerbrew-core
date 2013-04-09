require 'formula'

class Ideviceinstaller < Formula
  homepage 'http://www.libimobiledevice.org/'
  url 'http://www.libimobiledevice.org/downloads/ideviceinstaller-1.0.1.tar.bz2'
  sha1 '7dd57f5d6d4466d8eca5d28fef3c22033b2af2da'

  head 'http://cgit.sukimashita.com/ideviceinstaller.git'

  depends_on 'pkg-config' => :build
  depends_on 'libimobiledevice'
  depends_on 'libzip'

  if build.head?
    depends_on 'autoconf' => :build
    depends_on 'automake' => :build
    depends_on 'libtool' => :build
  end

  def install
    system "./autogen.sh" if build.head?

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end

  def test
    system "#{bin}/ideviceinstaller --help |grep -q ^Usage"
  end
end
