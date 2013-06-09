require 'formula'

class Groovy < Formula
  homepage 'http://groovy.codehaus.org/'
  url 'http://dist.groovy.codehaus.org/distributions/groovy-binary-2.1.4.zip'
  sha1 '3e1dbf3469c6485448d555f7cba9ab4e7445760b'

  option 'invokedynamic', "Install the InvokeDynamic version of Groovy (only works with Java 1.7+)"

  def install
    # Don't need Windows files.
    rm_f Dir["bin/*.bat"]

    if build.include? 'invokedynamic'
      Dir['indy/*.jar'].each do |src_path|
        dst_file = File.basename(src_path, '-indy.jar') + '.jar'
        dst_path = File.join('lib', dst_file)
        mv src_path, dst_path
      end
    end

    prefix.install_metafiles
    libexec.install %w(bin conf lib embeddable)
    bin.install_symlink Dir["#{libexec}/bin/*"] - Dir["#{libexec}/bin/*.icns"]
  end

  def caveats
    <<-EOS.undent
      You should set the environment variable GROOVY_HOME to
        #{opt_prefix}/libexec
    EOS
  end
end
