require 'formula'

class Liblwgeom < Formula
  homepage 'http://postgis.net'
  url 'http://download.osgeo.org/postgis/source/postgis-2.1.1.tar.gz'
  sha1 'eaff009fb22b8824f89e5aa581e8b900c5d8f65b'

  head do
    url 'http://svn.osgeo.org/postgis/trunk/'
    depends_on 'postgresql' => :build # don't maintain patches for HEAD
  end

  keg_only "Conflicts with PostGIS, which also installs liblwgeom.dylib"

  depends_on :autoconf => :build
  depends_on :automake => :build
  depends_on :libtool => :build
  depends_on 'gpp' => :build

  depends_on 'proj'
  depends_on 'geos'
  depends_on 'json-c'

  def patches
    if build.stable?
      # Strip all the PostgreSQL functions from PostGIS configure.ac, to allow
      # building liblwgeom.dylib without needing PostgreSQL
      # NOTE: this will need to be maintained per postgis version
      "https://gist.github.com/dakcarto/7458788/raw/8df39204eef5a1e5671828ded7f377ad0f61d4e1/postgis-config_strip-pgsql.diff"
    end
  end

  def install
    # See postgis.rb for comments about these settings
    ENV.deparallelize

    args = [
      "--disable-dependency-tracking",
      "--disable-nls",

      "--with-projdir=#{HOMEBREW_PREFIX}",
      "--with-jsondir=#{Formula.factory('json-c').opt_prefix}",

      # Disable extraneous support
      "--without-libiconv-prefix",
      "--without-libintl-prefix",
      "--without-raster", # this ensures gdal is not required
      "--without-topology"
    ]

    args << "--with-pgconfig=#{Formula.factory('postgresql').opt_prefix.realpath}/bin/pg_config" if build.head?

    system './autogen.sh'
    system './configure', *args

    mkdir 'stage'
    cd 'liblwgeom' do
      system 'make', 'install', "DESTDIR=#{buildpath}/stage"
    end

    # NOTE: lib.install Dir['stage/**/lib/*'] fails (symlink is not resolved)
    prefix.install Dir["stage/**/lib"]
    include.install Dir["stage/**/include/*"]
  end
end
