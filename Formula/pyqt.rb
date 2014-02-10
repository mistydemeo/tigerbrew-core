require 'formula'

class Pyqt < Formula
  homepage 'http://www.riverbankcomputing.co.uk/software/pyqt'
  url 'http://downloads.sf.net/project/pyqt/PyQt4/PyQt-4.10.3/PyQt-mac-gpl-4.10.3.tar.gz'
  sha1 'ba5465f92fb43c9f0a5b948fa25df5045f160bf0'

  depends_on :python => :recommended
  depends_on :python3 => :optional

  if !Formula.factory("python").installed? && build.with?("python") &&
     build.with?("python3")
    odie <<-EOS.undent
      pyqt: You cannot use system Python 2 and Homebrew's Python 3 simultaneously.
      Either `brew install python` or use `--without-python3`.
    EOS
  elsif build.without?("python3") && build.without?("python")
    odie "pyqt: --with-python3 must be specified when using --without-python"
  end

  depends_on 'qt'  # From their site: PyQt currently supports Qt v4 and will build against Qt v5

  if build.with? "python3"
    depends_on "sip" => "with-python3"
  else
    depends_on "sip"
  end

  def pythons
    pythons = []
    ["python", "python3"].each do |python|
      next if build.without? python
      version = /\d\.\d/.match `#{python} --version 2>&1`
      pythons << [python, version]
    end
    pythons
  end

  def patches
    # On Mavericks we want to target libc++, but this requires a user specified
    # qmake makespec. Unfortunately user specified makespecs are broken in the
    # configure.py script, so we have to fix the makespec path handling logic.
    # Also qmake spec macro parsing does not properly handle inline comments,
    # which can result in ignored build flags when they are concatenated together.
    # Changes proposed upstream: http://www.riverbankcomputing.com/pipermail/pyqt/2013-December/033537.html
    DATA
  end

  def install
    # On Mavericks we want to target libc++, this requires a non default qt makespec
    if ENV.compiler == :clang and MacOS.version >= :mavericks
      ENV.append "QMAKESPEC", "unsupported/macx-clang-libc++"
    end

    pythons.each do |python, version|
      ENV["PYTHONPATH"] = HOMEBREW_PREFIX/"opt/sip/lib/python#{version}/site-packages"

      args = ["--confirm-license",
              "--bindir=#{bin}",
              "--destdir=#{lib}/python#{version}/site-packages",
              "--sipdir=#{HOMEBREW_PREFIX}/share/sip"]

      # We need to run "configure.py" so that pyqtconfig.py is generated, which
      # is needed by PyQWT (and many other PyQt interoperable implementations such
      # as the ROS GUI libs). This file is currently needed for generating build
      # files appropriate for the qmake spec that was used to build Qt. This method
      # is deprecated and will be removed with SIP v5, so we do the actual compile
      # using the newer configure-ng.py as recommended.

      inreplace "configure.py", "iteritems", "items" if python == "python3"
      system python, "configure.py", *args
      (lib/"python#{version}/site-packages/PyQt4").install "pyqtconfig.py"

      # On Mavericks we want to target libc++, this requires a non default qt makespec
      if ENV.compiler == :clang and MacOS.version >= :mavericks
        args << "--spec" << "unsupported/macx-clang-libc++"
      end

      system python, "./configure-ng.py", *args
      system "make"
      system "make", "install"
      system "make", "clean" if pythons.length > 1
    end
  end

  def caveats
    "Phonon support is broken."
  end

  test do
    Pathname('test.py').write <<-EOS.undent
      import sys
      from PyQt4 import QtGui, QtCore

      class Test(QtGui.QWidget):
          def __init__(self, parent=None):
              QtGui.QWidget.__init__(self, parent)
              self.setGeometry(300, 300, 400, 150)
              self.setWindowTitle('Homebrew')
              QtGui.QLabel("Python " + "{0}.{1}.{2}".format(*sys.version_info[0:3]) +
                           " working with PyQt4. Quitting now...", self).move(50, 50)
              QtCore.QTimer.singleShot(1500, QtGui.qApp, QtCore.SLOT('quit()'))

      app = QtGui.QApplication([])
      window = Test()
      window.show()
      sys.exit(app.exec_())
    EOS

    pythons.each do |python, version|
      unless Formula.factory(python).installed?
        ENV["PYTHONPATH"] = HOMEBREW_PREFIX/"lib/python#{version}/site-packages"
      end
      system python, "test.py"
    end
  end
end
__END__
diff --git a/configure.py b/configure.py
index a8e5dcd..a5f1474 100644
--- a/configure.py
+++ b/configure.py
@@ -1886,7 +1886,7 @@ def get_build_macros(overrides):
     if "QMAKESPEC" in list(os.environ.keys()):
         fname = os.environ["QMAKESPEC"]

-        if not os.path.dirname(fname):
+        if not os.path.dirname(fname) or fname.startswith('unsupported'):
             qt_macx_spec = fname
             fname = os.path.join(qt_archdatadir, "mkspecs", fname)
     elif sys.platform == "darwin":
@@ -1934,6 +1934,11 @@ def get_build_macros(overrides):
     if macros is None:
         return None

+    # QMake macros may contain comments on the same line so we need to remove them
+    for macro, value in macros.iteritems():
+        if "#" in value:
+            macros[macro] = value.split("#", 1)[0]
+
     # Qt5 doesn't seem to support the specific macros so add them if they are
     # missing.
     if macros.get("INCDIR_QT", "") == "":
