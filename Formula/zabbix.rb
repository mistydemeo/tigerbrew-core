require 'formula'

class Zabbix < Formula
  homepage 'http://www.zabbix.com/'
  url 'http://downloads.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/2.0.7/zabbix-2.0.7.tar.gz'
  sha1 'd7b6e97af514afd131d38dd692b75644080a4aaa'

  option 'with-mysql', 'Use Zabbix Server with MySQL library instead PostgreSQL.'
  option 'agent-only', 'Install only the Zabbix Agent without Server and Proxy.'

  unless build.include? 'agent-only'
    depends_on :mysql => :optional
    depends_on :postgresql unless build.with? 'mysql'
    depends_on 'fping'
    depends_on 'libssh2'
  end

  def brewed_or_shipped(db_config)
    brewed_db_config = "#{HOMEBREW_PREFIX}/bin/#{db_config}"
    (File.exists?(brewed_db_config) && brewed_db_config) || which(db_config)
  end

  def install
    args = %W{
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-agent
    }

    unless build.include? 'agent-only'
      args += %W{
        --enable-server
        --enable-proxy
        --enable-ipv6
        --with-net-snmp
        --with-libcurl
        --with-ssh2
      }
      if build.with? 'mysql'
        args << "--with-mysql=#{brewed_or_shipped('mysql_config')}"
      else
        args << "--with-postgresql=#{brewed_or_shipped('pg_config')}"
      end
    end

    system "./configure", *args
    system "make install"

    unless build.include? 'agent-only'
      db = build.with?('mysql') ? 'mysql' : 'postgresql'
      (share/'zabbix').install 'frontends/php', "database/#{db}"
    end
  end

  def test
    system "#{sbin}/zabbix_agentd", "--print"
  end
end
