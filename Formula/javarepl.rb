require 'formula'

class Javarepl < Formula
  homepage "https://github.com/albertlatacz/java-repl"
  url "http://albertlatacz.published.s3.amazonaws.com/repo/javarepl/javarepl/261/javarepl-261.jar"
  sha1 "a94f9426b806189adcb04ccb365116966b4d75dc"

  def install
    libexec.install "javarepl-#{version}.jar"
    bin.write_jar_script libexec/"javarepl-#{version}.jar", "javarepl"
  end

  test do
    system "echo :quit | javarepl"
  end
end
