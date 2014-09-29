require "formula"

class Newlisp < Formula
  homepage "http://www.newlisp.org/"
  url "http://www.newlisp.org/downloads/newlisp-10.6.0.tgz"
  sha1 "0f5ce581d070ff171cbef504308e578885aa5e72"

  devel do
    url "http://www.newlisp.org/downloads/development/newlisp-10.6.1.tgz"
    sha1 "6f7d06df961022f4319b0ea7227480847e221cb0"
  end

  depends_on "readline"

  patch :DATA

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

  test do
    path = testpath/"test.lsp"
    path.write <<-EOS
      (println "hello")
      (exit 0)
    EOS

    assert_equal "hello\n", shell_output("#{bin}/newlisp #{path}")
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
@@ -157,7 +157,7 @@
 			(write-file file (base64-dec text)))
 		(if (= ostype "Win32")
 			(catch (exec (string {newlisp.exe "} currentScriptFile {" } file " > " (string file "out"))) 'result)
-			(catch (exec (string "/usr/bin/newlisp " currentScriptFile " " file)) 'result)
+			(catch (exec (string "/usr/local/bin/newlisp " currentScriptFile " " file)) 'result)
 		)
 		(if (list? result)
 			(begin
@@ -225,7 +225,7 @@
 		(gs:run-shell 'OutputArea 
 			(string newlispDir "/newlisp.exe") (string currentExtension " -C -w \"" $HOME "\""))
 		(gs:run-shell 'OutputArea 
-			(string "/usr/bin/newlisp") (string currentExtension " -C -w " $HOME))
+			(string "/usr/local/bin/newlisp") (string currentExtension " -C -w " $HOME))
 	)
 )
 
