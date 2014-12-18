require 'formula'

class Geoserver < Formula
  homepage 'http://geoserver.org/'
  url 'https://downloads.sourceforge.net/project/geoserver/GeoServer/2.6.1/geoserver-2.6.1-bin.zip'
  sha1 'c9673fcf659671854eda64cfaacf6f4d1218dc42'

  def install
    libexec.install Dir['*']
    (bin/'geoserver').write <<-EOS.undent
      #!/bin/sh
      if [ -z "$1" ]; then
        echo "Usage: $ geoserver path/to/data/dir"
      else
        cd "#{libexec}" && java -DGEOSERVER_DATA_DIR=$1 -jar start.jar
      fi
    EOS
  end

  def caveats; <<-EOS.undent
    To start geoserver:
      geoserver path/to/data/dir

    See the Geoserver homepage for more setup information:
      brew home geoserver
    EOS
  end
end
