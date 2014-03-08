require "formula"

# speed up head clone, see: https://developer.mozilla.org/en-US/docs/Developer_Guide/Source_Code/Mercurial/Bundles
class HgBundleDownloadStrategy < CurlDownloadStrategy
  def hgpath
    MercurialDownloadStrategy.new(@name, @resource).hgpath
  end

  def fetch
    @repo = @url.split("|").last
    @url = @url.split("|").first
    super()
  end

  def stage
    safe_system "mkdir mozilla-central"
    safe_system hgpath, "init", "mozilla-central"
    chdir
    safe_system hgpath, "unbundle", @tarball_path
    safe_system hgpath, "pull", @repo
    safe_system hgpath, "update"
  end
end

class Python273Requirement < Requirement
  fatal true
  default_formula "python"

  satisfy do
    `python -V 2>&1` =~ /^Python 2.7.(\d+)/
    $1.to_i >= 3
  end
end

class Xulrunner < Formula
  homepage "https://developer.mozilla.org/docs/XULRunner"
  url "http://ftp.mozilla.org/pub/mozilla.org/xulrunner/releases/27.0.1/source/xulrunner-27.0.1.source.tar.bz2"
  sha1 "c9c5a6142fc9c50113c18eb8b1fb9249c08c4aac"

  devel do
    url "http://ftp.mozilla.org/pub/mozilla.org/xulrunner/releases/28.0b8/source/xulrunner-28.0b8.source.tar.bz2"
    sha1 "2c2bda033f7ce771b0aff82237551264911a32c3"
    version "28.0b8"
  end

  head do
    url "http://ftp.mozilla.org/pub/mozilla.org/firefox/bundles/mozilla-central.hg|https://hg.mozilla.org/mozilla-central/",
      :using => HgBundleDownloadStrategy
    depends_on "mercurial" => :build
    depends_on "gettext" => :build
  end

  depends_on :macos => :lion # needs clang++
  depends_on :xcode
  depends_on :python => :build
  depends_on Python273Requirement => :build
  depends_on "gnu-tar" => :build
  depends_on "pkg-config" => :build
  depends_on "yasm"

  fails_with :gcc do
    cause "Mozilla XULRunner only supports Clang on OS X"
  end

  fails_with :llvm do
    cause "Mozilla XULRunner only supports Clang on OS X"
  end

  resource "autoconf213" do
    url "http://ftpmirror.gnu.org/autoconf/autoconf-2.13.tar.gz"
    mirror "http://ftp.gnu.org/gnu/autoconf/autoconf-2.13.tar.gz"
    sha1 "e4826c8bd85325067818f19b2b2ad2b625da66fc"
  end

  def install
    if build.head?
      resource("autoconf213").stage do
        system "./configure", "--disable-debug", "--program-suffix=213", "--prefix=#{buildpath}/ac213"
        system "make", "install"
      end
      ENV["AUTOCONF"] = buildpath/"ac213/bin/autoconf213"
    end

    # build xulrunner to objdir and disable tests, updater.app and crashreporter.app, specify sdk path
    (buildpath/"mozconfig").write <<-EOS.undent
      . $topsrcdir/xulrunner/config/mozconfig
      mk_add_options MOZ_OBJDIR=objdir
      ac_add_options --disable-tests
      ac_add_options --disable-updater
      ac_add_options --disable-crashreporter
      ac_add_options --with-macos-sdk=#{MacOS.sdk_path}
    EOS
    # fixed usage of bsdtar with unsupported parameters (replaced with gnu-tar)
    inreplace "toolkit/mozapps/installer/packager.mk", "$(TAR) -c --owner=0 --group=0 --numeric-owner",
              "#{Formula["gnu-tar"].bin}/gtar -c --owner=0 --group=0 --numeric-owner"

    # nss is not fully parallel build safe (fixes rare ld: library not found for -lplc4 issues)
    ENV.deparallelize
    system "make", "-f", "client.mk", "build"
    system "make", "-f", "client.mk", "package"

    frameworks.mkpath
    if build.head?
      # update HEAD version here with every version bump
      tar_path = "objdir/dist/xulrunner-30.0a1.en-US.mac64.tar.bz2"
    else
      tar_path = "objdir/dist/xulrunner-#{version.to_s[/\d+\.\d+(\.\d+)?/]}.en-US.mac64.tar.bz2"
    end
    system "tar", "-xvj", "-C", frameworks, "-f", tar_path

    # symlink only xulrunner here will fail (assumes dylibs in same directory)
    bin.write_exec_script frameworks/"XUL.framework/Versions/Current/xulrunner"

    # fix Trace/BPT trap: 5 error on OS X 10.9, see laurentj/slimerjs#135
    # and https://bugzilla.mozilla.org/show_bug.cgi?id=922590#c4
    if MacOS.version >= :mavericks
      (frameworks/"XUL.framework/Versions/Current/Info.plist").write <<-EOS.undent
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <dict>
          <key>CFBundleIdentifier</key>
          <string>org.mozilla.xulrunner</string>
        </dict>
        </plist>
      EOS
    end
  end

  test do
    system "#{bin}/xulrunner", "-v"
  end
end
