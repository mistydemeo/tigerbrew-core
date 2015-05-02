class Pcre < Formula
  homepage "http://www.pcre.org/"
  url "https://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.37.tar.bz2"
  mirror "https://downloads.sourceforge.net/project/pcre/pcre/8.37/pcre-8.37.tar.bz2"
  sha256 "51679ea8006ce31379fb0860e46dd86665d864b5020fc9cd19e71260eef4789d"

  bottle do
    cellar :any
    sha256 "83191880a6cc02a258928bf69f6bc0545b019f90ecccc5b2d08787180504327c" => :yosemite
    sha256 "88485e49b169f4123f29c086e8e59d835a16b1e7d39c4ecaca01412b88d16281" => :mavericks
    sha256 "78ecdc1a81fe8da426fd5fe0d9d04fb03bb92bd3763d876fcb3d48d45b76876f" => :mountain_lion
  end

  option :universal

  # See https://github.com/mistydemeo/tigerbrew/issues/93
  fails_with :gcc do
    build 5553
    cause "One test failure on G4"
  end

  fails_with :llvm do
    build 2326
    cause "Bus error in ld on SL 10.6.4"
  end

  def install
    ENV.universal_binary if build.universal?

    args = [ "--disable-dependency-tracking",
              "--prefix=#{prefix}",
              "--enable-utf8",
              "--enable-pcre8",
              "--enable-pcre16",
              "--enable-pcre32",
              "--enable-unicode-properties",
              "--enable-pcregrep-libz",
              "--enable-pcregrep-libbz2" ]

    # JIT fails tests very badly on PPC right now
    args << "--enable-jit" unless Hardware::CPU.type == :ppc

    system "./configure", *args
    system "make"
    ENV.deparallelize
    system "make", "test"
    system "make", "install"
  end

  test do
    system "#{bin}/pcregrep", "regular expression", "#{prefix}/README"
  end
end
