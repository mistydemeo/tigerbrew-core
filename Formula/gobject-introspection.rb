require 'formula'

class GobjectIntrospection < Formula
  homepage 'http://live.gnome.org/GObjectIntrospection'
  url 'http://ftp.gnome.org/pub/GNOME/sources/gobject-introspection/1.38/gobject-introspection-1.38.0.tar.xz'
  sha256 '3575e5d353c17a567fdf7ffaaa7aebe9347b5b0eee8e69d612ba56a9def67d73'

  bottle do
    sha1 "08dcb543c8b7f2c8fc112278db752159edb420ba" => :mavericks
    sha1 "a65b28dde0014e5cf622657ac913e6ad5fd29709" => :mountain_lion
    sha1 "2adfc7d361663cd40780b19cccebfb275a180791" => :lion
  end

  option :universal
  option 'with-tests', 'Run tests in addition to the build (requires cairo)'

  depends_on 'pkg-config' => :build
  depends_on 'xz' => :build
  depends_on 'glib'
  depends_on 'libffi'
  # To avoid: ImportError: dlopen(./.libs/_giscanner.so, 2): Symbol not found: _PyList_Check
  depends_on :python
  depends_on 'cairo' => :build if build.with? 'tests'

  # Allow tests to execute on OS X (.so => .dylib)
  def patches
    "https://gist.github.com/krrk/6958869/raw/de8d83009d58eefa680a590f5839e61a6e76ff76/gobject-introspection-tests.patch"
  end if build.with? 'tests'

  def install
    ENV['GI_SCANNER_DISABLE_CACHE'] = 'true'
    ENV.universal_binary if build.universal?
    inreplace 'giscanner/transformer.py', '/usr/share', HOMEBREW_PREFIX/'share'
    inreplace 'configure' do |s|
      s.change_make_var! 'GOBJECT_INTROSPECTION_LIBDIR', HOMEBREW_PREFIX/'lib'
    end

    args = %W[--disable-dependency-tracking --prefix=#{prefix}]
    args << "--with-cairo" if build.with? "tests"

    system "./configure", *args
    system "make"
    system "make", "check" if build.with? "tests"
    system "make", "install"
  end
end
