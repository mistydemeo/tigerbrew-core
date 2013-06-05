require 'formula'

class SeleniumServerStandalone < Formula
  homepage 'http://seleniumhq.org/'
  url 'http://selenium.googlecode.com/files/selenium-server-standalone-2.33.0.jar'
  sha1 '1eeb43187fb8550a91cf4a270ca9ac8553156bcf'

  def install
    prefix.install "selenium-server-standalone-#{version}.jar"
  end

  plist_options :manual => "java -jar #{HOMEBREW_PREFIX}/opt/selenium-server-standalone/selenium-server-standalone-#{version}.jar -p 4444"

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
            <false/>
            <key>ProgramArguments</key>
            <array>
                    <string>/usr/bin/java</string>
                    <string>-jar</string>
                    <string>#{prefix}/selenium-server-standalone-#{version}.jar</string>
                    <string>-port</string>
                    <string>4444</string>
            </array>
            <key>ServiceDescription</key>
            <string>Selenium Server</string>
            <key>StandardErrorPath</key>
            <string>/var/log/selenium/selenium-error.log</string>
            <key>StandardOutPath</key>
            <string>/var/log/selenium/selenium-output.log</string>
    </dict>
    </plist>
    EOS
  end
end
