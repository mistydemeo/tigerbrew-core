require 'formula'

class Geoip < Formula
  homepage 'http://www.maxmind.com/app/c'
  url 'http://geolite.maxmind.com/download/geoip/api/c/GeoIP-1.5.1.tar.gz'
  sha1 '36b211ad1857431772f811b126422aea6b68a122'

  # These are needed for the autoreconf it always tries to run.
  depends_on :automake
  depends_on :libtool

  option :universal

  def install
    ENV.universal_binary if build.universal?

    # Fixes a build error on Lion when configure does a variant of autoreconf
    # that results in a botched Makefile, causing this error:
    # No rule to make target '../libGeoIP/libGeoIP.la', needed by 'geoiplookup'
    # This works on Snow Leopard also when it tries but fails to run autoreconf.
    system "autoreconf", "-ivf"

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end

  test do
    system "#{bin}/geoiplookup", '8.8.8.8'
  end
end
