require 'formula'

class Zookeeper < Formula
  homepage 'http://zookeeper.apache.org/'
  url 'http://www.apache.org/dyn/closer.cgi?path=zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz'
  sha1 '2a9e53f5990dfe0965834a525fbcad226bf93474'
  revision 1

  bottle do
    sha1 "44d960c61b67308c2e6e510399505582afe2904d" => :mavericks
    sha1 "df1c9ff667738859b1362541bcd14bcdfcf6804c" => :mountain_lion
    sha1 "23cdb5e2a183ef2593b4d7c4e2047fb7a774e031" => :lion
  end

  head do
    url 'http://svn.apache.org/repos/asf/zookeeper/trunk'

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
    depends_on "ant" => :build
    depends_on "cppunit" => :build
  end

  option "perl", "Build Perl bindings"

  depends_on :python => :optional

  def shim_script target
    <<-EOS.undent
      #!/usr/bin/env bash
      . "#{etc}/zookeeper/defaults"
      cd "#{libexec}/bin"
      ./#{target} "$@"
    EOS
  end

  def default_zk_env
    <<-EOS.undent
      export ZOOCFGDIR="#{etc}/zookeeper"
    EOS
  end

  def default_log4j_properties
    <<-EOS.undent
      log4j.rootCategory=WARN, zklog
      log4j.appender.zklog = org.apache.log4j.FileAppender
      log4j.appender.zklog.File = #{var}/log/zookeeper/zookeeper.log
      log4j.appender.zklog.Append = true
      log4j.appender.zklog.layout = org.apache.log4j.PatternLayout
      log4j.appender.zklog.layout.ConversionPattern = %d{yyyy-MM-dd HH:mm:ss} %c{1} [%p] %m%n
    EOS
  end

  def install
    # Don't try to build extensions for PPC
    if Hardware.is_32_bit?
      ENV['ARCHFLAGS'] = "-arch #{Hardware::CPU.arch_32_bit}"
    else
      ENV['ARCHFLAGS'] = Hardware::CPU.universal_archs.as_arch_flags
    end

    if build.head?
      system "ant", "compile_jute"
      system "autoreconf", "-fvi", "src/c"
    end

    cd "src/c" do
      system "./configure", "--disable-dependency-tracking",
                            "--prefix=#{prefix}",
                            "--without-cppunit"
      system "make install"
    end

    cd "src/contrib/zkpython" do
      system "python", "src/python/setup.py", "build"
      system "python", "src/python/setup.py", "install", "--prefix=#{prefix}"
    end if build.with? "python"

    cd "src/contrib/zkperl" do
      system "perl", "Makefile.PL", "PREFIX=#{prefix}",
                                    "--zookeeper-include=#{include}",
                                    "--zookeeper-lib=#{lib}"
      system "make install"
    end if build.include? "perl"

    rm_f Dir["bin/*.cmd"]

    if build.head?
      system "ant"
      libexec.install Dir["bin", "src/contrib", "src/java/lib", "build/*.jar"]
    else
      libexec.install Dir["bin", "contrib", "lib", "*.jar"]
    end

    bin.mkpath
    (etc+'zookeeper').mkpath
    (var+'log/zookeeper').mkpath
    (var+'run/zookeeper/data').mkpath

    Pathname.glob("#{libexec}/bin/*.sh") do |path|
      next if path == libexec+'bin/zkEnv.sh'
      script_name = path.basename
      bin_name    = path.basename '.sh'
      (bin+bin_name).write shim_script(script_name)
    end

    defaults = etc/'zookeeper/defaults'
    defaults.write(default_zk_env) unless defaults.exist?

    log4j_properties = etc/'zookeeper/log4j.properties'
    log4j_properties.write(default_log4j_properties) unless log4j_properties.exist?

    inreplace 'conf/zoo_sample.cfg',
              /^dataDir=.*/, "dataDir=#{var}/run/zookeeper/data"
    cp 'conf/zoo_sample.cfg', 'conf/zoo.cfg'
    (etc/'zookeeper').install ['conf/zoo.cfg', 'conf/zoo_sample.cfg']
  end

  plist_options :manual => "zkServer start"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>EnvironmentVariables</key>
        <dict>
           <key>SERVER_JVMFLAGS</key>
           <string>-Dapple.awt.UIElement=true</string>
        </dict>
        <key>KeepAlive</key>
        <dict>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/zkServer</string>
          <string>start-foreground</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}</string>
      </dict>
    </plist>
    EOS
  end
end
