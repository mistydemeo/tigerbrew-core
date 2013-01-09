require 'formula'

class Ykpers < Formula
  homepage 'http://code.google.com/p/yubikey-personalization/'
  url 'http://yubikey-personalization.googlecode.com/files/ykpers-1.11.1.tar.gz'
  sha1 '454f82e3ec0bbc7224fac542cf761db71c584621'

  depends_on 'libyubikey'

  # Pre-Lion fix, per MacPorts. See:
  # https://trac.macports.org/ticket/34910
  def patches
    {:p0 =>
    "https://trac.macports.org/export/96037/trunk/dports/security/ykpers/files/patch-pre-Lion-strnlen.diff"
    } unless MacOS.version >= :lion
  end

  def install
    libyubikey_prefix = Formula.factory('libyubikey').prefix
    system "./configure", "--prefix=#{prefix}",
                          "--with-libyubikey-prefix=#{libyubikey_prefix}",
                          '--with-backend=osx',
                          '--disable-dependency-tracking'
    system "make install"
  end
end
