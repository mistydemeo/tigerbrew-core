require 'formula'

class Lighttpd < Formula
  homepage 'http://www.lighttpd.net/'
  url 'http://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-1.4.32.tar.bz2'
  sha256 '60691b2dcf3ad2472c06b23d75eb0c164bf48a08a630ed3f308f61319104701f'

  option 'with-lua', 'Include Lua scripting support for mod_magnet'

  depends_on 'pkg-config' => :build
  depends_on 'pcre'
  depends_on 'lua' => :optional

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --with-openssl
      --with-ldap
    ]
    args << "--with-lua" if build.with? 'lua'
    system "./configure", *args
    system "make install"
  end
end
