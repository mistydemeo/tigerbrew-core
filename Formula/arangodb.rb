require 'formula'

class Arangodb < Formula
  homepage 'http://www.arangodb.org/'
  url 'https://www.arangodb.org/repositories/Source/ArangoDB-2.2.3.tar.gz'
  sha1 '57b11419c6dcd6675570fcd88f94fe5ed8ef64ff'

  head "https://github.com/triAGENS/ArangoDB.git", :branch => 'unstable'

  bottle do
    sha1 "ece51b3ac2ba6ec5db359a2961a07e41858f255f" => :mavericks
    sha1 "fb3a3c9c370bf33f5c339e29aa945ab5ab4590cd" => :mountain_lion
    sha1 "c041fb81737c038051531d63e9fa419b4997da99" => :lion
  end

  depends_on 'go' => :build

  needs :cxx11

  def suffix
    if build.stable?
      return ""
    else
      return "-" + (build.devel? ? version : "unstable")
    end
  end

  def install
    # clang on 10.8 will still try to build against libstdc++,
    # which fails because it doesn't have the C++0x features
    # arangodb requires.
    ENV.libcxx

    # Bundled V8 tries to build with a 10.5 deployment target,
    # which causes clang to error out b/c a 10.5 deployment target
    # and -stdlib=libc++ are not valid together.
    inreplace "3rdParty/V8/build/standalone.gypi",
      "'mac_deployment_target%': '10.5',",
      "'mac_deployment_target%': '#{MacOS.version}',"

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-relative
      --enable-all-in-one-icu
      --enable-all-in-one-libev
      --enable-all-in-one-v8
      --enable-mruby
      --datadir=#{share}
      --localstatedir=#{var}
      --program-suffix=#{suffix}
    ]

    system "./configure", *args
    system "make install"

    (var/'arangodb').mkpath
    (var/'log/arangodb').mkpath
  end

  def post_install
    system "#{sbin}/arangod", "--upgrade", "--log.file", "-"
  end

  plist_options :manual => "#{HOMEBREW_PREFIX}/opt/arangodb/sbin/arangod --log.file -"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_sbin}/arangod</string>
          <string>-c</string>
          <string>#{etc}/arangodb/arangod.conf</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
    EOS
  end
end
