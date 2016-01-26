class Libpng < Formula
  desc "Library for manipulating PNG images"
  homepage "http://www.libpng.org/pub/png/libpng.html"
  url "ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng16/libpng-1.6.19.tar.xz"
  #mirror "https://downloads.sourceforge.net/project/libpng/libpng16/1.6.19/libpng-1.6.19.tar.xz"
  sha256 "311c5657f53516986c67713c946f616483e3cdb52b8b2ee26711be74e8ac35e8"

  bottle do
    cellar :any
    sha256 "d09b58d89e89013b8674e090d57a900d7e554d47c9ce952802116754e505cfc3" => :tiger_altivec
    sha256 "46146f5fdac93a350d98ff17222ecfb38bc2287653dc88ba9e619246f1573f31" => :leopard_g3
    sha256 "c32e4fc4f87fd40d719cefc5734f93a2ccde334a18c33934c2eefbb0ce0f083d" => :leopard_altivec
  end

  keg_only :provided_pre_mountain_lion

  head do
    url "https://github.com/glennrp/libpng.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "test"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <png.h>

      int main()
      {
        png_structp png_ptr;
        png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
        png_destroy_write_struct(&png_ptr, (png_infopp)NULL);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lpng", "-o", "test"
    system "./test"
  end
end
