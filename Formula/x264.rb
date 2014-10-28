require "formula"

class X264 < Formula
  homepage "https://www.videolan.org/developers/x264.html"
  # the latest commit on the stable branch
  url "https://git.videolan.org/git/x264.git", :revision => "021c0dc6c95c1bc239c9db78a80dd85fc856a4dd"
  version "r2455"
  head "https://git.videolan.org/git/x264.git"

  devel do
    # the latest commit on the master branch
    url "https://git.videolan.org/git/x264.git", :revision => "dd79a61e0e354a432907f2d1f7137b27a12dfce7"
    version "r2479"
  end

  bottle do
    cellar :any
    revision 1
    sha1 "dd035a889bb65ba9ae9cc4815a4159e8d28a5ff2" => :yosemite
    sha1 "4dcf404cc4609578b5dffc94e2aff366f0a5d193" => :mavericks
    sha1 "a49c0943b4b420607c410f6736f9edf3d50704c2" => :mountain_lion
  end

  depends_on :ld64
  # reports that ASM causes a crash on G3; works on G4
  depends_on "yasm" => :build unless Hardware::CPU.family == :g3

  option "10-bit", "Build a 10-bit x264 (default: 8-bit)"
  option "with-mp4=", "Select mp4 output: none (default), l-smash or gpac"

  case ARGV.value "with-mp4"
  when "l-smash" then depends_on "l-smash"
  when "gpac" then depends_on "gpac"
  end

  def install
    # On Darwin/PPC x264 always uses -fastf,
    # which isn't supported by FSF GCC.
    if ![:gcc, :llvm, :gcc_4_0].include? ENV.compiler
      inreplace "configure", "-fastf", ""
    end
    
    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --enable-static
      --enable-strip
    ]
    if Formula["l-smash"].installed?
      args << "--disable-gpac"
    elsif Formula["gpac"].installed?
      args << "--disable-lsmash"
    end
    args << "--bit-depth=10" if build.include? "10-bit"
    args << "--disable-asm" if Hardware::CPU.family == :g3

    # For running version.sh correctly
    buildpath.install_symlink cached_download/".git"

    system "./configure", *args
    system "make", "install"
  end
end
