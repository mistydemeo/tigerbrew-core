require 'formula'

class Strongswan < Formula
  homepage 'http://www.strongswan.org'
  url 'http://download.strongswan.org/strongswan-5.1.2.tar.bz2'
  sha1 '414569a95faeddacd99d23562be6f5a57b63f700'

  bottle do
    sha1 "2ab86079317c1639a765917d20fb6fa1666f1e2f" => :mavericks
    sha1 "13d46f9a95708fead99868b7c4cb4379011710ba" => :mountain_lion
    sha1 "c3cff0ddf082c012a6f77cfde3742a8eaf4994ac" => :lion
  end

  option 'with-curl', 'Build with libcurl based fetcher'
  option 'with-suite-b', 'Build with Suite B support (does not use the IPsec implementation provided by the kernel)'

  depends_on 'openssl' if build.with? "suite-b" or MacOS.version <= :leopard
  depends_on 'curl' => :optional

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sbindir=#{bin}
      --sysconfdir=#{etc}
      --disable-defaults
      --enable-charon
      --enable-cmd
      --enable-constraints
      --enable-eap-identity
      --enable-eap-md5
      --enable-eap-gtc
      --enable-eap-mschapv2
      --enable-ikev1
      --enable-ikev2
      --enable-kernel-pfroute
      --enable-nonce
      --enable-openssl
      --enable-osx-attr
      --enable-pem
      --enable-pgp
      --enable-pkcs1
      --enable-pkcs8
      --enable-pubkey
      --enable-revocation
      --enable-socket-default
      --enable-sshkey
      --enable-stroke
      --enable-tools
      --enable-updown
      --enable-unity
      --enable-xauth-generic
    ]
    args << "--enable-curl" if build.with? 'curl'
    args << "--enable-kernel-pfkey" if build.without? 'suite-b'
    args << "--enable-kernel-libipsec" if build.with? 'suite-b'

    system "./configure", *args
    system "make", "install"
  end

  def caveats
    msg = <<-EOS.undent
      strongSwan's configuration files are placed in:
        #{etc}

      You will have to run both 'ipsec' and 'charon-cmd' with 'sudo'.
    EOS
    if build.with? 'suite-b'
      msg += <<-EOS.undent

        If you previously ran strongSwan without Suite B support it might be
        required to execute 'sudo sysctl -w net.inet.ipsec.esp_port=0' in order
        to receive packets.
      EOS
    end
    return msg
  end
end
