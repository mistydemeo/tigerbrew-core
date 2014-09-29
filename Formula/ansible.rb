require 'formula'

class Ansible < Formula
  homepage 'http://www.ansible.com/home'
  url 'http://releases.ansible.com/ansible/ansible-1.7.1.tar.gz'
  sha1 '4f4be4d45f28f52e4ab0c063efb66c7b9f482a51'

  head 'https://github.com/ansible/ansible.git', :branch => 'devel'

  bottle do
    revision 2
    sha1 "d24b092def576f66ef87ad4ac08e82379f857569" => :mavericks
    sha1 "91272b6bcdd4ccae55ebe1bb0dc318f7adcc5bb5" => :mountain_lion
    sha1 "1a27c03864b32c8696e9fd203bc1fc5fe8cecdbf" => :lion
  end

  depends_on :python if MacOS.version <= :snow_leopard
  depends_on 'libyaml'

  option 'with-accelerate', "Enable accelerated mode"

  resource 'pycrypto' do
    url 'https://pypi.python.org/packages/source/p/pycrypto/pycrypto-2.6.tar.gz'
    sha1 'c17e41a80b3fbf2ee4e8f2d8bb9e28c5d08bbb84'
  end

  resource 'boto' do
    url 'https://pypi.python.org/packages/source/b/boto/boto-2.32.1.tar.gz'
    sha1 '4fdecde66245b7fc0295e22d2c2d3c9b08c2b1fa'
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

  resource 'python-keyczar' do
    url 'https://pypi.python.org/packages/source/p/python-keyczar/python-keyczar-0.71b.tar.gz'
    sha1 '20c7c5d54c0ce79262092b4cc691aa309fb277fa'
  end

  def install
    ENV["PYTHONPATH"] = lib+"python2.7/site-packages"
    ENV.prepend_create_path 'PYTHONPATH', libexec+'lib/python2.7/site-packages'
    # HEAD additionally requires this to be present in PYTHONPATH, or else
    # ansible's own setup.py will fail.
    ENV.prepend_create_path 'PYTHONPATH', prefix+'lib/python2.7/site-packages'
    install_args = [ "setup.py", "install", "--prefix=#{libexec}" ]

    res = %w[pycrypto boto pyyaml paramiko markupsafe jinja2]
    res << "python-keyczar" if build.with? "accelerate"
    res.each do |r|
      resource(r).stage { system "python", *install_args }
    end

    inreplace 'lib/ansible/constants.py' do |s|
      s.gsub! '/usr/share/ansible', share+'ansible'
      s.gsub! '/etc/ansible', etc+'ansible'
    end

    system "python", "setup.py", "install", "--prefix=#{prefix}"

    # These are now rolled into 1.6 and cause linking conflicts
    rm Dir["#{bin}/easy_install*"]
    rm "#{lib}/python2.7/site-packages/site.py"
    rm Dir["#{lib}/python2.7/site-packages/*.pth"]

    man1.install Dir['docs/man/man1/*.1']

    bin.env_script_all_files(libexec+'bin', :PYTHONPATH => ENV['PYTHONPATH'])
  end

  test do
    system "#{bin}/ansible", "--version"
  end
end
