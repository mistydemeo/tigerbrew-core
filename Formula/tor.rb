require "formula"

class Tor < Formula
  homepage "https://www.torproject.org/"
  url "https://www.torproject.org/dist/tor-0.2.4.23.tar.gz"
  sha256 "05a3793cfb66b694cb5b1c8d81226d0f7655031b0d5e6a8f5d9c4c2850331429"
  revision 1

  bottle do
    revision 1
    sha1 "b58db7a56a1b8e58ce6a3687d8c91d98de880327" => :mavericks
    sha1 "2f7888fac6b4811a8ca282477c6d32d91b10ce90" => :mountain_lion
    sha1 "d1ada402fd751dab3aa912ae51a7452ee55c9d6e" => :lion
  end

  devel do
    url "https://www.torproject.org/dist/tor-0.2.5.6-alpha.tar.gz"
    version "0.2.5.6-alpha"
    sha256 "ec8edfd824a65bec19c7b79bacfc73c5df76909477ab6dac0d6e8ede7fa337c1"
  end

  depends_on "libevent"
  depends_on "openssl"

  # See https://github.com/mistydemeo/tigerbrew/issues/105
  fails_with :gcc do
    build 5553
    cause "linking fails with: /usr/bin/ld: can't locate file for: -lssp_nonshared"
  end

  def install
    if build.stable?
      # Fix the path to the control cookie. (tor-ctrl removed in v0.2.5.5.)
      inreplace "contrib/tor-ctrl.sh",
        'TOR_COOKIE="/var/lib/tor/data/control_auth_cookie"',
        'TOR_COOKIE="$HOME/.tor/control_auth_cookie"'
    end

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--with-openssl-dir=#{Formula["openssl"].opt_prefix}"
    system "make install"

    if build.stable?
      # (tor-ctrl removed in v0.2.5.5.)
      bin.install "contrib/tor-ctrl.sh" => "tor-ctrl"
    end
  end

  test do
    system bin/"tor", "--version"
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/tor</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
    </plist>
    EOS
  end
end
