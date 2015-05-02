class Atk < Formula
  homepage "https://library.gnome.org/devel/atk/"
  url "https://download.gnome.org/sources/atk/2.16/atk-2.16.0.tar.xz"
  sha256 "095f986060a6a0b22eb15eef84ae9f14a1cf8082488faa6886d94c37438ae562"

  bottle do
    sha256 "128b040fbcf11591d3fef7bff779b958fb1fd4ce49715a14427fd5f8aba81010" => :yosemite
    sha256 "50a58e13caac37709dd4cb9d7414393ded99aa17ca8037316d0dd0cb9018286d" => :mavericks
    sha256 "7a7f9f7a5532e454434eeb4d33abd52cf7a568c259b407b61af1705233f0ea6c" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "gobject-introspection"

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-introspection=yes"
    system "make"
    system "make", "install"
  end
  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <atk/atk.h>

      int main(int argc, char *argv[]) {
        const gchar *version = atk_get_version();
        return 0;
      }
    EOS
    system ENV.cc, "-I#{HOMEBREW_PREFIX}/include/atk-1.0", "-I#{HOMEBREW_PREFIX}/include/glib-2.0", "-I#{HOMEBREW_PREFIX}/lib/glib-2.0/include", "-I#{HOMEBREW_PREFIX}/opt/gettext/include", "test.c", "-L#{HOMEBREW_PREFIX}/lib", "-L#{HOMEBREW_PREFIX}/lib", "-L#{HOMEBREW_PREFIX}/opt/gettext/lib", "-latk-1.0", "-lgobject-2.0", "-lglib-2.0", "-lintl", "-o", "test"
    system "./test"
  end
end
