require 'formula'

class Git < Formula
  homepage 'http://git-scm.com'
  url 'https://git-core.googlecode.com/files/git-1.8.5.5.tar.gz'
  sha1 '7bb4ea883b1f8f6f7f927035f85e8e27b57e0194'
  head 'https://github.com/git/git.git'

  bottle do
    sha1 "582a276b608de17888da01922648522bf7a9c11a" => :mavericks
    sha1 "f308b293aa5664b65c57c3b206b892537397d3b9" => :mountain_lion
    sha1 "fa5f896b766bb103804800abde58e25579cf58a7" => :lion
  end

  option 'with-blk-sha1', 'Compile with the block-optimized SHA1 implementation'
  option 'without-completions', 'Disable bash/zsh completions from "contrib" directory'
  option 'with-brewed-openssl', "Build with Homebrew OpenSSL instead of the system version" if MacOS.version > :leopard
  option 'with-brewed-curl', "Use Homebrew's version of cURL library" if MacOS.version > :snow_leopard
  option 'with-persistent-https', 'Build git-remote-persistent-https from "contrib" directory'

  if MacOS.version == :tiger
    # system tar has odd permissions errors
    depends_on 'gnu-tar' => :build
    # Tiger's ld produces bad install-names for a keg-only curl
    depends_on 'ld64' => :build
    depends_on 'cctools' => :build
  end

  if MacOS.version < :snow_leopard
    depends_on 'curl'
  else
    depends_on 'curl' if build.with? 'brewed-curl'
  end
  depends_on :expat
  depends_on 'pcre' => :optional
  depends_on 'gettext' => :optional
  depends_on 'openssl' if MacOS.version < :leopard || build.with?('brewed-openssl')
  depends_on 'go' => :build if build.with? 'persistent-https'

  resource 'man' do
    url 'http://git-core.googlecode.com/files/git-manpages-1.8.5.5.tar.gz'
    sha1 'a4a2aef1440d4751f37c65359da57c9bd51a7beb'
  end

  resource 'html' do
    url 'http://git-core.googlecode.com/files/git-htmldocs-1.8.5.5.tar.gz'
    sha1 '39dd7979c8757d2dc4bc3aaa82741ba93557d566'
  end

  def patches
    p = []
    # ld64 understands -rpath but rejects it on Tiger
    p << 'https://trac.macports.org/export/106975/trunk/dports/devel/git-core/files/patch-Makefile.diff' if MacOS.version < :leopard

    if MacOS.version >= :mavericks and not build.head?
      # Allow using PERLLIB_EXTRA to find Subversion Perl bindings location
      # in the CLT/Xcode. Should be included in Git 1.8.6.
      # https://git.kernel.org/cgit/git/git.git/commit/?h=next&id=07981d
      # https://git.kernel.org/cgit/git/git.git/commit/?h=next&id=0386dd
      p << 'https://git.kernel.org/cgit/git/git.git/patch/?id=07981d'
      p << 'https://git.kernel.org/cgit/git/git.git/patch/?id=0386dd'
    end

    p
  end

  def install
    # git's index-pack will segfault unless compiled without optimization
    ENV.no_optimization if MacOS.version == :tiger

    if MacOS.version == :tiger
      tar = Formula.factory('gnu-tar')
      tab = Tab.for_keg tar.installed_prefix
      tar_name = tab.used_options.include?('--default-names') ? tar.bin/'tar' : tar.bin/'gtar'
      inreplace 'Makefile' do |s|
        s.change_make_var! 'TAR', tar_name.to_s
      end
    end

    # If these things are installed, tell Git build system to not use them
    ENV['NO_FINK'] = '1'
    ENV['NO_DARWIN_PORTS'] = '1'
    ENV['V'] = '1' # build verbosely
    ENV['NO_R_TO_GCC_LINKER'] = '1' # pass arguments to LD correctly
    ENV['PYTHON_PATH'] = which 'python'
    ENV['PERL_PATH'] = which 'perl'
    ENV['CURLDIR'] = Formula.factory('curl').opt_prefix if MacOS.version < :snow_leopard
    ENV['NO_APPLE_COMMON_CRYPTO'] = '1' if MacOS.version < :leopard

    if MacOS.version >= :mavericks and MacOS.dev_tools_prefix
      ENV['PERLLIB_EXTRA'] = "#{MacOS.dev_tools_prefix}/Library/Perl/5.16/darwin-thread-multi-2level"
    end

    unless quiet_system ENV['PERL_PATH'], '-e', 'use ExtUtils::MakeMaker'
      ENV['NO_PERL_MAKEMAKER'] = '1'
    end

    ENV['BLK_SHA1'] = '1' if build.with? 'blk-sha1'

    if build.with? 'pcre'
      ENV['USE_LIBPCRE'] = '1'
      ENV['LIBPCREDIR'] = Formula.factory('pcre').opt_prefix
    end

    ENV['LD'] = Formula.factory('ld64').opt_prefix/'bin/ld'
    ENV['NO_GETTEXT'] = '1' unless build.with? 'gettext'

    system "make", "prefix=#{prefix}",
                   "sysconfdir=#{etc}",
                   "CC=#{ENV.cc}",
                   "CFLAGS=#{ENV.cflags}",
                   "LDFLAGS=#{ENV.ldflags}",
                   "install"

    bin.install Dir["contrib/remote-helpers/git-remote-{hg,bzr}"]

    # Install the OS X keychain credential helper
    cd 'contrib/credential/osxkeychain' do
      system "make", "CC=#{ENV.cc}",
                     "CFLAGS=#{ENV.cflags}",
                     "LDFLAGS=#{ENV.ldflags}"
      bin.install 'git-credential-osxkeychain'
      system "make", "clean"
    end

    # Install git-subtree
    cd 'contrib/subtree' do
      system "make", "CC=#{ENV.cc}",
                     "CFLAGS=#{ENV.cflags}",
                     "LDFLAGS=#{ENV.ldflags}"
      bin.install 'git-subtree'
    end

    if build.with? 'persistent-https'
      cd 'contrib/persistent-https' do
        system "make"
        bin.install 'git-remote-persistent-http',
                    'git-remote-persistent-https',
                    'git-remote-persistent-https--proxy'
      end
    end

    unless build.without? 'completions'
      # install the completion script first because it is inside 'contrib'
      bash_completion.install 'contrib/completion/git-completion.bash'
      bash_completion.install 'contrib/completion/git-prompt.sh'

      zsh_completion.install 'contrib/completion/git-completion.zsh' => '_git'
      cp "#{bash_completion}/git-completion.bash", zsh_completion
    end

    (share+'git-core').install 'contrib'

    # We could build the manpages ourselves, but the build process depends
    # on many other packages, and is somewhat crazy, this way is easier.
    man.install resource('man')
    (share+'doc/git-doc').install resource('html')

    # Make html docs world-readable; check if this is still needed at 1.8.6
    chmod 0644, Dir["#{share}/doc/git-doc/**/*.{html,txt}"]
  end

  def caveats; <<-EOS.undent
    The OS X keychain credential helper has been installed to:
      #{HOMEBREW_PREFIX}/bin/git-credential-osxkeychain

    The 'contrib' directory has been installed to:
      #{HOMEBREW_PREFIX}/share/git-core/contrib
    EOS
  end

  test do
    HOMEBREW_REPOSITORY.cd do
      assert_equal 'bin/brew', `#{bin}/git ls-files -- bin`.strip
    end
  end
end
