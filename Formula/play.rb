require 'formula'

class Play < Formula
  homepage 'http://www.playframework.org/'
  url 'http://downloads.typesafe.com/play/2.1.0/play-2.1.0.zip'
  sha1 '0708a30906673b5cded859b9d3d772a01855e07a'

  head 'https://github.com/playframework/Play20.git'

  devel do
    url 'http://downloads.typesafe.com/play/2.1.1-RC2/play-2.1.1-RC2.zip'
    sha1 '14d05de4d7d300c349debfbd210dc0578b879f3e'
  end

  def install
    rm Dir['*.bat'] # remove windows' bat files
    libexec.install Dir['*']
    inreplace libexec+"play" do |s|
      s.gsub! "$dir/", "$dir/../libexec/"
      s.gsub! "dir=`dirname $PRG`", "dir=`dirname $0` && dir=$dir/`dirname $PRG`"
    end
    bin.install_symlink libexec+'play'
  end
end
