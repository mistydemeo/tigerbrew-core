require 'formula'

class NpmNotInstalled < Requirement
  fatal true

  def modules_folder
    "#{HOMEBREW_PREFIX}/lib/node_modules"
  end

  def message; <<-EOS.undent
    Beginning with 0.8.0, this recipe now comes with npm.
    It appears you already have npm installed at #{modules_folder}/npm.
    To use the npm that comes with this recipe, first uninstall npm with
    `npm uninstall npm -g`, then run this command again.

    If you would like to keep your installation of npm instead of
    using the one provided with homebrew, install the formula with
    the `--without-npm` option.
    EOS
  end

  satisfy :build_env => false do
    begin
      path = Pathname.new("#{modules_folder}/npm/bin/npm")
      path.realpath.to_s.include?(HOMEBREW_CELLAR)
    rescue Errno::ENOENT
      true
    end
  end
end

class Node < Formula
  homepage 'http://nodejs.org/'
  url 'http://nodejs.org/dist/v0.10.13/node-v0.10.13.tar.gz'
  sha1 'f73d5f134296ed0aa16cbec5d727f94587844155'

  devel do
    url 'http://nodejs.org/dist/v0.11.4/node-v0.11.4.tar.gz'
    sha1 '0035d18e2dcf9aad669b1c7c07319e17abfe3762'
  end

  head 'https://github.com/joyent/node.git'

  option 'enable-debug', 'Build with debugger hooks'
  option 'without-npm', 'npm will not be installed'

  depends_on NpmNotInstalled unless build.without? 'npm'
  depends_on :python => ["2.6", :build]

  fails_with :llvm do
    build 2326
  end

  # fixes gyp's detection of system paths on CLT-only systems
  def patches; DATA; end

  def install
    args = %W{--prefix=#{prefix}}

    args << "--debug" if build.include? 'enable-debug'
    args << "--without-npm" if build.include? 'without-npm'

    system "./configure", *args
    system "make install"

    unless build.include? 'without-npm'
      (lib/"node_modules/npm/npmrc").write("prefix = #{npm_prefix}\n")
      # we need to force make this directory, or node modules installed here
      # by npm will end up in the node keg and won't survive upgrades
      mkdir_p "#{HOMEBREW_PREFIX}/lib/node_modules"
    end
  end

  def npm_prefix
    d = "#{HOMEBREW_PREFIX}/share/npm"
    if File.directory? d
      d
    else
      HOMEBREW_PREFIX.to_s
    end
  end

  def caveats
    if build.include? 'without-npm' then <<-end.undent
      Homebrew has NOT installed npm. If you later install it, you should supplement
      your NODE_PATH with the npm module folder:
          #{npm_prefix}/lib/node_modules
      end
    elsif not ENV['PATH'].split(':').include? "#{npm_prefix}/bin"; <<-end.undent
      Probably you should amend your PATH to include npm-installed binaries:
          #{npm_prefix}/bin
      end
    end
  end
end

__END__
diff --git a/tools/gyp/pylib/gyp/xcode_emulation.py b/tools/gyp/pylib/gyp/xcode_emulation.py
index 806f92b..5256856 100644
--- a/tools/gyp/pylib/gyp/xcode_emulation.py
+++ b/tools/gyp/pylib/gyp/xcode_emulation.py
@@ -224,8 +224,7 @@ class XcodeSettings(object):
 
   def _GetSdkVersionInfoItem(self, sdk, infoitem):
     job = subprocess.Popen(['xcodebuild', '-version', '-sdk', sdk, infoitem],
-                           stdout=subprocess.PIPE,
-                           stderr=subprocess.STDOUT)
+                           stdout=subprocess.PIPE)
     out = job.communicate()[0]
     if job.returncode != 0:
       sys.stderr.write(out + '\n')
@@ -234,9 +233,17 @@ class XcodeSettings(object):
 
   def _SdkPath(self):
     sdk_root = self.GetPerTargetSetting('SDKROOT', default='macosx')
+    if sdk_root.startswith('/'):
+      return sdk_root
     if sdk_root not in XcodeSettings._sdk_path_cache:
-      XcodeSettings._sdk_path_cache[sdk_root] = self._GetSdkVersionInfoItem(
-          sdk_root, 'Path')
+      try:
+        XcodeSettings._sdk_path_cache[sdk_root] = self._GetSdkVersionInfoItem(
+            sdk_root, 'Path')
+      except:
+        # if this fails it's because xcodebuild failed, which means
+        # the user is probably on a CLT-only system, where there
+        # is no valid SDK root
+        XcodeSettings._sdk_path_cache[sdk_root] = None
     return XcodeSettings._sdk_path_cache[sdk_root]
 
   def _AppendPlatformVersionMinFlags(self, lst):
@@ -339,10 +346,11 @@ class XcodeSettings(object):
 
     cflags += self._Settings().get('WARNING_CFLAGS', [])
 
-    config = self.spec['configurations'][self.configname]
-    framework_dirs = config.get('mac_framework_dirs', [])
-    for directory in framework_dirs:
-      cflags.append('-F' + directory.replace('$(SDKROOT)', sdk_root))
+    if 'SDKROOT' in self._Settings():
+      config = self.spec['configurations'][self.configname]
+      framework_dirs = config.get('mac_framework_dirs', [])
+      for directory in framework_dirs:
+        cflags.append('-F' + directory.replace('$(SDKROOT)', sdk_root))
 
     self.configname = None
     return cflags
@@ -572,10 +580,11 @@ class XcodeSettings(object):
     for rpath in self._Settings().get('LD_RUNPATH_SEARCH_PATHS', []):
       ldflags.append('-Wl,-rpath,' + rpath)
 
-    config = self.spec['configurations'][self.configname]
-    framework_dirs = config.get('mac_framework_dirs', [])
-    for directory in framework_dirs:
-      ldflags.append('-F' + directory.replace('$(SDKROOT)', self._SdkPath()))
+    if 'SDKROOT' in self._Settings():
+      config = self.spec['configurations'][self.configname]
+      framework_dirs = config.get('mac_framework_dirs', [])
+      for directory in framework_dirs:
+        ldflags.append('-F' + directory.replace('$(SDKROOT)', self._SdkPath()))
 
     self.configname = None
     return ldflags
@@ -700,7 +709,10 @@ class XcodeSettings(object):
         l = '-l' + m.group(1)
       else:
         l = library
-    return l.replace('$(SDKROOT)', self._SdkPath())
+    if self._SdkPath():
+      return l.replace('$(SDKROOT)', self._SdkPath())
+    else:
+      return l
 
   def AdjustLibraries(self, libraries):
     """Transforms entries like 'Cocoa.framework' in libraries into entries like
