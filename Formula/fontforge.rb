require 'formula'

class Fontforge < Formula
  homepage 'http://fontforge.org/'
  url 'http://downloads.sourceforge.net/project/fontforge/fontforge-source/fontforge_full-20120731-b.tar.bz2'
  sha1 'b520f532b48e557c177dffa29120225066cc4e84'

  head 'https://github.com/fontforge/fontforge.git'

  option 'with-gif', 'Build with GIF support'
  option 'with-x', 'Build with X'

  depends_on 'gettext'
  depends_on :python => :recommended

  depends_on :libpng    => :recommended
  depends_on 'jpeg'     => :recommended
  depends_on 'libtiff'  => :recommended
  depends_on :x11 if build.with? 'x'
  depends_on 'giflib' if build.with? 'gif'
  depends_on 'cairo' => :optional
  depends_on 'pango' => :optional
  depends_on 'libspiro' => :optional
  depends_on 'fontconfig'

  fails_with :llvm do
    build 2336
    cause "Compiling cvexportdlg.c fails with error: initializer element is not constant"
  end

  def install
    args = ["--prefix=#{prefix}",
            "--enable-double",
            "--without-freetype-bytecode"]

    args << "--without-cairo" unless build.with? "cairo"
    args << "--without-pango" unless build.with? "pango"
    args << "--without-x" unless build.with? 'x'

    # To avoid "dlopen(/opt/local/lib/libpng.2.dylib, 1): image not found"
    args << "--with-static-imagelibs"

    if build.with? 'python'
      args << "--enable-pyextension"
      # Fix linking to correct Python library
      ENV.prepend "LDFLAGS", "-L#{python.libdir}"
    else
      args << "--without-python"
    end

    # Fix linker error; see: http://trac.macports.org/ticket/25012
    ENV.append "LDFLAGS", "-lintl"

    # Reset ARCHFLAGS to match how we build
    ENV["ARCHFLAGS"] = "-arch #{MacOS.preferred_arch}"

    # Set up framework paths so FlatCarbon replacement paths work (see below)
    ENV.append "CFLAGS", "-F#{MacOS.sdk_path}/System/Library/Frameworks/CoreServices.framework/Frameworks"
    ENV.append "CFLAGS", "-F#{MacOS.sdk_path}/System/Library/Frameworks/Carbon.framework/Frameworks"

    system "./configure", *args

    # Fix hard-coded install locations that don't respect the target bindir
    inreplace "Makefile" do |s|
      s.gsub! "/Applications", "$(prefix)"
      s.gsub! "ln -s /usr/local/bin/fontforge", "ln -s $(bindir)/fontforge"
    end

    # Fix install location of Python extension; see:
    # http://sourceforge.net/mailarchive/message.php?msg_id=26827938
    inreplace "Makefile" do |s|
      s.gsub! "python setup.py install --prefix=$(prefix) --root=$(DESTDIR)", "#{python} setup.py install --prefix=$(prefix)"
    end

    # Replace FlatCarbon headers with the real paths
    # Fixes building on 10.8
    inreplace %w(fontforge/macbinary.c fontforge/startui.c gutils/giomime.c) do |s|
      s.gsub! "/Developer/Headers/FlatCarbon/Files.h", "CarbonCore/Files.h"
    end
    inreplace %w(fontforge/startui.c) do |s|
      s.gsub! "/Developer/Headers/FlatCarbon/CarbonEvents.h", "HIToolbox/CarbonEvents.h"
    end

    system "make"
    system "make install"
  end

  test do
    system "#{bin}/fontforge", "-version"
    python do
      system python, "-c", "import fontforge"
    end
  end

  def caveats
    x_caveats = <<-EOS.undent
      fontforge is an X11 application.

      To install the Mac OS X wrapper application run:
        brew linkapps
      or:
        ln -s #{opt_prefix}/FontForge.app /Applications
    EOS

    s = ""
    s += x_caveats if build.with? "x"
    s += python.standard_caveats if python
    return s
  end

  def patches
    # Fixes double defined AnchorPoint on Mountain Lion 10.8.2
    "https://gist.github.com/rubenfonseca/5078149/raw/98a812df4e8c50d5a639877bc2d241e5689f1a14/fontforge"
  end
end
