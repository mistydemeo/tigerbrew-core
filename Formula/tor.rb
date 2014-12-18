require "formula"

class Tor < Formula
  homepage "https://www.torproject.org/"
  url "https://dist.torproject.org/tor-0.2.5.10.tar.gz"
  sha256 "b3dd02a5dcd2ffe14d9a37956f92779d4427edf7905c0bba9b1e3901b9c5a83b"

  bottle do
    sha1 "0bf6ef6985285bac9e67fbc78cef7ebb78844de2" => :yosemite
    sha1 "6f4d92e5a77e1d3f3da94f1b45e4817c8ccecdf9" => :mavericks
    sha1 "bae5ecb83486c16256d9d56b284bbf341c8d5a42" => :mountain_lion
  end

  devel do
    url "https://dist.torproject.org/tor-0.2.6.1-alpha.tar.gz"
    version "0.2.6.1-a1"
    sha256 "83154b8e5514978722add6c888d050420342405d4567e5945e89ae40b78b8761"
  end

  depends_on "libevent"
  depends_on "openssl"
  depends_on "libnatpmp" => :optional
  depends_on "miniupnpc" => :optional

  # See https://github.com/mistydemeo/tigerbrew/issues/105
  fails_with :gcc do
    build 5553
    cause "linking fails with: /usr/bin/ld: can't locate file for: -lssp_nonshared"
  end

  def install
    args = ["--disable-dependency-tracking",
            "--prefix=#{prefix}",
            "--sysconfdir=#{etc}",
            "--with-openssl-dir=#{Formula["openssl"].opt_prefix}"]

    args << "--with-libnatpmp-dir=#{Formula["libnatpmp"].opt_prefix}" if build.with? "libnatpmp"
    args << "--with-libminiupnpc-dir=#{Formula["miniupnpc"].opt_prefix}" if build.with? "miniupnpc"

    system "./configure", *args
    system "make", "install"
  end

  test do
    system bin/"tor", "--version"
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/tor</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
    </plist>
    EOS
  end
end
