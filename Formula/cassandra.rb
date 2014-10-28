require 'formula'

class Cassandra < Formula
  homepage 'http://cassandra.apache.org'
  url 'http://www.apache.org/dyn/closer.cgi?path=/cassandra/2.1.1/apache-cassandra-2.1.1-bin.tar.gz'
  sha1 'ba1ce9e7f141e0217cb97238f69157b20cc84e01'

  def install
    (var+"lib/cassandra").mkpath
    (var+"log/cassandra").mkpath
    (etc+"cassandra").mkpath

    inreplace "conf/cassandra.yaml", "/var/lib/cassandra", "#{var}/lib/cassandra"
    inreplace "conf/cassandra-env.sh", "/lib/", "/"

    inreplace "bin/cassandra", "-Dcassandra.logdir\=$CASSANDRA_HOME/logs", "-Dcassandra.logdir\=#{var}/log/cassandra"
    inreplace "bin/cassandra.in.sh" do |s|
      s.gsub! "CASSANDRA_HOME=\"`dirname \"$0\"`/..\"", "CASSANDRA_HOME=\"#{prefix}\""
      # Store configs in etc, outside of keg
      s.gsub! "CASSANDRA_CONF=\"$CASSANDRA_HOME/conf\"", "CASSANDRA_CONF=\"#{etc}/cassandra\""
      # Jars installed to prefix, no longer in a lib folder
      s.gsub! "\"$CASSANDRA_HOME\"/lib/*.jar", "\"$CASSANDRA_HOME\"/*.jar"
      # The jammm Java agent is not in a lib/ subdir either:
      s.gsub! "JAVA_AGENT=\"$JAVA_AGENT -javaagent:$CASSANDRA_HOME/lib/jamm-", "JAVA_AGENT=\"$JAVA_AGENT -javaagent:$CASSANDRA_HOME/jamm-"
      # Storage path
      s.gsub! "cassandra_storagedir\=\"$CASSANDRA_HOME/data\"", "cassandra_storagedir\=\"#{var}/lib/cassandra\""
    end

    rm Dir["bin/*.bat", "bin/*.ps1"]

    (etc+"cassandra").install Dir["conf/*"]
    prefix.install Dir["*.txt", "{bin,interface,javadoc,pylib,lib/licenses}"]
    prefix.install Dir["lib/*.jar"]

    share.install [bin+'cassandra.in.sh', bin+'stop-server']
    inreplace Dir["#{bin}/cassandra*", "#{bin}/debug-cql", "#{bin}/nodetool", "#{bin}/sstable*"],
              /`dirname "?\$0"?`\/cassandra.in.sh/,
              "#{share}/cassandra.in.sh"
  end

  def caveats; <<-EOS.undent
    If you plan to use the CQL shell (cqlsh), you will need the Python CQL library
    installed. Since Homebrew prefers using pip for Python packages, you can
    install that using:

      pip install cql
    EOS
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>

        <key>Label</key>
        <string>#{plist_name}</string>

        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/cassandra</string>
            <string>-f</string>
        </array>

        <key>RunAtLoad</key>
        <true/>

        <key>WorkingDirectory</key>
        <string>#{var}/lib/cassandra</string>
      </dict>
    </plist>
    EOS
  end
end
