class Sip < Formula
  homepage "http://www.riverbankcomputing.co.uk/software/sip"
  url "https://downloads.sf.net/project/pyqt/sip/sip-4.16.5/sip-4.16.5.tar.gz"
  sha1 "d5d7b6765de8634eccf48a250dbd915f01b2a771"

  bottle do
    sha1 "92f54a37300cd0d1881a6d8d2e218ecd0532a70a" => :yosemite
    sha1 "6b0a127bbb486c17c045788d85e92b3008469395" => :mavericks
    sha1 "0c103fbd3a6dac723336f968d6e1faae23e34a32" => :mountain_lion
  end

  head "http://www.riverbankcomputing.co.uk/hg/sip", :using => :hg

  depends_on :python => :recommended
  depends_on :python3 => :optional

  if build.without?("python3") && build.without?("python")
    odie "sip: --with-python3 must be specified when using --without-python"
  end

  def install
    if build.head?
      # Link the Mercurial repository into the download directory so
      # build.py can use it to figure out a version number.
      ln_s cached_download + ".hg", ".hg"
      # build.py doesn't run with python3
      system "python", "build.py", "prepare"
    end

    Language::Python.each_python(build) do |python, version|
      # Note the binary `sip` is the same for python 2.x and 3.x
      system python, "configure.py",
                     "--deployment-target=#{MacOS.version}",
                     "--destdir=#{lib}/python#{version}/site-packages",
                     "--bindir=#{bin}",
                     "--incdir=#{include}",
                     "--sipdir=#{HOMEBREW_PREFIX}/share/sip"
      system "make"
      system "make", "install"
      system "make", "clean"
    end
  end

  def post_install
    mkdir_p "#{HOMEBREW_PREFIX}/share/sip"
  end

  def caveats
    "The sip-dir for Python is #{HOMEBREW_PREFIX}/share/sip."
  end

  test do
    (testpath/"test.h").write <<-EOS.undent
      #pragma once
      class Test {
      public:
        Test();
        void test();
      };
    EOS
    (testpath/"test.cpp").write <<-EOS.undent
      #include "test.h"
      #include <iostream>
      Test::Test() {}
      void Test::test()
      {
        std::cout << "Hello World!" << std::endl;
      }
    EOS
    (testpath/"test.sip").write <<-EOS.undent
      %Module test
      class Test {
      %TypeHeaderCode
      #include "test.h"
      %End
      public:
        Test();
        void test();
      };
    EOS
    (testpath/"run.py").write <<-EOS.undent
      from test import Test
      t = Test()
      t.test()
    EOS
    system "#{bin}/sip", "-c", ".", "test.sip"
    Language::Python.each_python(build) do |python, _version|
      cppflags = `#{python}-config --cflags`.strip.split
      ldflags = `#{python}-config --ldflags`.strip.split
      cppflags << "-I#{include}"
      ldflags += %w[-L#{lib} -shared -undefined dynamic_lookup]
      Dir[testpath/"*.cpp"].each do |source|
        object = File.basename(source, ".cpp") + ".o"
        system ENV.cxx, "-c", source, "-o", object, *cppflags
      end
      link_args= Dir[testpath/"*.o"] + %w[-o test.so] + ldflags
      system ENV.cxx, *link_args
      system python, "run.py"
    end
  end
end
