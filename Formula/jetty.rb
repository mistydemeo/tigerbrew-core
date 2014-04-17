require 'formula'

class Jetty < Formula
  homepage 'http://www.eclipse.org/jetty/'
  url 'http://eclipse.org/downloads/download.php?file=/jetty/9.1.4.v20140401/dist/jetty-distribution-9.1.4.v20140401.tar.gz&r=1'
  version '9.1.4'
  sha1 'f26ff39fec09892195909c417ffffe9f3c08cc72'

  def install
    libexec.install Dir['*']
    (libexec+'logs').mkpath

    bin.mkpath
    Dir["#{libexec}/bin/*.sh"].each do |f|
      scriptname = File.basename(f, '.sh')
      (bin+scriptname).write <<-EOS.undent
        #!/bin/bash
        JETTY_HOME=#{libexec}
        #{f} $@
      EOS
      chmod 0755, bin+scriptname
    end
  end
end
