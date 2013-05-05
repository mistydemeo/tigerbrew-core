require 'formula'

class Pyside < Formula
  homepage 'http://www.pyside.org'
  url 'http://qt-project.org/uploads/pyside/pyside-qt4.8+1.1.2.tar.bz2'
  mirror 'https://distfiles.macports.org/py-pyside/pyside-qt4.8+1.1.2.tar.bz2'
  sha1 'c0119775f2500e48efebdd50b7be7543e71b2c24'

  depends_on 'cmake' => :build
  depends_on 'shiboken'

  def which_python
    "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  end

  def install
    # The build will be unable to find Qt headers buried inside frameworks
    # unless the folder containing those frameworks is added to the compiler
    # search path.
    qt = Formula.factory 'qt'
    ENV.append_to_cflags "-F#{qt.frameworks}"

    # Also need `ALTERNATIVE_QT_INCLUDE_DIR` to prevent "missing file" errors.
    # Add out of tree build because one of its deps, shiboken, itself needs an
    # out of tree build in shiboken.rb.
    args = std_cmake_args + %W[
      -DALTERNATIVE_QT_INCLUDE_DIR=#{qt.frameworks}
      -DSITE_PACKAGE=lib/#{which_python}/site-packages
      -DBUILD_TESTS=NO
      ..
    ]
    mkdir 'macbuild' do
      system 'cmake', *args
      system 'make'
      system 'make install'
    end
  end

  def caveats
    <<-EOS
PySide Python modules have been linked to:
    #{HOMEBREW_PREFIX}/lib/#{which_python}/site-packages

Make sure this folder is on your PYTHONPATH. For PySide development tools,
install the `pyside-tools` formula.
    EOS
  end
end
