require 'formula'

def needs_universal_python?
  build.universal? and not build.include? "without-python"
end

class UniversalPython < Requirement
  def message; <<-EOS.undent
    A universal build was requested, but Python is not a universal build

    Boost compiles against the Python it finds in the path; if this Python
    is not a universal build then linking will likely fail.
    EOS
  end
  def satisfied?
    archs_for_command("python").universal?
  end
end

class Boost < Formula
  homepage 'http://www.boost.org'
  url 'http://downloads.sourceforge.net/project/boost/boost/1.52.0/boost_1_52_0.tar.bz2'
  sha1 'cddd6b4526a09152ddc5db856463eaa1dc29c5d9'

  head 'http://svn.boost.org/svn/boost/trunk'

  bottle do
    sha1 'a4e733fe67c15b7bfe500b0855d84616152f7042' => :mountainlion
    sha1 'dd94aac5f03fb553c1c0e393fbd346748b0bc524' => :lion
    sha1 '5fae01afa7e5c6e2d29ec32a24324fdaa14cf594' => :snowleopard
  end

  env :userpaths

  option :universal
  option 'with-mpi', 'Enable MPI support'
  option 'without-python', 'Build without Python'
  option 'with-icu', 'Build regexp engine with icu support'
  option 'with-c++11', 'Compile using Clang, std=c++11 and stdlib=libc++' if MacOS.version >= :lion

  depends_on UniversalPython.new if needs_universal_python?
  depends_on "icu4c" if build.include? "with-icu"
  depends_on MPIDependency.new(:cc, :cxx) if build.include? "with-mpi"

  fails_with :llvm do
    build 2335
    cause "Dropped arguments to functions when linking with boost"
  end

  # Patch boost/config/stdlib/libcpp.hpp to fix the constexpr bug reported under Boost 1.52 in Ticket
  # 7671.  This patch can be removed when upstream release an updated version including the fix.
  def patches
    if MacOS.version >= :lion and build.include? 'with-c++11'
      {:p0 => "https://svn.boost.org/trac/boost/raw-attachment/ticket/7671/libcpp_c11_numeric_limits.patch"}
    end
  end

  def install
    # Adjust the name the libs are installed under to include the path to the
    # Homebrew lib directory so executables will work when installed to a
    # non-/usr/local location.
    #
    # otool -L `which mkvmerge`
    # /usr/local/bin/mkvmerge:
    #   libboost_regex-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
    #   libboost_filesystem-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
    #   libboost_system-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
    #
    # becomes:
    #
    # /usr/local/bin/mkvmerge:
    #   /usr/local/lib/libboost_regex-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
    #   /usr/local/lib/libboost_filesystem-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
    #   /usr/local/lib/libboost_system-mt.dylib (compatibility version 0.0.0, current version 0.0.0)
    inreplace 'tools/build/v2/tools/darwin.jam', '-install_name "', "-install_name \"#{HOMEBREW_PREFIX}/lib/"

    # boost will try to use cc, even if we'd rather it use, say, gcc-4.2
    inreplace 'tools/build/v2/engine/build.sh', 'BOOST_JAM_CC=cc', "BOOST_JAM_CC=#{ENV.cc}"
    inreplace 'tools/build/v2/engine/build.jam', 'toolset darwin cc', "toolset darwin #{ENV.cc}"

    # Force boost to compile using the appropriate GCC version
    open("user-config.jam", "a") do |file|
      file.write "using darwin : : #{ENV.cxx} ;\n"
      file.write "using mpi ;\n" if build.include? 'with-mpi'
    end

    # we specify libdir too because the script is apparently broken
    bargs = ["--prefix=#{prefix}", "--libdir=#{lib}"]

    bargs << "--with-toolset=clang" if build.include? "with-c++11"

    if build.include? 'with-icu'
      icu4c_prefix = Formula.factory('icu4c').opt_prefix
      bargs << "--with-icu=#{icu4c_prefix}"
    else
      bargs << '--without-icu'
    end

    args = ["--prefix=#{prefix}",
            "--libdir=#{lib}",
            "-d2",
            "-j#{ENV.make_jobs}",
            "--layout=tagged",
            "--user-config=user-config.jam",
            "threading=multi",
            "install"]

    # Macports does this
    args << "--disable-long-double" if Hardware.cpu_type == :ppc

    if MacOS.version >= :lion and build.include? 'with-c++11'
      args << "toolset=clang" << "cxxflags=-std=c++11"
      args << "cxxflags=-stdlib=libc++" << "cxxflags=-fPIC"
      args << "linkflags=-stdlib=libc++"
      args << "linkflags=-headerpad_max_install_names"
      args << "linkflags=-arch x86_64"
    end

    args << "address-model=32_64" << "architecture=x86" << "pch=off" if build.universal?
    args << "--without-python" if build.include? "without-python"

    system "./bootstrap.sh", *bargs
    system "./b2", *args
  end
end
