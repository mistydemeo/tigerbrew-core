class Qemu < Formula
  homepage "http://wiki.qemu.org"
  url "http://wiki.qemu-project.org/download/qemu-2.3.0.tar.bz2"
  sha256 "b6bab7f763d5be73e7cb5ee7d4c8365b7a8df2972c52fa5ded18893bd8281588"
  head "git://git.qemu-project.org/qemu.git"

  bottle do
    sha256 "a8fdc51e7f656136fd8dc926ebefd648a0e1b1bee0a695d4d08e07b4075b19ef" => :yosemite
    sha256 "db9a906a1d92a209369271ed9d1d041a18e5dd97abbd08f4a79d8c0044f36b30" => :mavericks
    sha256 "7243043a8a71dbc0a2ca5d80efd8eb646806d8cd8cf1772186efb69fed71cb0d" => :mountain_lion
  end

  patch do
    # Fix for VENOM <http://venom.fail>
    # Patch from QEMU Git
    url "http://git.qemu.org/?p=qemu.git;a=commitdiff_plain;h=e907746266721f305d67bc0718795fedee2e824c"
    sha256 "a182ee0e5d6aa040dea51796a410827e8c0b3b928c864846c6e5a1754dde9c88"
  end

  depends_on "pkg-config" => :build
  depends_on "libtool" => :build
  depends_on "jpeg"
  depends_on "gnutls"
  depends_on "glib"
  depends_on "pixman"
  depends_on "vde" => :optional
  depends_on "sdl" => :optional
  depends_on "gtk+" => :optional
  depends_on "libssh2" => :optional

  # 3.2MB working disc-image file hosted on upstream's servers for people to use to test qemu functionality.
  resource "armtest" do
    url "http://wiki.qemu.org/download/arm-test-0.2.tar.gz"
    sha256 "4b4c2dce4c055f0a2adb93d571987a3d40c96c6cbfd9244d19b9708ce5aea454"
  end

  def install
    ENV["LIBTOOL"] = "glibtool"

    args = %W[
      --prefix=#{prefix}
      --cc=#{ENV.cc}
      --host-cc=#{ENV.cc}
      --enable-cocoa
      --disable-bsd-user
      --disable-guest-agent
    ]

    args << (build.with?("sdl") ? "--enable-sdl" : "--disable-sdl")
    args << (build.with?("vde") ? "--enable-vde" : "--disable-vde")
    args << (build.with?("gtk+") ? "--enable-gtk" : "--disable-gtk")
    args << (build.with?("libssh2") ? "--enable-libssh2" : "--disable-libssh2")

    system "./configure", *args
    system "make", "V=1", "install"
  end

  test do
    resource("armtest").stage testpath
    assert_match /file format: raw/, shell_output("#{bin}/qemu-img info arm_root.img")
  end
end
