require 'formula'

class OpenSceneGraph < Formula
  homepage 'http://www.openscenegraph.org/projects/osg'
  url 'http://trac.openscenegraph.org/downloads/developer_releases/OpenSceneGraph-3.2.0.zip'
  sha1 'c20891862b5876983d180fc4a3d3cfb2b4a3375c'

  head 'http://www.openscenegraph.org/svn/osg/OpenSceneGraph/trunk/'

  option 'docs', 'Build the documentation with Doxygen and Graphviz'
  option :cxx11

  depends_on 'cmake' => :build
  depends_on 'pkg-config' => :build
  depends_on 'jpeg'
  depends_on 'wget'
  depends_on 'gtkglext'
  depends_on 'gdal' => :optional
  depends_on 'jasper' => :optional
  depends_on 'openexr' => :optional
  depends_on 'dcmtk' => :optional
  depends_on 'librsvg' => :optional
  depends_on 'collada-dom' => :optional
  depends_on 'gnuplot' => :optional
  depends_on 'ffmpeg' => :optional
  depends_on 'qt5' => :optional
  depends_on 'qt' => :optional

  if build.include? 'docs'
    depends_on 'doxygen'
    depends_on 'graphviz'
  end

  def patches
    # Fix osgQt for Qt 5.2
    # Reported upstream http://forum.openscenegraph.org/viewtopic.php?t=13206
    DATA
  end

  def install
    ENV.cxx11 if build.cxx11?

    # Turning off FFMPEG takes this change or a dozen "-DFFMPEG_" variables
    unless build.with? 'ffmpeg'
      inreplace 'CMakeLists.txt', 'FIND_PACKAGE(FFmpeg)', '#FIND_PACKAGE(FFmpeg)'
    end

    args = std_cmake_args
    args << '-DBUILD_DOCUMENTATION=' + ((build.include? 'docs') ? 'ON' : 'OFF')

    if MacOS.prefer_64_bit?
      args << "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.arch_64_bit}"
      args << "-DOSG_DEFAULT_IMAGE_PLUGIN_FOR_OSX=imageio"
      args << "-DOSG_WINDOWING_SYSTEM=Cocoa"
    else
      args << "-DCMAKE_OSX_ARCHITECTURES=i386"
    end

    if Formula.factory('collada-dom').installed?
      args << "-DCOLLADA_INCLUDE_DIR=#{HOMEBREW_PREFIX}/include/collada-dom"
    end

    if build.with? 'qt5'
      args << "-DCMAKE_PREFIX_PATH=#{Formula.factory('qt5').opt_prefix}"
    elsif build.with? 'qt'
      args << "-DCMAKE_PREFIX_PATH=#{Formula.factory('qt').opt_prefix}"
    end

    args << '..'

    mkdir 'build' do
      system 'cmake', *args
      system 'make'
      system 'make', 'doc_openscenegraph' if build.include? 'docs'
      system 'make install'
      if build.include? 'docs'
        doc.install Dir["#{prefix}/doc/OpenSceneGraphReferenceDocs/*"]
      end
    end
  end
end

__END__
diff --git a/src/osgQt/CMakeLists.txt b/src/osgQt/CMakeLists.txt
index 43afffe..6c62e73 100644
--- a/src/osgQt/CMakeLists.txt
+++ b/src/osgQt/CMakeLists.txt
@@ -13,7 +13,11 @@ SET(SOURCES_H
 )

 IF ( Qt5Widgets_FOUND )
-    QT5_WRAP_CPP( SOURCES_H_MOC ${SOURCES_H} OPTIONS "-f" )
+    IF (Qt5Widgets_VERSION VERSION_LESS 5.2.0)
+        QT5_WRAP_CPP( SOURCES_H_MOC ${SOURCES_H} OPTIONS "-f" )
+    ELSE()
+        QT5_WRAP_CPP( SOURCES_H_MOC ${SOURCES_H} )
+    ENDIF()
 ELSE()
     QT4_WRAP_CPP( SOURCES_H_MOC ${SOURCES_H} OPTIONS "-f" )
 ENDIF()
