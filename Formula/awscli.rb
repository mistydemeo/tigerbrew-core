require "formula"

class Awscli < Formula
  homepage "https://aws.amazon.com/cli/"
  url "https://pypi.python.org/packages/source/a/awscli/awscli-1.4.3.tar.gz"
  sha1 "59d5cb117ba1c6071ce4badc61ba48d41263f182"

  bottle do
    cellar :any
    sha1 "ef4b22b8f9393a3f24d3c6e1ec8794af65abcc59" => :mavericks
    sha1 "b5f2317057750fdb098b1e5f2edd72e210818d19" => :mountain_lion
    sha1 "70dfcb884bfa1436b3ebd8d610d2128666426dba" => :lion
  end

  head do
    url "https://github.com/aws/aws-cli.git", :branch => :develop

    resource "botocore" do
      url "https://github.com/boto/botocore.git", :branch => :develop
    end

    resource "bcdoc" do
      url "https://github.com/boto/bcdoc.git", :branch => :develop
    end

    resource "jmespath" do
      url "https://github.com/boto/jmespath.git", :branch => :develop
    end
  end

  depends_on :python if MacOS.version <= :snow_leopard

  resource "botocore" do
    url "https://pypi.python.org/packages/source/b/botocore/botocore-0.63.0.tar.gz"
    sha1 "41ea1bf85acdd95d7af6f1b705cbe5cf2b4aea02"
  end

  resource "bcdoc" do
    url "https://pypi.python.org/packages/source/b/bcdoc/bcdoc-0.12.2.tar.gz"
    sha1 "31b2a714c2803658d9d028c8edf4623fd0daaf18"
  end

  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.8.0.tar.gz"
    sha1 "aa3b0659cbc85c6c7a91efc51f2d1007040070cd"
  end

  resource "colorama" do
    url "https://pypi.python.org/packages/source/c/colorama/colorama-0.2.5.tar.gz"
    sha1 "87507210c5a7d400b27d23e8dd42734198663d66"
  end

  resource "docutils" do
    url "https://pypi.python.org/packages/source/d/docutils/docutils-0.12.tar.gz"
    sha1 "002450621b33c5690060345b0aac25bc2426d675"
  end

  resource "rsa" do
    url "https://bitbucket.org/sybren/python-rsa/get/version-3.1.2.tar.gz"
    sha1 "6a7515221e50ee87cfb54cb36e96f2a39df9badd"
  end

  def install
    ENV["PYTHONPATH"] = lib+"python2.7/site-packages"
    ENV.prepend_create_path "PYTHONPATH", libexec+"lib/python2.7/site-packages"

    resources.each do |r|
      r.stage { system "python", "setup.py", "install", "--prefix=#{libexec}" }
    end

    system "python", "setup.py", "install", "--prefix=#{prefix}",
      "--single-version-externally-managed", "--record=installed.txt"

    # Install zsh completion
    zsh_completion.install "bin/aws_zsh_completer.sh" => "_aws"

    # Install the examples
    (share+"awscli").install "awscli/examples"

    bin.env_script_all_files(libexec+"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  def caveats; <<-EOS.undent
    The "examples" directory has been installed to:
      #{HOMEBREW_PREFIX}/share/awscli/examples

    Add the following to ~/.bashrc to enable bash completion:
      complete -C aws_completer aws

    Add the following to ~/.zshrc to enable zsh completion:
      source #{HOMEBREW_PREFIX}/share/zsh/site-functions/_aws

    Before using awscli, you need to tell it about your AWS credentials.
    The easiest way to do this is to run:
      aws configure

    More information:
      http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html
    EOS
  end

  test do
    system "#{bin}/aws", "--version"
  end
end
