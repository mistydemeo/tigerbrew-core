class AwsElasticbeanstalk < Formula
  homepage "https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-reference-eb.html"
  url "https://pypi.python.org/packages/source/a/awsebcli/awsebcli-3.4.4.tar.gz"
  sha256 "f503253a6ed3e8ed567092927ca3e3baf41ba95f3ccbbe7ee798777d0592e879"

  bottle do
    cellar :any
    sha256 "d7beceb7056c939810924908e2c61558794d2620942c0b2744537ce62b5b741a" => :yosemite
    sha256 "ce6df0b920142438c31d35f25040ce0134a3c8e48f967ff26d6ba72f115a7217" => :mavericks
    sha256 "a0153c1978d05bdef7c2efe1a62536900867de5dd20ab3c65375c1b79775cabd" => :mountain_lion
  end

  depends_on :python if MacOS.version <= :snow_leopard

  resource "pyyaml" do
    url "https://pypi.python.org/packages/source/P/PyYAML/PyYAML-3.11.tar.gz"
    sha256 "c36c938a872e5ff494938b33b14aaa156cb439ec67548fcab3535bb78b0846e8"
  end

  resource "cement" do
    url "https://pypi.python.org/packages/source/c/cement/cement-2.4.0.tar.gz"
    sha256 "81c46cd056cbc7e48ae2342b3a65afbae4732b09af5d1d3e2e079678d2ccd5bb"
  end

  resource "backports.ssl_match_hostname" do
    url "https://pypi.python.org/packages/source/b/backports.ssl_match_hostname/backports.ssl_match_hostname-3.4.0.2.tar.gz"
    sha256 "07410e7fb09aab7bdaf5e618de66c3dac84e2e3d628352814dc4c37de321d6ae"
  end

  resource "pathspec" do
    url "https://pypi.python.org/packages/source/p/pathspec/pathspec-0.3.3.tar.gz"
    sha256 "38d0613ee2ce75adbbad61a33895c3b88122c768a732fb14800e6f660cc1380b"
  end

  resource "docopt" do
    url "https://pypi.python.org/packages/source/d/docopt/docopt-0.6.2.tar.gz"
    sha256 "49b3a825280bd66b3aa83585ef59c4a8c82f2c8a522dbe754a8bc8d08c85c491"
  end

  resource "requests" do
    url "https://pypi.python.org/packages/source/r/requests/requests-2.6.2.tar.gz"
    sha256 "0577249d4b6c4b11fd97c28037e98664bfaa0559022fee7bcef6b752a106e505"
  end

  resource "texttable" do
    url "https://pypi.python.org/packages/source/t/texttable/texttable-0.8.3.tar.gz"
    sha256 "f333ac915e7c5daddc7d4877b096beafe74ea88b4b746f82a4b110f84e348701"
  end

  resource "websocket-client" do
    url "https://pypi.python.org/packages/source/w/websocket-client/websocket_client-0.30.0.tar.gz"
    sha256 "fab17bc3eb450a28c6edb7a23442a01353712f29240ea76cc9409571e58ed3e5"
  end

  resource "docker-py" do
    url "https://pypi.python.org/packages/source/d/docker-py/docker-py-1.1.0.tar.gz"
    sha256 "6a07eb56b234719e89d3038c24f9c870b6f1ee0b58080120e865e2752673cd94"
  end

  resource "dockerpty" do
    url "https://pypi.python.org/packages/source/d/dockerpty/dockerpty-0.3.3.tar.gz"
    sha256 "5b9bd23e4a5f0ad28ea702adeebc1bb8b153c4a19526f230792b0af57f7eb3be"
  end

  resource "python-dateutil" do
    url "https://pypi.python.org/packages/source/p/python-dateutil/python-dateutil-2.4.2.tar.gz"
    sha256 "3e95445c1db500a344079a47b171c45ef18f57d188dffdb0e4165c71bea8eb3d"
  end

  resource "jmespath" do
    url "https://pypi.python.org/packages/source/j/jmespath/jmespath-0.7.1.tar.gz"
    sha256 "cd5a12ee3dfa470283a020a35e69e83b0700d44fe413014fd35ad5584c5f5fd1"
  end

  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.9.0.tar.gz"
    sha256 "e24052411fc4fbd1f672635537c3fc2330d9481b18c0317695b46259512c91d5"
  end

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec+"lib/python2.7/site-packages"

    resources.each do |r|
      r.stage { system "python", *Language::Python.setup_install_args(libexec) }
    end

    system "python", *Language::Python.setup_install_args(libexec)

    bash_completion.install libexec/"bin/eb_completion.bash"
    bin.install Dir[libexec/"bin/{eb,jp}"]
    bin.env_script_all_files(libexec+"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    system "#{bin}/eb", "--version"
  end
end
