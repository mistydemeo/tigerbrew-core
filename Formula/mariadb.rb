require 'formula'

class Mariadb < Formula
  homepage 'http://mariadb.org/'
  url 'http://ftp.osuosl.org/pub/mariadb/mariadb-5.5.34/kvm-tarbake-jaunty-x86/mariadb-5.5.34.tar.gz'
  sha1 '8a7d8f6094faa35cc22bc084a0e0d8037fd4ba03'

  devel do
    url 'http://ftp.osuosl.org/pub/mariadb/mariadb-10.0.7/kvm-tarbake-jaunty-x86/mariadb-10.0.7.tar.gz'
    sha1 '14d830cf322175a3fc772e3b265faca1246a7b07'
  end

  depends_on 'cmake' => :build
  # otherwise linking fails with multiple definitions of symbol
  depends_on :ld64
  depends_on 'pidof' unless MacOS.version >= :mountain_lion

  option :universal
  option 'with-tests', 'Keep test when installing'
  option 'with-bench', 'Keep benchmark app when installing'
  option 'with-embedded', 'Build the embedded server'
  option 'with-libedit', 'Compile with editline wrapper instead of readline'
  option 'with-archive-storage-engine', 'Compile with the ARCHIVE storage engine enabled'
  option 'with-blackhole-storage-engine', 'Compile with the BLACKHOLE storage engine enabled'
  option 'enable-local-infile', 'Build with local infile loading support'

  conflicts_with 'mysql', 'mysql-cluster', 'percona-server',
    :because => "mariadb, mysql, and percona install the same binaries."
  conflicts_with 'mysql-connector-c',
    :because => 'both install MySQL client libraries'

  env :std if build.universal?

  def patches
    if build.devel?
      [
        # Prevent name collision leading to compilation failure. See:
        # issue #24489, upstream: https://mariadb.atlassian.net/browse/MDEV-5314
        'https://gist.github.com/makigumo/8199195/raw/ab0bc78fd0e839aafcf072505f017feba2b6f6fa/mariadb-10.0.7.mac.patch',
      ]
    end
  end

  def install
    # Don't hard-code the libtool path. See:
    # https://github.com/Homebrew/homebrew/issues/20185
    inreplace "cmake/libutils.cmake",
      "COMMAND /usr/bin/libtool -static -o ${TARGET_LOCATION}",
      "COMMAND libtool -static -o ${TARGET_LOCATION}"

    # Build without compiler or CPU specific optimization flags to facilitate
    # compilation of gems and other software that queries `mysql-config`.
    ENV.minimal_optimization

    # -DINSTALL_* are relative to prefix
    args = %W[
      .
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_FIND_FRAMEWORK=LAST
      -DCMAKE_VERBOSE_MAKEFILE=ON
      -DMYSQL_DATADIR=#{var}/mysql
      -DINSTALL_INCLUDEDIR=include/mysql
      -DINSTALL_MANDIR=share/man
      -DINSTALL_DOCDIR=share/doc/#{name}
      -DINSTALL_INFODIR=share/info
      -DINSTALL_MYSQLSHAREDIR=share/mysql
      -DWITH_SSL=yes
      -DDEFAULT_CHARSET=utf8
      -DDEFAULT_COLLATION=utf8_general_ci
      -DINSTALL_SYSCONFDIR=#{etc}
      -DCOMPILATION_COMMENT=Homebrew
    ]

    args << "-DWITH_UNIT_TESTS=OFF" unless build.with? 'tests'

    # oqgraph requires boost, but fails to compile against boost 1.54
    # Upstream bug: https://mariadb.atlassian.net/browse/MDEV-4795
    args << "-DWITHOUT_OQGRAPH_STORAGE_ENGINE=1"

    # Build the embedded server
    args << "-DWITH_EMBEDDED_SERVER=ON" if build.with? 'embedded'

    # Compile with readline unless libedit is explicitly chosen
    args << "-DWITH_READLINE=yes" unless build.with? 'libedit'

    # Compile with ARCHIVE engine enabled if chosen
    args << "-DWITH_ARCHIVE_STORAGE_ENGINE=1" if build.with? 'archive-storage-engine'

    # Compile with BLACKHOLE engine enabled if chosen
    args << "-DWITH_BLACKHOLE_STORAGE_ENGINE=1" if build.with? 'blackhole-storage-engine'

    # Make universal for binding to universal applications
    args << "-DCMAKE_OSX_ARCHITECTURES='#{Hardware::CPU.universal_archs.as_cmake_arch_flags}'" if build.universal?

    # Build with local infile loading support
    args << "-DENABLED_LOCAL_INFILE=1" if build.include? 'enable-local-infile'

    system "cmake", *args
    system "make"
    system "make install"

    # Fix my.cnf to point to #{etc} instead of /etc
    (etc+'my.cnf.d').mkpath
    inreplace "#{etc}/my.cnf" do |s|
      s.gsub!("!includedir /etc/my.cnf.d", "!includedir #{etc}/my.cnf.d")
    end

    unless build.include? 'client-only'
      # Don't create databases inside of the prefix!
      # See: https://github.com/Homebrew/homebrew/issues/4975
      rm_rf prefix+'data'

      (prefix+'mysql-test').rmtree unless build.with? 'tests' # save 121MB!
      (prefix+'sql-bench').rmtree unless build.with? 'bench'

      # Link the setup script into bin
      ln_s prefix+'scripts/mysql_install_db', bin+'mysql_install_db'

      # Fix up the control script and link into bin
      inreplace "#{prefix}/support-files/mysql.server" do |s|
        s.gsub!(/^(PATH=".*)(")/, "\\1:#{HOMEBREW_PREFIX}/bin\\2")
        # pidof can be replaced with pgrep from proctools on Mountain Lion
        s.gsub!(/pidof/, 'pgrep') if MacOS.version >= :mountain_lion
      end

      ln_s "#{prefix}/support-files/mysql.server", bin
    end

    # Make sure the var/mysql directory exists
    (var+"mysql").mkpath
  end

  def post_install
    unless File.exist? "#{var}/mysql/mysql/user.frm"
      ENV['TMPDIR'] = nil
      system "#{bin}/mysql_install_db", '--verbose', "--user=#{ENV['USER']}",
        "--basedir=#{prefix}", "--datadir=#{var}/mysql", "--tmpdir=/tmp"
    end
  end

  def caveats; <<-EOS.undent
    A "/etc/my.cnf" from another install may interfere with a Homebrew-built
    server starting up correctly.

    To connect:
        mysql -uroot
    EOS
  end

  plist_options :manual => "mysql.server start"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_prefix}/bin/mysqld_safe</string>
        <string>--bind-address=127.0.0.1</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{var}</string>
    </dict>
    </plist>
    EOS
  end
end
