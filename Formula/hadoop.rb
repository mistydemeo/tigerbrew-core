require 'formula'

class Hadoop < Formula
  homepage 'http://hadoop.apache.org/common/'
  url 'http://www.apache.org/dyn/closer.cgi?path=hadoop/core/hadoop-1.1.1/hadoop-1.1.1.tar.gz'
  sha1 '3b7f226e437a30bb8eee12093179c81ae94e7896'

  def install
    rm_f Dir["bin/*.bat"]
    libexec.install %w[bin conf lib webapps contrib]
    libexec.install Dir['*.jar']
    bin.write_exec_script Dir["#{libexec}/bin/*"]
    # But don't make rcc visible, it conflicts with Qt
    (bin/'rcc').unlink

    inreplace "#{libexec}/conf/hadoop-env.sh",
      "# export JAVA_HOME=/usr/lib/j2sdk1.5-sun",
      "export JAVA_HOME=\"$(/usr/libexec/java_home)\""
  end

  def caveats; <<-EOS.undent
    In Hadoop's config file:
      #{libexec}/conf/hadoop-env.sh
    $JAVA_HOME has been set to be the output of:
      /usr/libexec/java_home
    EOS
  end
end
