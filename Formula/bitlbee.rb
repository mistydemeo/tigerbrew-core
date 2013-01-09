require 'formula'

class Bitlbee < Formula
  homepage 'http://www.bitlbee.org/'
  url 'http://get.bitlbee.org/src/bitlbee-3.0.6.tar.gz'
  sha1 '6ac7cab4dab422f9baac97818e69ee9934db345c'

  option 'purple', "Use libpurple for all communication with instant messaging networks"
  option 'with-otr', "Build with otr (off the record) support"

  depends_on 'glib'
  depends_on 'pkg-config' => :build
  depends_on 'gnutls'
  depends_on 'libgcrypt'
  depends_on 'libpurple' => :optional if build.include? 'purple'
  depends_on 'libotr' => :optional if build.include? 'with-otr'

  def install
    # By default Homebrew will set ENV['LD'] to the same as ENV['CC'] which
    # defaults to /usr/bin/cc (see Library/Homebrew/extend/ENV.rb:39) However
    # this will break as bitlbee uses one of those odd and rare Makefiles that
    # can't handle the linker being 'cc' and must be 'ld' (don't ask me some C
    # magician will know).
    ENV['LD'] = '/usr/bin/ld'

    args = ["--prefix=#{prefix}",
            "--debug=0",
            "--ssl=gnutls",
            "--pidfile=#{var}/bitlbee/run/bitlbee.pid",
            "--config=#{var}/bitlbee/lib/",
            "--ipsocket=#{var}/bitlbee/run/bitlbee.sock"]

    args << "--purple=1" if build.include? "purple"
    args << "--otr=1" if build.include? "with-otr"

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
