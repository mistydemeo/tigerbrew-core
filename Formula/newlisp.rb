require 'formula'

class Newlisp < Formula
  homepage 'http://www.newlisp.org/'
  url 'http://www.newlisp.org/downloads/newlisp-10.5.0.tgz'
  sha1 '647aa86af6edce30402da260fe7f3ea7d03a91f1'

  depends_on 'readline'

  def install
    # Required to use our configuration
    ENV.append_to_cflags "-DNEWCONFIG -c"

    system "./configure-alt", "--prefix=#{prefix}", "--mandir=#{man}"
    system "make"
    system "make check"
    system "make install"
  end

  def caveats; <<-EOS.undent
    If you have brew in a custom prefix, the included examples
    will need to be be pointed to your newlisp executable.
    EOS
  end

  def patches
    DATA
  end

  # Use the IDE to test a complete installation
  def test
    system "#{bin}/newlisp-edit"
  end
end

__END__

--- a/guiserver/newlisp-edit.lsp
+++ b/Users/gordy/tmp/newlisp-edit
@@ -1,4 +1,4 @@
-#!/usr/bin/newlisp
+#!/usr/bin/env newlisp
 
 ; newlisp-edit.lsp - multiple tab LISP editor and support for running code from the editor
 ; needs 9.9.2 version minimum to run
@@ -155,7 +155,7 @@
 			(write-file file (base64-dec text)))
 		(if (= ostype "Win32")
 			(catch (exec (string {newlisp.exe "} currentScriptFile {" } file " > " (string file "out"))) 'result)
-			(catch (exec (string "/usr/bin/newlisp " currentScriptFile " " file)) 'result)
+			(catch (exec (string "/usr/local/bin/newlisp " currentScriptFile " " file)) 'result)
 		)
 		(if (list? result)
 			(begin
@@ -223,7 +223,7 @@
 		(gs:run-shell 'OutputArea 
 			(string newlispDir "/newlisp.exe " currentExtension " -C -w \"" $HOME "\""))
 		(gs:run-shell 'OutputArea 
-			(string "/usr/bin/newlisp " currentExtension " -C -w " $HOME))
+			(string "/usr/local/bin/newlisp " currentExtension " -C -w " $HOME))
 	)
 )
 
