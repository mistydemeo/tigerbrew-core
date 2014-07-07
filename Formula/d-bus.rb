require 'formula'

class DBus < Formula
  homepage 'http://www.freedesktop.org/wiki/Software/dbus'
  url "http://dbus.freedesktop.org/releases/dbus/dbus-1.8.4.tar.gz"
  sha1 "316f1196312a88cc858ba810d4e5d16f70ab9d58"

  bottle do
    sha1 "07a7bd9331dcf60f0db9d9efd199c3e3164dbb54" => :mavericks
    sha1 "03e7c08ff3816150aa1db99a594f0c4c21baf223" => :mountain_lion
    sha1 "24385436ff2c32efee5cceab5744273d91c800d0" => :lion
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
    system "make install"

    (prefix+'org.freedesktop.dbus-session.plist').chmod 0644
  end

  def post_install
    # Generate D-Bus's UUID for this machine
    system "#{bin}/dbus-uuidgen", "--ensure=#{var}/lib/dbus/machine-id"
  end

  def caveats; <<-EOS.undent
    If this is your first install, automatically load on login with:
        mkdir -p ~/Library/LaunchAgents
        cp #{prefix}/org.freedesktop.dbus-session.plist ~/Library/LaunchAgents/
        launchctl load -w ~/Library/LaunchAgents/org.freedesktop.dbus-session.plist

    If this is an upgrade and you already have the org.freedesktop.dbus-session.plist loaded:
        launchctl unload -w ~/Library/LaunchAgents/org.freedesktop.dbus-session.plist
        cp #{prefix}/org.freedesktop.dbus-session.plist ~/Library/LaunchAgents/
        launchctl load -w ~/Library/LaunchAgents/org.freedesktop.dbus-session.plist
    EOS
  end
end
