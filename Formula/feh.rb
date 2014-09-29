require "formula"

class Feh < Formula
  homepage "http://feh.finalrewind.org/"
  url "http://feh.finalrewind.org/feh-2.12.tar.bz2"
  sha1 "30eb2b778858b1f4ce97e44c8225758185b0c588"

  depends_on :x11
  depends_on "imlib2"
  depends_on "libexif" => :recommended

  def install
    args = []
    args << "exif=1" if build.with? "libexif"
    system "make", "PREFIX=#{prefix}", *args
    system "make", "PREFIX=#{prefix}", "install"
  end
end
