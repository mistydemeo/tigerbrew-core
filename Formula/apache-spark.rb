require "formula"

class ApacheSpark < Formula
  homepage "https://spark.apache.org/"
  head "https://github.com/apache/spark.git"
  url "https://d3kbcqa49mib13.cloudfront.net/spark-1.3.1-bin-hadoop2.6.tgz"
  version "1.3.1"
  sha1 "86911b6c8964230a93691bd45589f491c10d36c0"

  conflicts_with 'hive', :because => 'both install `beeline` binaries'

  def install
    rm_f Dir["bin/*.cmd"]
    libexec.install Dir["*"]
    bin.write_exec_script Dir["#{libexec}/bin/*"]
  end

  test do
    system "#{bin}/spark-shell <<<'sc.parallelize(1 to 1000).count()'"
  end
end
