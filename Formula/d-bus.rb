class DBus < Formula
  # releases: even (1.8.x) = stable, odd (1.9.x) = development
  desc "Message bus system, providing inter-application communication"
  homepage "https://wiki.freedesktop.org/www/Software/dbus"
  url "http://dbus.freedesktop.org/releases/dbus/dbus-1.8.14.tar.gz"
  sha256 "83425250a6a4c93b9ab4a349771a7700e8ddff2d73a5a088222ca47ae9ce1f1a"

  bottle do
    sha1 "22806b6107833bea3b69099848c6f12add3625cc" => :yosemite
    sha1 "d9271e1f6906883e42c9782b4ce43ce288ad8f8e" => :mavericks
    sha1 "4162df1d33f03d55472155728bd2911653702798" => :mountain_lion
  end

  # Upstream fix for O_CLOEXEC portability
  # http://cgit.freedesktop.org/dbus/dbus/commit/?id=5d91f615d18629eaac074fbde2ee7e17b82e5472
  # This is fixed in 1.9.x but won't be fixed upstream for 1.8.x
  patch do
    url "http://cgit.freedesktop.org/dbus/dbus/patch/?id=5d91f615d18629eaac074fbde2ee7e17b82e5472"
    sha256 "35a021c54da36b22d720acc23f5f133a609cb268e7cb16e36a772552e9cf3e69"
  end

  def install
    # Fix the TMPDIR to one D-Bus doesn't reject due to odd symbols
    ENV["TMPDIR"] = "/tmp"

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--localstatedir=#{var}",
                          "--sysconfdir=#{etc}",
                          "--disable-xml-docs",
                          "--disable-doxygen-docs",
                          "--enable-launchd",
                          "--with-launchd-agent-dir=#{prefix}",
                          "--without-x",
                          "--disable-tests"
    system "make"
    ENV.deparallelize
    system "make", "install"

    (prefix+"org.freedesktop.dbus-session.plist").chmod 0644
  end

  def post_install
    # Generate D-Bus's UUID for this machine
    system "#{bin}/dbus-uuidgen", "--ensure=#{var}/lib/dbus/machine-id"
  end

  test do
    system "#{bin}/dbus-daemon", "--version"
  end
end
