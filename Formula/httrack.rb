require 'formula'

class Httrack < Formula
  homepage 'http://www.httrack.com/'
  # url: Always use mirror.httrack.com when you link to a new version
  # of HTTrack, as link to download.httrack.com will break on next
  # HTTrack update.
  url 'http://mirror.httrack.com/historical/httrack-3.47.11.tar.gz'
  sha1 '237fca7a9c5c63b53c5d0134dac6e5714422384c'

  def install
    ENV.deparallelize
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make install"
    # Don't need Gnome integration
    rm_rf share+'applications'
    rm_rf share+'pixmaps'
  end
end
