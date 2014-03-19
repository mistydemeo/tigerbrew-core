require 'formula'

class Tor < Formula
  homepage 'https://www.torproject.org/'
  url 'https://www.torproject.org/dist/tor-0.2.4.21.tar.gz'
  sha1 'b93b66e4d5162cefc711cb44f9167ed4799ef990'

  devel do
    url 'https://www.torproject.org/dist/tor-0.2.5.2-alpha.tar.gz'
    version '0.2.5.2-alpha'
    sha1 '80f4697dfc0473bf5ec642b074cee4ce95fd0fa6'
  end

  depends_on 'libevent'
  depends_on 'openssl'

  # See https://github.com/mistydemeo/tigerbrew/issues/105
  fails_with :gcc do
    build 5553
    cause "linking fails with: /usr/bin/ld: can't locate file for: -lssp_nonshared"
  end

  def install
    # Fix the path to the control cookie.
    inreplace \
      'contrib/tor-ctrl.sh',
      'TOR_COOKIE="/var/lib/tor/data/control_auth_cookie"',
      'TOR_COOKIE="$HOME/.tor/control_auth_cookie"'

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-openssl-dir=#{Formula["openssl"].opt_prefix}"
    system "make install"

    bin.install "contrib/tor-ctrl.sh" => "tor-ctrl"
  end

  test do
    system "tor", "--version"
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
