class Suricata < Formula
  homepage "http://suricata-ids.org"
  url "https://www.openinfosecfoundation.org/download/suricata-2.0.8.tar.gz"
  sha256 "7af6394cb81e464f5c1ac88a1444030e30940caab6e53688a6d9eb652226d1be"

  bottle do
    sha256 "269066b7601a3cd2c47d7e0e3c789ff2c334d1eff7dfa47221b1fb66233a7014" => :yosemite
    sha256 "08ea538e48680b7712324dc8fe19a682aa0d485193823408f251f0441f62ec59" => :mavericks
    sha256 "692c6babe72dd65363c607c846c2f9a5a01580451fd6ed97c0d1eadb4bbe736a" => :mountain_lion
  end

  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "pkg-config" => :build
  depends_on "libmagic"
  depends_on "libnet"
  depends_on "libyaml"
  depends_on "pcre"
  depends_on "geoip" => :optional
  depends_on "lua" => :optional
  depends_on "luajit" => :optional

  resource "argparse" do
    url "https://pypi.python.org/packages/source/a/argparse/argparse-1.3.0.tar.gz"
    sha256 "b3a79a23d37b5a02faa550b92cbbbebeb4aa1d77e649c3eb39c19abf5262da04"
  end

  resource "simplejson" do
    url "https://pypi.python.org/packages/source/s/simplejson/simplejson-3.6.5.tar.gz"
    sha256 "2a3189f79d1c7b8a2149a0e783c0b4217fad9b30a6e7d60450f2553dc2c0e57e"
  end

  def install
    # bug raised https://redmine.openinfosecfoundation.org/issues/1470
    ENV.deparallelize

    libnet = Formula["libnet"]
    libmagic = Formula["libmagic"]

    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
    resources.each do |r|
      r.stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --localstatedir=#{var}
      --with-libnet-includes=#{libnet.opt_include}
      --with-libnet-libs=#{libnet.opt_lib}
      --with-libmagic-includes=#{libmagic.opt_include}
      --with-libmagic-libraries=#{libmagic.opt_lib}
    ]

    args << "--enable-lua" if build.with? "lua"
    args << "--enable-luajit" if build.with? "luajit"

    if build.with? "geoip"
      geoip = Formula["geoip"]
      args << "--enable-geoip"
      args << "--with-libgeoip-includes=#{geoip.opt_include}"
      args << "--with-libgeoip-libs=#{geoip.opt_lib}"
    end

    system "./configure", *args
    system "make", "install-full"

    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])

    # Leave the magic-file: prefix in otherwise it overrides a commented out line rather than intended line.
    inreplace etc/"suricata/suricata.yaml", %r{magic-file: /.+/magic}, "magic-file: #{libmagic.opt_share}/misc/magic"
  end

  test do
    assert_match /#{version}/, shell_output("#{bin}/suricata --build-info")
  end
end
