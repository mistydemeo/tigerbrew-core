require 'formula'

class Fuseki < Formula
  homepage 'http://jena.apache.org/documentation/serving_data/'
  url "http://www.apache.org/dist/jena/binaries/jena-fuseki-1.0.0-distribution.tar.gz"
  version "1.0.0"
  sha1 '94349d9795a20cabb8b4f5887fc1b341b08cc271'

  def install
    # Remove windows files
    rm_f 'fuseki-server.bat'

    # Remove init.d script to avoid confusion
    rm 'fuseki'

    # Write the installation path into the wrapper shell script
    inreplace 'fuseki-server' do |s|
      s.gsub! /export FUSEKI_HOME=.+/,
              %'export FUSEKI_HOME="#{libexec}"'
      s.gsub! /^exec java\s+(.+)/,
              "exec java -Dlog4j.configuration=file:#{etc/'fuseki.log4j.properties'} \\1"
    end

    # Use file logging instead of STDOUT logging
    inreplace 'log4j.properties' do |s|
      s.gsub! /^log4j\.rootLogger=.+/,                  '### \0'
      s.gsub! /^log4j\.appender\.stdlog.+/,             '### \0'
      s.gsub! /^## (log4j\.rootLogger=.+)/,             '\1'
      s.gsub! /^## (log4j\.appender\.FusekiFileLog.+)/, '\1'
      s.gsub! /^log4j.appender.FusekiFileLog.File=.+/,
              "log4j.appender.FusekiFileLog.File=#{(var/'log/fuseki/fuseki.log')}"
    end
    etc.install 'log4j.properties' => 'fuseki.log4j.properties'

    # Install and symlink wrapper binaries into place
    libexec.install 'fuseki-server'
    bins = ['s-delete', 's-get', 's-head', 's-post', 's-put', 's-query', 's-update', 's-update-form']
    chmod 0755, bins
    libexec.install bins
    bin.install_symlink Dir["#{libexec}/*"]
    # Non-symlinked binaries and application files
    libexec.install 'fuseki-server.jar', 'pages'

    etc.install 'config.ttl' => 'fuseki.ttl'

    # Create a location for dataset and log files,
    # in case we're being used in LaunchAgent mode
    (var/'fuseki').mkpath
    (var/'log/fuseki').mkpath

    # Install example configs
    prefix.install 'config-examples.ttl', 'config-inf-tdb.ttl', 'config-tdb-text.ttl', 'config-tdb.ttl'

    # Install example data
    prefix.install 'Data'

    # Install documentation
    prefix.install 'DEPENDENCIES', 'LICENSE', 'NOTICE', 'ReleaseNotes.txt'
  end

  def caveats; <<-EOS.undent
    Quick-start guide:

    * See the Fuseki documentation for instructions on using an in-memory database:
      http://jena.apache.org/documentation/serving_data/#fuseki-server-starting-with-an-empty-dataset

    * Running from the LaunchAgent is different the standard configuration and
      uses traditional Unix paths: please inspect the settings here first:
      #{etc}/fuseki.ttl

      NOTE: Currently the logging configuration file will be overwritten
            if you re-install or upgrade Fuseki. This file is located here:
            #{etc}/'fuseki.log4j.properties'
    EOS
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
        <false/>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_prefix}/bin/fuseki-server</string>
          <string>--config</string>
          <string>/usr/local/etc/fuseki.ttl</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/fuseki-server", '--version'
  end
end
