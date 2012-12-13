require 'formula'

class Openvpn < Formula
  homepage 'http://openvpn.net/'
  url 'http://build.openvpn.net/downloads/releases/openvpn-2.2.2.tar.gz'
  mirror 'http://swupdate.openvpn.org/community/releases/openvpn-2.2.2.tar.gz'
  sha256 '54ca8b260e2ea3b26e84c2282ccb5f8cb149edcfd424b686d5fb22b8dbbeac00'

  devel do
    version '2.3-rc1'

    url 'http://build.openvpn.net/downloads/releases/openvpn-2.3_rc1.tar.gz'
    mirror 'http://swupdate.openvpn.org/community/releases/openvpn-2.3_rc1.tar.gz'
    sha256 '5628423b18a0a05bff2169630e030bc4a440d0e92b820a1b78bc16357d5306e8'
  end

  depends_on 'lzo'

  # This patch fixes compilation on Lion
  # There is a long history of confusion between these two consts:
  # http://www.google.com/search?q=SOL_IP+IPPROTO_IP
  def patches
    DATA unless build.devel?
  end

  def install
    # Build and install binary
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-password-save"
    system "make install"

    # Adjust sample file paths
    if build.devel?
      inreplace ["sample/sample-config-files/openvpn-startup.sh"] do |s|
        s.gsub! "/etc/openvpn", etc+'openvpn'
      end

      # Install sample files
      Dir['sample/sample-*'].each do |d|
        (share + 'doc/openvpn' + d).install Dir[d+'/*']
      end
    else
      inreplace ["sample-config-files/openvpn-startup.sh", "sample-scripts/openvpn.init"] do |s|
        s.gsub! "/etc/openvpn", etc+'openvpn'
        s.gsub! "/var/run/openvpn", var+'run/openvpn'
      end

      # Install sample files
      Dir['sample-*'].each do |d|
        (share + 'doc/openvpn' + d).install Dir[d+'/*']
      end
    end

    # Create etc & var paths
    (etc + 'openvpn').mkpath
    (var + 'run/openvpn').mkpath
  end

  def caveats; <<-EOS.undent
    You may also wish to install tuntap:

      The TunTap project provides kernel extensions for Mac OS X that allow
      creation of virtual network interfaces.

      http://tuntaposx.sourceforge.net/

    Because these are kernel extensions, there is no Homebrew formula for tuntap.

    For OpenVPN to work as a server, you will need to create configuration file
    in #{etc}/openvpn, samples can be found in #{share}/doc/openvpn
    EOS
  end

  plist_options :startup => true

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd";>
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_prefix}/sbin/openvpn</string>
        <string>--config</string>
        <string>#{etc}/openvpn/openvpn.conf</string>
      </array>
      <key>OnDemand</key>
      <false/>
      <key>RunAtLoad</key>
      <true/>
      <key>TimeOut</key>
      <integer>90</integer>
      <key>WatchPaths</key>
      <array>
        <string>#{etc}/openvpn</string>
      </array>
      <key>WorkingDirectory</key>
      <string>#{etc}/openvpn</string>
    </dict>
    </plist>
    EOS
  end
end

__END__
diff --git a/socket.c b/socket.c
index 4720398..faa1782 100644
--- a/socket.c
+++ b/socket.c
@@ -35,6 +35,10 @@

 #include "memdbg.h"

+#ifndef SOL_IP
+#define SOL_IP IPPROTO_IP
+#endif
+
 const int proto_overhead[] = { /* indexed by PROTO_x */
   IPv4_UDP_HEADER_SIZE,
   IPv4_TCP_HEADER_SIZE,
