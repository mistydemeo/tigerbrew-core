require "formula"

class Rethinkdb < Formula
  homepage "http://www.rethinkdb.com/"
  url "http://download.rethinkdb.com/dist/rethinkdb-1.15.0-1.tgz"
  version "1.15.0"
  sha1 "eb68b3a2f9e6c1eb917bec1e46c3cef86fe3c25b"

  bottle do
    sha1 "4b5f1269335697008c507f528c68d3a59dd2cc02" => :mavericks
    sha1 "925bad3bb759089349aca73b112c036347101342" => :mountain_lion
    sha1 "1c1ab85203934327dffed316d55a63cc34430582" => :lion
  end

  depends_on :macos => :lion
  depends_on "boost" => :build

  fails_with :gcc do
    build 5666 # GCC 4.2.1
    cause "RethinkDB uses C++0x"
  end

  # boost 1.56 compatibility
  # https://github.com/rethinkdb/rethinkdb/issues/3044#issuecomment-55478774
  patch :DATA

  def install
    args = ["--prefix=#{prefix}"]

    # brew's v8 is too recent. rethinkdb uses an older v8 API
    args += ["--fetch", "v8"]

    # rethinkdb requires that protobuf be linked against libc++
    # but brew's protobuf is sometimes linked against libstdc++
    args += ["--fetch", "protobuf"]

    # support gcc with boost 1.56
    # https://github.com/rethinkdb/rethinkdb/issues/3044#issuecomment-55471981
    args << "CXXFLAGS=-DBOOST_VARIANT_DO_NOT_USE_VARIADIC_TEMPLATES"

    system "./configure", *args
    system "make"
    system "make", "install-osx"

    mkdir_p "#{var}/log/rethinkdb"
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
          <string>#{opt_bin}/rethinkdb</string>
          <string>-d</string>
          <string>#{var}/rethinkdb</string>
      </array>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/rethinkdb/rethinkdb.log</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/rethinkdb/rethinkdb.log</string>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <true/>
    </dict>
    </plist>
    EOS
  end
end
__END__
diff --git a/src/clustering/reactor/reactor_be_primary.cc b/src/clustering/reactor/reactor_be_primary.cc
index 3f583fc..945f78b 100644
--- a/src/clustering/reactor/reactor_be_primary.cc
+++ b/src/clustering/reactor/reactor_be_primary.cc
@@ -290,7 +290,7 @@ void do_backfill(

 bool check_that_we_see_our_broadcaster(const boost::optional<boost::optional<broadcaster_business_card_t> > &maybe_a_
     guarantee(maybe_a_business_card, "Not connected to ourselves\n");
-    return maybe_a_business_card.get();
+    return static_cast<bool>(maybe_a_business_card.get());
 }

 bool reactor_t::attempt_backfill_from_peers(directory_entry_t *directory_entry,
