require 'formula'

class Goaccess < Formula
  homepage 'http://goaccess.prosoftcorp.com/'
  url 'http://sourceforge.net/projects/goaccess/files/0.5/goaccess-0.5.tar.gz'
  sha1 '97c0c48e41ed0c8cf24cc87f1d39d7be687bc52b'

  head 'git://goaccess.git.sourceforge.net/gitroot/goaccess/goaccess'

  option 'enable-geoip', "Enable IP location information using GeoIP"

  depends_on 'pkg-config' => :build
  depends_on 'glib'
  depends_on 'geoip' if build.include? "enable-geoip"

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]

    args << "--enable-geoip" if build.include? "enable-geoip"

    system "./configure", *args
    system "make install"
  end
end
