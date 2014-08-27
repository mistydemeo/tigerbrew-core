require "formula"

class Mongodb < Formula
  homepage "http://www.mongodb.org/"
  url "http://downloads.mongodb.org/src/mongodb-src-r2.6.4.tar.gz"
  sha1 "16dda6d8b1156194fc09b5ad72e58612d06abada"
  revision 1

  bottle do
    sha1 "59059165afd50c14b0d6b9b6929532bf7310c899" => :mavericks
    sha1 "03b866db1d6c3e1dd575648c63078a652cca53a4" => :mountain_lion
    sha1 "eb9bcb5dbd44c2ea4266e25c23a43482241aef68" => :lion
  end

  devel do
    url "http://downloads.mongodb.org/src/mongodb-src-r2.7.5.tar.gz"
    sha1 "e7e38a6fec1fde1bb8ee50674089c909b428a48c"
  end

  head "https://github.com/mongodb/mongo.git"

  option "with-boost", "Compile using installed boost, not the version shipped with mongodb"
  depends_on "boost" => :optional

  depends_on :macos => :snow_leopard
  depends_on "scons" => :build
  depends_on "openssl" => :optional

  def install
    args = %W[
      --prefix=#{prefix}
      -j#{ENV.make_jobs}
      --cc=#{ENV.cc}
      --cxx=#{ENV.cxx}
      --osx-version-min=#{MacOS.version}
    ]

    # --full installs development headers and client library, not just binaries
    # (only supported pre-2.7)
    args << "--full" if build.stable?
    args << "--use-system-boost" if build.with? "boost"
    args << "--64" if MacOS.prefer_64_bit?

    if build.with? "openssl"
      args << "--ssl" << "--extrapath=#{Formula["openssl"].opt_prefix}"
    end

    scons "install", *args

    (buildpath+"mongod.conf").write mongodb_conf
    etc.install "mongod.conf"

    (var+"mongodb").mkpath
    (var+"log/mongodb").mkpath
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

  plist_options :manual => "mongod --config #{HOMEBREW_PREFIX}/etc/mongod.conf"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/mongod</string>
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

  test do
    system "#{bin}/mongod", "--sysinfo"
  end
end
