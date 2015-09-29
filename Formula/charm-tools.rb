class CharmTools < Formula
  desc "Tools for authoring and maintaining juju charms"
  homepage "https://launchpad.net/charm-tools"
  url "https://launchpad.net/charm-tools/1.7/1.7.0/+download/charm-tools-1.7.0.tar.gz"
  sha256 "6bc12d24460b366e12176538692d5b29c3697f5c8a98b525a05fa5ec7b04e042"

  bottle do
    cellar :any
    sha256 "ce32f7bea01b802b7e3fe7602824803bc9e1e0aa2f7b9b9b97209d9e55069472" => :yosemite
    sha256 "dac2d32c219b2cf83e611626292a229eb5901b218ad39b8704d4d59a2b36f491" => :mavericks
    sha256 "4239d0adc10d00e4d96f74bba4d05221cd828b18fe9dce3498aacbf38c8c6484" => :mountain_lion
  end

  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "libyaml"

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec+"lib/python2.7/site-packages"
    system "python", "setup.py", "install", "--prefix=#{libexec}"

    bin.install Dir[libexec/"bin/*charm*"]
    bin.env_script_all_files(libexec+"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    system "#{bin}/charm", "list"
  end
end
