require 'formula'

class KyotoTycoon < Formula
  homepage 'http://fallabs.com/kyototycoon/'
  url 'http://fallabs.com/kyototycoon/pkg/kyototycoon-0.9.56.tar.gz'
  sha1 'e5433833e681f8755ff6b9f7209029ec23914ce6'

  option "no-lua", "Disable Lua support"

  depends_on 'lua' unless build.include? "no-lua"
  depends_on 'kyoto-cabinet'

  def install
    # Locate kyoto-cabinet for non-/usr/local builds
    cabinet = Formula.factory("kyoto-cabinet")
    args = ["--prefix=#{prefix}", "--with-kc=#{cabinet.opt_prefix}"]
    args << "--enable-lua" unless build.include? "no-lua"

    system "./configure", *args
    system "make"
    system "make install"
  end

  def patches
    if MacOS.version >= :mavericks
      DATA
    end
  end
end


__END__
--- a/ktdbext.h  2013-11-08 09:34:53.000000000 -0500
+++ b/ktdbext.h  2013-11-08 09:35:00.000000000 -0500
@@ -271,7 +271,7 @@
       if (!logf("prepare", "started to open temporary databases under %s", tmppath.c_str()))
         err = true;
       stime = kc::time();
-      uint32_t pid = getpid() & kc::UINT16MAX;
+      uint32_t pid = kc::getpid() & kc::UINT16MAX;
       uint32_t tid = kc::Thread::hash() & kc::UINT16MAX;
       uint32_t ts = kc::time() * 1000;
       for (size_t i = 0; i < dbnum_; i++) {
