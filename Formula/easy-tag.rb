require 'formula'

class EasyTag < Formula
  homepage 'http://projects.gnome.org/easytag'
  url 'http://download.gnome.org/sources/easytag/2.1/easytag-2.1.8.tar.xz'
  sha1 '7f9246b0eab97ed9739daf5356c89925634241a2'

  depends_on :x11
  depends_on 'pkg-config' => :build
  depends_on 'intltool' => :build
  depends_on 'xz' => :build
  depends_on 'glib'
  depends_on 'gtk+'
  depends_on 'libid3tag'
  depends_on 'id3lib'
  depends_on 'libvorbis' => :optional
  depends_on 'speex' => :optional
  depends_on 'flac' => :optional
  depends_on 'mp4v2' => :optional
  depends_on 'wavpack' => :optional

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    ENV.deparallelize # make install fails in parallel
    system "make install"
  end
end


