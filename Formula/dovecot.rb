require 'formula'

class Dovecot < Formula
  homepage 'http://dovecot.org/'
  url 'http://dovecot.org/releases/2.2/dovecot-2.2.4.tar.gz'
  sha256 '018ffa5eb3a77772cb7ae932a67449536d92a3fa9781202481a4203c003dbdc4'

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--libexecdir=#{libexec}",
                          "--sysconfdir=#{etc}",
                          "--localstatedir=#{var}",
                          "--with-ssl=openssl"
    system "make install"
  end

  def caveats; <<-EOS
For Dovecot to work, you will need to do the following:

1) Create configuration in #{etc}

2) If required by the configuration above, create a dovecot user and group

3) possibly create a launchd item in /Library/LaunchDaemons/#{plist_path.basename}, like so:
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>OnDemand</key>
        <false/>
        <key>ProgramArguments</key>
        <array>
                <string>#{HOMEBREW_PREFIX}/sbin/dovecot</string>
                <string>-F</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>ServiceDescription</key>
        <string>Dovecot mail server</string>
</dict>
</plist>

Source: http://wiki.dovecot.org/LaunchdInstall
4) start the server using: sudo launchctl load /Library/LaunchDaemons/#{plist_path.basename}
    EOS
  end
end

