require 'formula'

class Shark < Formula
  homepage 'http://shark-project.sourceforge.net/'
  url 'http://downloads.sourceforge.net/project/shark-project/Shark%20Core/Shark%202.3.4/shark-2.3.4.zip'
  sha1 '0b1b054872fe057747ff7f50e360499bb78bebdf'

  fails_with :clang do
    build 500
    cause "C++ is hard." # see error output below
  end

  #  include/FileUtil/FileUtil.h:416:3: error: call to function 'scanFrom_strict' that is neither visible in the template definition nor found by argument-dependent lookup
  #                  scanFrom_strict(is, token, val, true);
  #                  ^

  depends_on 'cmake' => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make install"
  end
end
