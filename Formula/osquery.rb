require "formula"

class Osquery < Formula
  desc "SQL powered operating system instrumentation and analytics"
  homepage "https://osquery.io"
  # pull from git tag to get submodules
  url "https://github.com/facebook/osquery.git", :tag => "1.4.6", :revision => "b56e9efd47efeea487b90fd7c137b55b3254c6c8"

  bottle do
    sha256 "73ef1b702ac0711cb8ae97c56688c0396104d042d4d735d9120274edbb87072f" => :yosemite
    sha256 "b065db81d07ad1bbc6f4f06438bd694cc5cf536364da0f518b39ba89bd715838" => :mavericks
  end

  # Build currently fails on Mountain Lion:
  # https://github.com/facebook/osquery/issues/409
  # Will welcome PRs to fix this!
  depends_on :macos => :mavericks

  depends_on "cmake" => :build
  depends_on "boost" => :build
  depends_on "doxygen" => :build
  depends_on "gflags" => :build
  depends_on "rocksdb" => :build
  depends_on "thrift" => :build
  depends_on "yara" => :build
  depends_on "openssl"

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
  end

  plist_options :startup => true, :manual => "osqueryd"

  test do
    require 'open3'
    Open3.popen3("#{bin}/osqueryi") do |stdin, stdout, _|
      stdin.write(".mode line\nSELECT count(version) as lines FROM osquery_info;")
      stdin.close
      assert_equal "lines = 1\n", stdout.read
    end
  end
end
