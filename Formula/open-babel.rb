require 'formula'

class OpenBabel < Formula
  homepage 'http://www.openbabel.org'
  url 'http://sourceforge.net/projects/openbabel/files/openbabel/2.3.2/openbabel-2.3.2.tar.gz'
  sha1 'b8831a308617d1c78a790479523e43524f07d50d'

  option 'with-cairo',  'Support PNG depiction'
  option 'with-java',   'Compile Java language bindings'

  depends_on 'pkg-config' => :build
  depends_on 'cmake' => :build
  depends_on :python => :optional
  depends_on 'wxmac' => :optional
  depends_on 'cairo' => :optional
  depends_on 'eigen' if build.with?('python') || build.with?('java')

  # Patch to fix Molecule.draw() in pybel in accordance with upstream commit df59c4a630cf753723d1318c40479d48b7507e1c
  def patches
    "https://gist.github.com/fredrikw/5858168/raw"
  end

  def install
    args = %W[ -DCMAKE_INSTALL_PREFIX=#{prefix} ]
    args << "-DJAVA_BINDINGS=ON" if build.with? 'java'
    args << "-DBUILD_GUI=ON" if build.with? 'wxmac'
    # Looking for Cairo in HOMEBREW_PREFIX
    # setting the arguments separately, joining them in one string fails with the 'system "cmake", *args' command
    args << "-DCAIRO_INCLUDE_DIRS='#{HOMEBREW_PREFIX}/include/cairo'" if build.with? 'cairo'
    args << "-DCAIRO_LIBRARIES='#{HOMEBREW_PREFIX}/lib/libcairo.dylib'" if build.with? 'cairo'

    python do
      args << "-DPYTHON_BINDINGS=ON"
      # For Xcode-only systems, the headers of system's python are inside of Xcode:
      args << "-DPYTHON_INCLUDE_DIR='#{python.incdir}'"
      # Cmake picks up the system's python dylib, even if we have a brewed one:
      args << "-DPYTHON_LIBRARY='#{python.libdir}/lib#{python.xy}.dylib'"
      args << "-DPYTHON_PACKAGES_PATH='#{python.site_packages}'"
    end

    args << '..'

    mkdir 'build' do
      system "cmake", *args
      system "make"
      system "make install"
    end

    python do
      python.site_packages.install lib/'openbabel.py', lib/'pybel.py', lib/'_openbabel.so'
    end
  end

  def caveats
    s = ''
    s += python.standard_caveats if python
    s += <<-EOS.undent
      Java libraries are installed to #{HOMEBREW_PREFIX}/lib so this path should be
      included in the CLASSPATH environment variable.
    EOS
  end

end
