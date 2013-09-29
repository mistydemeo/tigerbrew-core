require 'formula'

class Neon < Formula
  homepage 'http://www.webdav.org/neon/'
  url 'http://www.webdav.org/neon/neon-0.29.6.tar.gz'
  sha1 'ae1109923303f67ed3421157927bc4bc29c58961'

  keg_only :provided_by_osx,
            "Compiling newer versions of Subversion on 10.6 require this newer neon."

  option :universal
  option 'with-brewed-openssl', 'Include OpenSSL support via Homebrew'

  depends_on 'pkg-config' => :build
  depends_on 'openssl' if build.with? 'brewed-openssl'

  def install
    ENV.universal_binary if build.universal?
    ENV.enable_warnings
    args = [
      "--disable-debug",
      "--prefix=#{prefix}",
      "--enable-shared",
      "--disable-static",
      "--disable-nls",
      "--with-ssl",
    ]
    if build.with? 'brewed-openssl'
      args << "--with-libs=" + Formula.factory('openssl').opt_prefix.to_s
    end
    system "./configure", *args
    system "make install"
  end
end
