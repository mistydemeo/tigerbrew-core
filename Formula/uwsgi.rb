require "formula"

class Uwsgi < Formula
  homepage "https://uwsgi-docs.readthedocs.org/en/latest/"
  url "http://projects.unbit.it/downloads/uwsgi-2.0.8.tar.gz"
  sha1 "f017faf259f409907dc8c37541370d3e803fba32"
  head "https://github.com/unbit/uwsgi.git"

  bottle do
    sha1 "111f178b0f86c2f3e35d791c00c78ce858633e12" => :yosemite
    sha1 "607debd03c31e9d3ac74ef3a7a72c06d14c868de" => :mavericks
    sha1 "d83b6ea522d5c9980778218db3545512b4ab09b8" => :mountain_lion
  end

  # See https://github.com/unbit/uwsgi/issues/334
  depends_on :ld64
  depends_on "pkg-config" => :build
  depends_on "openssl"
  depends_on :python if MacOS.version <= :snow_leopard

  depends_on "pcre"
  depends_on "yajl" if build.without? "jansson"

  depends_on "geoip" => :optional
  depends_on "gloox" => :optional
  depends_on "go" => [:build, :optional]
  depends_on "jansson" => :optional
  depends_on "libffi" => :optional
  depends_on "libxslt" => :optional
  depends_on "libyaml" => :optional
  depends_on "lua51" => :optional
  depends_on "mongodb" => :optional
  depends_on "mongrel2" => :optional
  depends_on "nagios" => :optional
  depends_on "postgresql" => :optional
  depends_on "pypy" => :optional
  depends_on "python" => :optional
  depends_on "python3" => :optional
  depends_on "rrdtool" => :optional
  depends_on "rsyslog" => :optional
  depends_on "tcc" => :optional
  depends_on "v8" => :optional
  depends_on "zeromq" => :optional

  option "with-java", "Compile with Java support"
  option "with-php", "Compile with PHP support (PHP must be built for embedding)"
  option "with-ruby", "Compile with Ruby support"

  # This is a hacky patch, but it works. Replace once upstream have a better fix.
  # https://github.com/Homebrew/homebrew/issues/33488
  # https://github.com/unbit/uwsgi/issues/760
  if MacOS.version == :yosemite
    patch :DATA
  end

  def install
    ENV.append %w{CFLAGS LDFLAGS}, "-arch #{MacOS.preferred_arch}"
    ENV.append_to_cflags "-DHAVE_HTONLL" if MacOS.version == :yosemite

    json = build.with?("jansson") ? "jansson" : "yajl"
    yaml = build.with?("libyaml") ? "libyaml" : "embedded"

    (buildpath/"buildconf/brew.ini").write <<-EOS.undent
      [uwsgi]
      json = #{json}
      yaml = #{yaml}
      inherit = base
      plugin_dir = #{libexec}/uwsgi
      embedded_plugins = null
    EOS

    system "python", "uwsgiconfig.py", "--build", "brew"

    plugins = ["airbrake", "alarm_curl", "alarm_speech", "asyncio", "cache",
               "carbon", "cgi", "cheaper_backlog2", "cheaper_busyness",
               "corerouter", "curl_cron", "cplusplus", "dumbloop", "dummy",
               "echo", "emperor_amqp", "fastrouter", "forkptyrouter", "gevent",
               "http", "logcrypto", "logfile", "ldap", "logpipe", "logsocket",
               "msgpack", "notfound", "pam", "ping", "psgi", "pty", "rawrouter",
               "router_basicauth", "router_cache", "router_expires",
               "router_hash", "router_http", "router_memcached",
               "router_metrics", "router_radius", "router_redirect",
               "router_redis", "router_rewrite", "router_static",
               "router_uwsgi", "router_xmldir", "rpc", "signal", "spooler",
               "sqlite3", "sslrouter", "stats_pusher_file",
               "stats_pusher_socket", "symcall", "syslog",
               "transformation_chunked", "transformation_gzip",
               "transformation_offload", "transformation_tofile",
               "transformation_toupper","ugreen", "webdav", "zergpool"]

    plugins << "alarm_xmpp" if build.with? "gloox"
    plugins << "emperor_mongodb" if build.with? "mongodb"
    plugins << "emperor_pg" if build.with? "postgresql"
    plugins << "ffi" if build.with? "libffi"
    plugins << "fiber" if build.with? "ruby"
    plugins << "gccgo" if build.with? "go"
    plugins << "geoip" if build.with? "geoip"
    plugins << "jvm" if build.with? "java"
    plugins << "jwsgi" if build.with? "java"
    plugins << "libtcc" if build.with? "tcc"
    plugins << "lua" if build.with? "lua"
    plugins << "mongodb" if build.with? "mongodb"
    plugins << "mongodblog" if build.with? "mongodb"
    plugins << "mongrel2" if build.with? "mongrel2"
    plugins << "nagios" if build.with? "nagios"
    plugins << "pypy" if build.with? "pypy"
    plugins << "php" if build.with? "php"
    plugins << "rack" if build.with? "ruby"
    plugins << "rbthreads" if build.with? "ruby"
    plugins << "ring" if build.with? "java"
    plugins << "rrdtool" if build.with? "rrdtool"
    plugins << "rsyslog" if build.with? "rsyslog"
    plugins << "servlet" if build.with? "java"
    plugins << "stats_pusher_mongodb" if build.with? "mongodb"
    plugins << "v8" if build.with? "v8"
    plugins << "xslt" if build.with? "libxslt"

    (libexec/"uwsgi").mkpath
    plugins.each do |plugin|
      system "python", "uwsgiconfig.py", "--plugin", "plugins/#{plugin}", "brew"
    end

    python_versions = ["python", "python2"]
    python_versions << "python3" if build.with? "python3"
    python_versions.each do |v|
      system "python", "uwsgiconfig.py", "--plugin", "plugins/python", "brew", v
    end

    bin.install "uwsgi"
  end

  plist_options :manual => "uwsgi"

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
            <string>#{bin}/uwsgi</string>
            <string>--uid</string>
            <string>_www</string>
            <string>--gid</string>
            <string>_www</string>
            <string>--master</string>
            <string>--die-on-term</string>
            <string>--autoload</string>
            <string>--logto</string>
            <string>#{HOMEBREW_PREFIX}/var/log/uwsgi.log</string>
            <string>--emperor</string>
            <string>#{HOMEBREW_PREFIX}/etc/uwsgi/apps-enabled</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
    </plist>
    EOS
  end
end

__END__
diff --git a/plugins/emperor_amqp/amqp.c b/plugins/emperor_amqp/amqp.c
index 7b34c66..a6f8a2f 100644
--- a/plugins/emperor_amqp/amqp.c
+++ b/plugins/emperor_amqp/amqp.c
@@ -2,6 +2,8 @@
 
 #define AMQP_CONNECTION_HEADER "AMQP\0\0\x09\x01"
 
+#ifndef HAVE_HTONLL
+
 #ifdef __BIG_ENDIAN__
 #define ntohll(x) x
 #else
@@ -9,6 +11,8 @@
 #endif
 #define htonll(x) ntohll(x)
 
+#endif
+
 #define amqp_send(a, b, c) if (send(a, b, c, 0) < 0) { uwsgi_error("send()"); return -1; }
 
 struct amqp_frame_header {
