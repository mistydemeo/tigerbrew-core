require 'formula'

class Mongodb < Formula
  homepage 'http://www.mongodb.org/'
  url 'http://downloads.mongodb.org/src/mongodb-src-r2.4.7.tar.gz'
  sha1 'abef63992fe12e4e68a7d9de01d8d8eaa8705c9a'

  devel do
    url 'http://downloads.mongodb.org/src/mongodb-src-r2.5.3.tar.gz'
    sha1 '8fbd7f6f2a55092ae0e461ee0f5a4a7f738d40c9'
  end

  head 'https://github.com/mongodb/mongo.git'

  def patches
    # Fix osx_min_verson issues with clang
    # This ensures libstdc++ is picked, since mongodb is not yet compatible
    p = []
    p << 'https://github.com/mongodb/mongo/commit/978af9.patch' if build.devel?
    # Fix Clang v8 build failure from build warnings and -Werror
    p << 'https://github.com/mongodb/mongo/commit/be4bc7.patch' if build.stable?
  end

  depends_on 'scons' => :build
  depends_on 'openssl' => :optional

  def install
    # mongodb currently can't build with libc++; this should be fixed in
    # 2.6, but can't be backported to the current stable release.
    ENV.cxx += ' -stdlib=libstdc++' if ENV.compiler == :clang && MacOS.version >= :mavericks

    args = ["--prefix=#{prefix}", "-j#{ENV.make_jobs}"]
    args << '--64' if MacOS.prefer_64_bit?
    args << "--cc=#{ENV.cc}"
    args << "--cxx=#{ENV.cxx}"

    if build.with? 'openssl'
      args << '--ssl'
      args << "--extrapathdyn=#{Formula.factory('openssl').opt_prefix}"
    end

    system 'scons', 'install', *args

    (prefix+'mongod.conf').write mongodb_conf

    mv bin/'mongod', prefix
    (bin/'mongod').write <<-EOS.undent
      #!/usr/bin/env ruby
      ARGV << '--config' << '#{etc}/mongod.conf' unless ARGV.find { |arg|
        arg =~ /^\s*\-\-config$/ or arg =~ /^\s*\-f$/
      }
      exec "#{prefix}/mongod", *ARGV
    EOS

    etc.install prefix+'mongod.conf'

    (var+'mongodb').mkpath
    (var+'log/mongodb').mkpath
  end

  def mongodb_conf; <<-EOS.undent
    # Store data in #{var}/mongodb instead of the default /data/db
    dbpath = #{var}/mongodb

    # Append logs to #{var}/log/mongodb/mongo.log
    logpath = #{var}/log/mongodb/mongo.log
    logappend = true

    # Only accept local connections
    bind_ip = 127.0.0.1
    EOS
  end

  plist_options :manual => "mongod"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_prefix}/mongod</string>
        <string>run</string>
        <string>--config</string>
        <string>#{etc}/mongod.conf</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <false/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/mongodb/output.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/mongodb/output.log</string>
      <key>HardResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>1024</integer>
      </dict>
      <key>SoftResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>1024</integer>
      </dict>
    </dict>
    </plist>
    EOS
  end
end
