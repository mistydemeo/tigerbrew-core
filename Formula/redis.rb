require 'formula'

class Redis < Formula
  homepage 'http://redis.io/'
  url 'http://download.redis.io/releases/redis-2.8.5.tar.gz'
  sha1 'f0eb48609ff66ead3c7f06bbe8a8dd1aa7341b73'

  bottle do
    sha1 "3670032929123972994cdc29374628311e5fb874" => :mavericks
    sha1 "9240b55f06576409d8f9e9f6f4d00d67a6861da0" => :mountain_lion
    sha1 "1ee0860611776df9e9d361df6a2d1ba6d5111cbb" => :lion
  end

  head 'https://github.com/antirez/redis.git', :branch => 'unstable'

  fails_with :llvm do
    build 2334
    cause 'Fails with "reference out of range from _linenoise"'
  end

  def install
    # Architecture isn't detected correctly on 32bit Snow Leopard without help
    ENV["OBJARCH"] = "-arch #{MacOS.preferred_arch}"

    # Head and stable have different code layouts
    src = (buildpath/'src/Makefile').exist? ? buildpath/'src' : buildpath
    system "make", "-C", src, "CC=#{ENV.cc}"

    %w[benchmark cli server check-dump check-aof sentinel].each { |p| bin.install src/"redis-#{p}" }
    %w[run db/redis log].each { |p| (var+p).mkpath }

    # Fix up default conf file to match our paths
    inreplace "redis.conf" do |s|
      s.gsub! "/var/run/redis.pid", "#{var}/run/redis.pid"
      s.gsub! "dir ./", "dir #{var}/db/redis/"
      s.gsub! "\# bind 127.0.0.1", "bind 127.0.0.1"
    end

    etc.install 'redis.conf'
    etc.install 'sentinel.conf' => 'redis-sentinel.conf'
  end

  plist_options :manual => "redis-server #{HOMEBREW_PREFIX}/etc/redis.conf"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <dict>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_prefix}/bin/redis-server</string>
          <string>#{etc}/redis.conf</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/redis.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/redis.log</string>
      </dict>
    </plist>
    EOS
  end
end
