require 'formula'

class Ifuse < Formula
  homepage 'http://www.libimobiledevice.org/'
  url 'http://www.libimobiledevice.org/downloads/ifuse-1.1.2.tar.bz2'
  sha1 '885d88b45edb85c38b0ce9863f0d45fd378b5614'

  head do
    url 'http://cgit.sukimashita.com/ifuse.git'

    depends_on 'autoconf' => :build
    depends_on 'automake' => :build
    depends_on 'libtool' => :build
  end

  depends_on 'pkg-config' => :build
  depends_on 'glib'
  depends_on 'libimobiledevice'
  depends_on 'fuse4x'

  def install
    system "./autogen.sh" if build.head?

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end
end
