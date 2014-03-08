require 'formula'

class Bitlbee < Formula
  homepage 'http://www.bitlbee.org/'
  url 'http://get.bitlbee.org/src/bitlbee-3.2.1.tar.gz'
  sha1 '954471ab87206826c072f31b3def40a1be5a78f5'
  revision 2

  option 'with-finch', "Use finch/libpurple for all communication with instant messaging networks"
  option 'with-libotr', "Build with otr (off the record) support"

  depends_on 'pkg-config' => :build
  depends_on 'glib'
  depends_on 'gnutls'
  depends_on 'libgcrypt'
  depends_on 'finch' => :optional
  depends_on 'libotr' => :optional

  def install
    args = ["--prefix=#{prefix}",
            "--debug=0",
            "--ssl=gnutls",
            "--pidfile=#{var}/bitlbee/run/bitlbee.pid",
            "--config=#{var}/bitlbee/lib/",
            "--ipsocket=#{var}/bitlbee/run/bitlbee.sock"]

    args << "--purple=1" if build.with? "finch"
    args << "--otr=1" if build.with? "libotr"

    system "./configure", *args

    # This build depends on make running first.
    system "make"
    system "make install"
    # Install the dev headers too
    system "make install-dev"
    # This build has an extra step.
    system "make install-etc"

    (var+"bitlbee/run").mkpath
    (var+"bitlbee/lib").mkpath
  end
end
