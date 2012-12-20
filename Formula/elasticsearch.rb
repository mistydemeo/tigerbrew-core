require 'formula'

class Elasticsearch < Formula
  homepage 'http://www.elasticsearch.org'
  url 'http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.20.1.tar.gz'
  sha1 'd1c468a589060dd43532c1afabec9eee10095429'

  def cluster_name
    "elasticsearch_#{ENV['USER']}"
  end

  def install
    # Remove Windows files
    rm_f Dir["bin/*.bat"]
    # Move JARs from lib to libexec according to homebrew conventions
    libexec.install Dir['lib/*.jar']
    (libexec+'sigar').install Dir['lib/sigar/*.jar']

    # Install everything directly into folder
    prefix.install Dir['*']

    # Set up ElasticSearch for local development:
    inreplace "#{prefix}/config/elasticsearch.yml" do |s|

      # 1. Give the cluster a unique name
      s.gsub! /#\s*cluster\.name\: elasticsearch/, "cluster.name: #{cluster_name}"

      # 2. Configure paths
      s.gsub! /#\s*path\.data\: [^\n]+/, "path.data: #{var}/elasticsearch/"
      s.gsub! /#\s*path\.logs\: [^\n]+/, "path.logs: #{var}/log/elasticsearch/"

      # 3. Bind to loopback IP for laptops roaming different networks
      s.gsub! /#\s*network\.host\: [^\n]+/, "network.host: 127.0.0.1"
    end

    inreplace "#{bin}/elasticsearch.in.sh" do |s|
      # Replace CLASSPATH paths to use libexec instead of lib
      s.gsub! /ES_HOME\/lib\//, "ES_HOME/libexec/"
    end

    inreplace "#{bin}/elasticsearch" do |s|
      # Set ES_HOME to prefix value
      s.gsub! /^ES_HOME=.*$/, "ES_HOME=#{prefix}"
    end

    inreplace "#{bin}/plugin" do |s|
      # Set ES_HOME to prefix value
      s.gsub! /^ES_HOME=.*$/, "ES_HOME=#{prefix}"
      # Replace CLASSPATH paths to use libexec instead of lib
      s.gsub! /-cp \".*\"/, '-cp "$ES_HOME/libexec/*"'
    end

    # Persist plugins on upgrade
    plugins = "#{HOMEBREW_PREFIX}/var/lib/elasticsearch/plugins"
    mkdir_p plugins
    ln_sf plugins, "#{prefix}/plugins"
  end

  def caveats; <<-EOS.undent
    If upgrading from 0.18 ElasticSearch requires flushing before shutting
    down the cluster with no indexing operations happening after flush:
        curl host:9200/_flush

    See the 'elasticsearch.yml' file for configuration options.

    You'll find the ElasticSearch log here:
        open #{var}/log/elasticsearch/#{cluster_name}.log

    The folder with cluster data is here:
        open #{var}/elasticsearch/#{cluster_name}/

    You should see ElasticSearch running:
        open http://localhost:9200/
    EOS
  end

  plist_options :manual => "elasticsearch -f -D es.config=#{HOMEBREW_PREFIX}/opt/elasticsearch/config/elasticsearch.yml"

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
            <string>#{HOMEBREW_PREFIX}/bin/elasticsearch</string>
            <string>-f</string>
            <string>-D es.config=#{prefix}/config/elasticsearch.yml</string>
          </array>
          <key>EnvironmentVariables</key>
          <dict>
            <key>ES_JAVA_OPTS</key>
            <string>-Xss200000</string>
          </dict>
          <key>RunAtLoad</key>
          <true/>
          <key>UserName</key>
          <string>#{ENV['USER']}</string>
          <key>WorkingDirectory</key>
          <string>#{var}</string>
          <key>StandardErrorPath</key>
          <string>/dev/null</string>
          <key>StandardOutPath</key>
          <string>/dev/null</string>
        </dict>
      </plist>
    EOS
  end
end
