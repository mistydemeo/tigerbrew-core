require 'formula'

class Glib < Formula
  homepage 'http://developer.gnome.org/glib/'
  url 'http://ftp.gnome.org/pub/gnome/sources/glib/2.38/glib-2.38.2.tar.xz'
  sha256 '056a9854c0966a0945e16146b3345b7a82562a5ba4d5516fd10398732aea5734'

  bottle do
    sha1 "4859364747094843599c19a42d7d150f91629f6c" => :mavericks
    sha1 "bd656d91c1641f0f12a0c509c60a7cb7b10416de" => :mountain_lion
    sha1 "2530552dce455e85f109ebeb090843cd9d7c4630" => :lion
  end

  option :universal
  option 'test', 'Build a debug build and run tests. NOTE: Not all tests succeed yet'
  option 'with-static', 'Build glib with a static archive.'

  depends_on 'pkg-config' => :build
  depends_on 'gettext'
  depends_on 'libffi'
  # the version of zlib which comes with Tiger does not
  # export some symbols glib expects
  depends_on 'homebrew/dupes/zlib' if MacOS.version == :tiger

  fails_with :llvm do
    build 2334
    cause "Undefined symbol errors while linking"
  end

  resource 'config.h.ed' do
    url 'https://trac.macports.org/export/111532/trunk/dports/devel/glib2/files/config.h.ed'
    version '111532'
    sha1 '0926f19d62769dfd3ff91a80ade5eff2c668ec54'
  end if build.universal?

  # https://bugzilla.gnome.org/show_bug.cgi?id=673135 Resolved as wontfix,
  # but needed to fix an assumption about the location of the d-bus machine
  # id file.
  patch do
    url "https://gist.github.com/jacknagel/6700436/raw/a94f21a9c5ccd10afa0a61b11455c880640f3133/glib-configurable-paths.patch"
    sha1 "911df7b09452c52ee3e0d269775d546cf7c077d1"
  end

  # Fixes compilation with FSF GCC. Doesn't fix it on every platform, due
  # to unrelated issues in GCC, but improves the situation.
  # Patch submitted upstream: https://bugzilla.gnome.org/show_bug.cgi?id=672777
  patch do
    url "https://gist.github.com/mistydemeo/8c7eaf0940b6b9159779/raw/11b3b1f09d15ccf805b0914a15eece11685ea8a5/gio.diff"
    sha1 "5afea1a284747d31039449ca970376430951ec55"
  end

  patch do
    url "https://gist.githubusercontent.com/jacknagel/9726139/raw/a3e716034dc082e98f179c9e490910211be1df4c/universal.patch"
    sha1 "1ce36591ff79bc05eeb89d91f008988e2f4c8cde"
  end if build.universal?

  def install
    ENV.universal_binary if build.universal?

    # Disable dtrace; see https://trac.macports.org/ticket/30413
    args = %W[
      --disable-maintainer-mode
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-dtrace
      --disable-libelf
      --prefix=#{prefix}
      --localstatedir=#{var}
      --with-gio-module-dir=#{HOMEBREW_PREFIX}/lib/gio/modules
    ]

    args << '--enable-static' if build.with? 'static'

    system "./configure", *args

    if build.universal?
      buildpath.install resource('config.h.ed')
      system "ed -s - config.h <config.h.ed"
    end

    system "make"
    # the spawn-multithreaded tests require more open files
    system "ulimit -n 1024; make check" if build.include? 'test'
    system "make install"

    # `pkg-config --libs glib-2.0` includes -lintl, and gettext itself does not
    # have a pkgconfig file, so we add gettext lib and include paths here.
    gettext = Formula["gettext"].opt_prefix
    inreplace lib+'pkgconfig/glib-2.0.pc' do |s|
      s.gsub! 'Libs: -L${libdir} -lglib-2.0 -lintl',
              "Libs: -L${libdir} -lglib-2.0 -L#{gettext}/lib -lintl"
      s.gsub! 'Cflags: -I${includedir}/glib-2.0 -I${libdir}/glib-2.0/include',
              "Cflags: -I${includedir}/glib-2.0 -I${libdir}/glib-2.0/include -I#{gettext}/include"
    end

    (share+'gtk-doc').rmtree
  end

  test do
    (testpath/'test.c').write <<-EOS.undent
      #include <string.h>
      #include <glib.h>

      int main(void)
      {
          gchar *result_1, *result_2;
          char *str = "string";

          result_1 = g_convert(str, strlen(str), "ASCII", "UTF-8", NULL, NULL, NULL);
          result_2 = g_convert(result_1, strlen(result_1), "UTF-8", "ASCII", NULL, NULL, NULL);

          return (strcmp(str, result_2) == 0) ? 0 : 1;
      }
      EOS
    flags = ["-I#{include}/glib-2.0", "-I#{lib}/glib-2.0/include", "-lglib-2.0"]
    system ENV.cc, "-o", "test", "test.c", *(flags + ENV.cflags.split)
    system "./test"
  end
end

__END__
diff --git a/gobject/gtype.h b/gobject/gtype.h
index 8a1bff2..4474ede 100644
--- a/gobject/gtype.h
+++ b/gobject/gtype.h
@@ -1580,7 +1580,7 @@ type_name##_get_type (void) \
  */
 #define G_DEFINE_BOXED_TYPE_WITH_CODE(TypeName, type_name, copy_func, free_func, _C_) _G_DEFINE_BOXED_TYPE_BEGIN (TypeName, type_name, copy_func, free_func) {_C_;} _G_DEFINE_TYPE_EXTENDED_END()

-#if !defined (__cplusplus) && (__GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ >= 7))
+#if !defined (__cplusplus) && (__GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ >= 7) && !defined (__ppc64__))
 #define _G_DEFINE_BOXED_TYPE_BEGIN(TypeName, type_name, copy_func, free_func) \
 GType \
 type_name##_get_type (void) \
