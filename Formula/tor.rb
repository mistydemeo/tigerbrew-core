require 'formula'

class Tor < Formula
  homepage 'https://www.torproject.org/'
  url 'https://www.torproject.org/dist/tor-0.2.3.25.tar.gz'
  sha1 'ef02e5b0eb44ab1a5d6108c39bd4e28918de79dc'

  option "with-brewed-openssl", "Build with Homebrew's OpenSSL instead of the system version"

  depends_on 'libevent'
  depends_on 'openssl' if build.with? 'brewed-openssl'

  # See https://github.com/mistydemeo/tigerbrew/issues/105
  fails_with :gcc do
    build 5553
    cause "linking fails with: /usr/bin/ld: can't locate file for: -lssp_nonshared"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]

    args << "-with-ssl=#{Formulary.factory('openssl').opt_prefix}" if build.with? 'brewed-openssl'

    system "./configure", *args
    system "make install"
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
            <string>#{opt_prefix}/bin/tor</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
    </plist>
    EOS
  end
end
