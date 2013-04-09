require 'formula'

class Tmux < Formula
  homepage 'http://tmux.sourceforge.net'
  url 'http://sourceforge.net/projects/tmux/files/tmux/tmux-1.8/tmux-1.8.tar.gz'
  sha1 '08677ea914e1973ce605b0008919717184cbd033'

  head 'git://tmux.git.sourceforge.net/gitroot/tmux/tmux'

  depends_on 'pkg-config' => :build
  depends_on 'libevent'

  if build.head?
    depends_on :automake
    depends_on :libtool
  end

  def patches
    # Fixes installation failure on Snow Leopard
    # http://sourceforge.net/mailarchive/forum.php?thread_name=CAJfQvvc2QDU%3DtXWb-sc-NK0J8cgnDRMDod6CNKO1uYqu%3DY5CXg%40mail.gmail.com&forum_name=tmux-users
    DATA
  end

  def install
    system "sh", "autogen.sh" if build.head?

    ENV.append "LDFLAGS", '-lresolv'
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}"
    system "make install"

    (prefix+'etc/bash_completion.d').install "examples/bash_completion_tmux.sh" => 'tmux'
  end

  def test
    system "#{bin}/tmux", "-V"
  end
end

__END__
diff --git a/osdep-darwin.c b/osdep-darwin.c
index 23de9d5..b5efe84 100644
--- a/osdep-darwin.c
+++ b/osdep-darwin.c
@@ -33,17 +33,17 @@ struct event_base	*osdep_event_init(void);
 char *
 osdep_get_name(int fd, unused char *tty)
 {
-	struct proc_bsdshortinfo	bsdinfo;
+	struct proc_bsdinfo bsdinfo;
	pid_t				pgrp;
	int				ret;

	if ((pgrp = tcgetpgrp(fd)) == -1)
		return (NULL);

-	ret = proc_pidinfo(pgrp, PROC_PIDT_SHORTBSDINFO, 0,
+	ret = proc_pidinfo(pgrp, PROC_PIDTBSDINFO, 0,
	    &bsdinfo, sizeof bsdinfo);
-	if (ret == sizeof bsdinfo && *bsdinfo.pbsi_comm != '\0')
-		return (strdup(bsdinfo.pbsi_comm));
+	if (ret == sizeof bsdinfo && *bsdinfo.pbi_comm != '\0')
+		return (strdup(bsdinfo.pbi_comm));
	return (NULL);
 }
