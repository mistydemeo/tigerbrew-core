class Stunnel < Formula
  homepage "https://www.stunnel.org/"
  url "https://www.stunnel.org/downloads/stunnel-5.10.tar.gz"
  mirror "http://www.usenix.org.uk/mirrors/stunnel/stunnel-5.10.tar.gz"
  sha256 "032bfc1854f8a0b9e452343c36ec6b52c7e0daef0863423c6b13a61a7c92eb23"

  bottle do
    sha1 "b4233f4f1ff1e1cf5d8385b019ef15af3f041c75" => :yosemite
    sha1 "cebb13b5918f30cad4807a42bf192a7f6fff9446" => :mavericks
    sha1 "6fc6de4baf70393eeb3d82f20c07856a54b4aa41" => :mountain_lion
  end

  # Please revision me whenever OpenSSL is updated
  # "Update OpenSSL shared libraries or rebuild stunnel"
  depends_on "openssl"

  def install
    # This causes a bogus .pem to be created in lieu of interactive cert generation.
    stunnel_cnf = Pathname.new("tools/stunnel.cnf")
    stunnel_cnf.unlink
    stunnel_cnf.write <<-EOS.undent
      # OpenSSL configuration file to create a server certificate
      # by Michal Trojnara 1998-2015

      [ req ]
      # the default key length is secure and quite fast - do not change it
      default_bits                    = 2048
      # comment out the next line to protect the private key with a passphrase
      encrypt_key                     = no
      distinguished_name              = req_dn
      x509_extensions                 = cert_type
      prompt                          = no

      [ req_dn ]
      countryName                     = PL
      stateOrProvinceName             = Mazovia Province
      localityName                    = Warsaw
      organizationName                = Stunnel Developers
      organizationalUnitName          = Provisional CA
      0.commonName                    = localhost

      # To create a certificate for more than one name uncomment:
      # 1.commonName                  = DNS alias of your server
      # 2.commonName                  = DNS alias of your server
      # ...
      # See http://home.netscape.com/eng/security/ssl_2.0_certificate.html
      # to see how Netscape understands commonName.

      [ cert_type ]
      nsCertType                      = server
    EOS

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}",
                          "--localstatedir=#{var}",
                          "--mandir=#{man}",
                          "--disable-libwrap",
                          "--disable-systemd",
                          "--with-ssl=#{Formula["openssl"].opt_prefix}"
    system "make", "install", "cert"
  end

  def caveats
    <<-EOS.undent
      A bogus SSL server certificate has been installed to:
        #{etc}/stunnel/stunnel.pem

      This certificate will be used by default unless a config file says otherwise!
      Stunnel will refuse to load the sample configuration file if left unedited.

      In your stunnel configuration, specify a SSL certificate with
      the "cert =" option for each service.
    EOS
  end

  test do
    (testpath/"tstunnel.conf").write <<-EOS.undent
      cert = #{etc}/stunnel/stunnel.pem

      setuid = nobody
      setgid = nobody

      [pop3s]
      accept  = 995
      connect = 110

      [imaps]
      accept  = 993
      connect = 143
    EOS

    assert_match /successful/, pipe_output("#{bin}/stunnel #{testpath}/tstunnel.conf 2>&1")
  end
end
