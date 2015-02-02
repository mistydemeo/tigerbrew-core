require 'formula'

class Predictionio < Formula
  homepage 'http://prediction.io/'
  url 'http://download.prediction.io/PredictionIO-0.8.5.tar.gz'
  sha1 '1cc68733d2f8dbad1ae01e960f74085db24c7e74'

  depends_on 'elasticsearch'
  depends_on 'hadoop'
  depends_on 'hbase'
  depends_on 'apache-spark'
  depends_on :java => "1.7"

  def install
    rm_f Dir["bin/*.bat"]

    libexec.install Dir['*']
    bin.write_exec_script libexec/"bin/pio"

    inreplace libexec/"conf/pio-env.sh" do |s|
       s.gsub! /#\s*ES_CONF_DIR=.+$/, "ES_CONF_DIR=#{Formula['elasticsearch'].opt_prefix}/config"
       s.gsub! /SPARK_HOME=.+$/, "SPARK_HOME=#{Formula['apache-spark'].opt_prefix}"
    end
  end

end
