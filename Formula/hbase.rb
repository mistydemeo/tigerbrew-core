require 'formula'

class Hbase < Formula
  homepage 'http://hbase.apache.org'
  url 'http://www.apache.org/dyn/closer.cgi?path=hbase/hbase-0.98.4/hbase-0.98.4-hadoop2-bin.tar.gz'
  sha1 'b93c8920dcfb8da04a41d1d981a7d046b9c4fb1f'

  depends_on 'hadoop'

  def install
    rm_f Dir["bin/*.cmd", "conf/*.cmd"]
    libexec.install %w[bin conf docs lib hbase-webapps]
    bin.write_exec_script Dir["#{libexec}/bin/*"]

    inreplace "#{libexec}/conf/hbase-env.sh",
      "# export JAVA_HOME=/usr/java/jdk1.6.0/",
      "export JAVA_HOME=\"$(/usr/libexec/java_home)\""
  end

  def caveats; <<-EOS.undent
    Requires Java 1.6.0 or greater.

    You must also edit the configs in:
      #{libexec}/conf
    to reflect your environment.

    For more details:
      http://wiki.apache.org/hadoop/Hbase
    EOS
  end
end
