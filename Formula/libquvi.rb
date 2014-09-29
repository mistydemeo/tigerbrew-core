require 'formula'

class Libquvi < Formula
  homepage 'http://quvi.sourceforge.net/'
  url 'https://downloads.sourceforge.net/project/quvi/0.4/libquvi/libquvi-0.4.1.tar.bz2'
  sha1 'b7ac371185c35a1a9a2135ef4ee61c86c48f78f4'
  revision 1

  bottle do
    sha1 "91f2b77a689f7086ab9d9c2342bcd7802718147f" => :mavericks
    sha1 "d140b93f469bc9227913dab2ab98f3f7298bd792" => :mountain_lion
    sha1 "8be78a6d012269633c435abd6a9b544ec098e05f" => :lion
  end

  depends_on 'pkg-config' => :build
  depends_on 'lua'

  resource 'scripts' do
    url 'https://downloads.sourceforge.net/project/quvi/0.4/libquvi-scripts/libquvi-scripts-0.4.14.tar.xz'
    sha1 'fe721c8d882c5c4a826f1339c79179c56bb0fe41'
  end

  def install
    scripts = prefix/'libquvi-scripts'
    resource('scripts').stage do
      system "./configure", "--prefix=#{scripts}", "--with-nsfw"
      system "make install"
    end
    ENV.append_path 'PKG_CONFIG_PATH', "#{scripts}/lib/pkgconfig"

    # Lua 5.2 does not have a proper lua.pc
    ENV['liblua_CFLAGS'] = ' '
    ENV['liblua_LIBS'] = '-llua'

    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make install"
  end
end
