require 'formula'

class Xpdf < Formula
  homepage 'http://www.foolabs.com/xpdf/'
  url 'ftp://ftp.foolabs.com/pub/xpdf/xpdf-3.03.tar.gz'
  sha1 '499423e8a795e0efd76ca798239eb4d0d52fe248'

  depends_on 'lesstif'
  depends_on :x11

  conflicts_with 'pdf2image', 'poppler',
    :because => 'xpdf, pdf2image, and poppler install conflicting executables'

  # see: http://gnats.netbsd.org/45562
  patch :DATA

  def install
    ENV.append_to_cflags "-I#{MacOS::X11.include} -I#{MacOS::X11.include}/freetype2"
    ENV.append "LDFLAGS", "-L#{MacOS::X11.lib}"

    system "./configure", "--prefix=#{prefix}", "--mandir=#{man}"
    system "make"
    system "make install"
  end
end

__END__
diff --git a/xpdf/XPDFViewer.cc b/xpdf/XPDFViewer.cc
index 2de349d..e6ef7fa 100644
--- a/xpdf/XPDFViewer.cc
+++ b/xpdf/XPDFViewer.cc
@@ -1803,7 +1803,7 @@ void XPDFViewer::initToolbar(Widget parent) {
   menuPane = XmCreatePulldownMenu(toolBar, "zoomMenuPane", args, n);
   for (i = 0; i < nZoomMenuItems; ++i) {
     n = 0;
-    s = XmStringCreateLocalized(zoomMenuInfo[i].label);
+    s = XmStringCreateLocalized((char *)zoomMenuInfo[i].label);
     XtSetArg(args[n], XmNlabelString, s); ++n;
     XtSetArg(args[n], XmNuserData, (XtPointer)i); ++n;
     sprintf(buf, "zoom%d", i);
