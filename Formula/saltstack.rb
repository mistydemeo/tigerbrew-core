require 'formula'

# We use a custom download strategy to properly configure
# salt's version information when built against HEAD.
# This is populated from git information unfortunately.
class SaltHeadDownloadStrategy < GitDownloadStrategy
  def stage
    @clone.cd {reset}
    safe_system 'git', 'clone', @clone, '.'
  end
end

class Saltstack < Formula
  homepage 'http://www.saltstack.org'
  url 'https://github.com/saltstack/salt/archive/v2014.1.10.tar.gz'
  sha256 '4f4771e654bad8842bf55dba89b6632a4ea216223a5a321342c20e65506198d1'

  bottle do
    sha1 "3ffc76046b54ceadac2224285ee52aa966d987a2" => :mavericks
    sha1 "f150d25e49b6d309c6794c2b78d55209ede96e40" => :mountain_lion
    sha1 "1b4d05f5c21e50f2ecc7df0956287aadde14eae5" => :lion
  end

  head 'https://github.com/saltstack/salt.git', :branch => 'develop',
    :using => SaltHeadDownloadStrategy, :shallow => false

  depends_on :python if MacOS.version <= :snow_leopard
  depends_on 'swig' => :build
  depends_on 'zeromq'
  depends_on 'libyaml'

  resource 'pycrypto' do
    url 'https://pypi.python.org/packages/source/p/pycrypto/pycrypto-2.6.1.tar.gz'
    sha1 'aeda3ed41caf1766409d4efc689b9ca30ad6aeb2'
  end

  resource 'm2crypto' do
    url 'https://pypi.python.org/packages/source/M/M2Crypto/M2Crypto-0.22.3.tar.gz'
    sha1 'c5e39d928aff7a47e6d82624210a7a31b8220a50'
  end

  resource 'pyyaml' do
    url 'https://pypi.python.org/packages/source/P/PyYAML/PyYAML-3.11.tar.gz'
    sha1 '1a2d5df8b31124573efb9598ec6d54767f3c4cd4'
  end

  resource 'markupsafe' do
    url 'https://pypi.python.org/packages/source/M/MarkupSafe/MarkupSafe-0.23.tar.gz'
    sha1 'cd5c22acf6dd69046d6cb6a3920d84ea66bdf62a'
  end

  resource 'jinja2' do
    url 'https://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.7.3.tar.gz'
    sha1 '25ab3881f0c1adfcf79053b58de829c5ae65d3ac'
  end

  resource 'pyzmq' do
    url 'https://pypi.python.org/packages/source/p/pyzmq/pyzmq-14.3.1.tar.gz'
    sha1 'a6cd6b0861fde75bfc85534e446364088ba97243'
  end

  resource 'msgpack-python' do
    url 'https://pypi.python.org/packages/source/m/msgpack-python/msgpack-python-0.4.2.tar.gz'
    sha1 '127ca4c63b182397123d84032ece70d43fa4f869'
  end

  resource 'apache-libcloud' do
    url 'https://pypi.python.org/packages/source/a/apache-libcloud/apache-libcloud-0.15.1.tar.gz'
    sha1 '0631bfa3201a5d4c3fdd3d9c39756051c1c70b0f'
  end

  head do
    resource 'requests' do
      url 'https://pypi.python.org/packages/source/r/requests/requests-2.3.0.tar.gz'
      sha1 'f57bc125d35ec01a81afe89f97dc75913a927e65'
    end
  end

  def install
    ENV["PYTHONPATH"] = lib+"python2.7/site-packages"
    ENV.prepend_create_path 'PYTHONPATH', libexec+'lib/python2.7/site-packages'

    resources.each do |r|
      r.stage { system "python", "setup.py", "install", "--prefix=#{libexec}" }
    end

    system "python", "setup.py", "install", "--prefix=#{prefix}"

    man1.install Dir['doc/man/*.1']
    man7.install Dir['doc/man/*.7']

    bin.env_script_all_files(libexec+'bin', :PYTHONPATH => ENV['PYTHONPATH'])
  end

  test do
    system "#{bin}/salt", "--version"
  end
end
