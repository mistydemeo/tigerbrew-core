require 'formula'

class Rethinkdb < Formula
  homepage 'http://www.rethinkdb.com/'
  url 'http://download.rethinkdb.com/dist/rethinkdb-1.7.3.tgz'
  sha1 '81bfcb7fc88ef61d83f84bab5c25d1a92d8687c5'

  depends_on :macos => :lion
  depends_on 'boost' => :build

  fails_with :gcc do
    build 5666 # GCC 4.2.1
    cause 'RethinkDB uses C++0x'
  end

  def install
    system "./configure", "--prefix=#{prefix}", "--fetch", "protobuf", "--fetch", "v8"
    system "make"
    system "make install-osx"
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
          <string>#{opt_prefix}/bin/rethinkdb</string>
          <string>-d</string>
          <string>#{var}/rethinkdb</string>
      </array>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/rethinkdb/rethinkdb.log</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/rethinkdb/rethinkdb.log</string>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <true/>
    </dict>
    </plist>
    EOS
  end
end
