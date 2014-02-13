require 'formula'

class Ansible < Formula
  homepage 'http://www.ansibleworks.com/'
  url 'https://github.com/ansible/ansible/archive/v1.4.5.tar.gz'
  sha1 '09f451e6634c6e7bb5705d26b9daab6efc0407c1'

  head 'https://github.com/ansible/ansible.git', :branch => 'devel'

  depends_on :python
  depends_on 'libyaml'

  option 'with-accelerate', "Enable accelerated mode"

  resource 'pycrypto' do
    url 'https://pypi.python.org/packages/source/p/pycrypto/pycrypto-2.6.tar.gz'
    sha1 'c17e41a80b3fbf2ee4e8f2d8bb9e28c5d08bbb84'
  end

  resource 'pyyaml' do
    url 'https://pypi.python.org/packages/source/P/PyYAML/PyYAML-3.10.tar.gz'
    sha1 '476dcfbcc6f4ebf3c06186229e8e2bd7d7b20e73'
  end

  resource 'paramiko' do
    url 'https://pypi.python.org/packages/source/p/paramiko/paramiko-1.11.0.tar.gz'
    sha1 'fd925569b9f0b1bd32ce6575235d152616e64e46'
  end

  resource 'markupsafe' do
    url 'https://pypi.python.org/packages/source/M/MarkupSafe/MarkupSafe-0.18.tar.gz'
    sha1 '9fe11891773f922a8b92e83c8f48edeb2f68631e'
  end

  resource 'jinja2' do
    url 'https://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.7.1.tar.gz'
    sha1 'a9b24d887f2be772921b3ee30a0b9d435cffadda'
  end

  if build.with? 'accelerate'
    resource 'python-keyczar' do
      url 'https://pypi.python.org/packages/source/p/python-keyczar/python-keyczar-0.71b.tar.gz'
      sha1 '20c7c5d54c0ce79262092b4cc691aa309fb277fa'
    end
  end

  def install
    ENV.prepend_create_path 'PYTHONPATH', libexec+'lib/python2.7/site-packages'
    install_args = [ "setup.py", "install", "--prefix=#{libexec}" ]

    resource('pycrypto').stage { system "python", *install_args }
    resource('pyyaml').stage { system "python", *install_args }
    resource('paramiko').stage { system "python", *install_args }
    resource('markupsafe').stage { system "python", *install_args }
    resource('jinja2').stage { system "python", *install_args }
    if build.with? 'accelerate'
      resource('python-keyczar').stage { system "python", *install_args }
    end

    inreplace 'lib/ansible/constants.py' do |s|
      s.gsub! '/usr/share/ansible', share+'ansible'
      s.gsub! '/etc/ansible', etc+'ansible'
    end

    system "python", "setup.py", "install", "--prefix=#{prefix}"

    man1.install Dir['docs/man/man1/*.1']

    bin.env_script_all_files(libexec+'bin', :PYTHONPATH => ENV['PYTHONPATH'])
  end

  test do
    system "#{bin}/ansible", "--version"
  end
end
