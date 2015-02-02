require "formula"

class Osquery < Formula
  homepage "http://osquery.io"
  # pull from git tag to get submodules
  url "https://github.com/facebook/osquery.git", :tag => "1.3.1"

  bottle do
    sha1 "01f4d94a896512fa89649b3e4d241671840e2492" => :yosemite
    sha1 "4afedc9a5bfbd19dd62770fb9c6c84bdebf1b548" => :mavericks
  end

  # Build currently fails on Mountain Lion:
  # https://github.com/facebook/osquery/issues/409
  # Will welcome PRs to fix this!
  depends_on :macos => :mavericks

  depends_on "cmake" => :build

  depends_on "boost"
  depends_on "gflags"
  depends_on "glog"
  depends_on "openssl"
  depends_on "rocksdb"
  depends_on "thrift"

  resource "markupsafe" do
    url "https://pypi.python.org/packages/source/M/MarkupSafe/MarkupSafe-0.23.tar.gz"
    sha1 "cd5c22acf6dd69046d6cb6a3920d84ea66bdf62a"
  end

  resource "jinja2" do
    url "https://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.7.3.tar.gz"
    sha1 "25ab3881f0c1adfcf79053b58de829c5ae65d3ac"
  end

  def install
    ENV.prepend_create_path "PYTHONPATH", buildpath+"third-party/python/lib/python2.7/site-packages"

    resources.each do |r|
      r.stage { system "python", "setup.py", "install",
                                 "--prefix=#{buildpath}/third-party/python/",
                                 "--single-version-externally-managed",
                                 "--record=installed.txt"}
    end

    system "cmake", ".", *std_cmake_args
    system "make"
    system "make", "install"

    prefix.install "tools/deployment/com.facebook.osqueryd.plist"
  end

  plist_options :startup => true, :manual => "osqueryd"

  test do
    require 'open3'
    Open3.popen3("#{bin}/osqueryi") do |stdin, stdout, _|
      stdin.write(".mode line\nSELECT major FROM osx_version;")
      stdin.close
      assert_equal "major = 10\n", stdout.read
    end
  end
end
