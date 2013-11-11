require 'formula'

class Apachetop < Formula
  homepage 'http://freecode.com/projects/apachetop'
  url 'http://www.webta.org/apachetop/apachetop-0.12.6.tar.gz'
  sha1 '005c9479800a418ee7febe5027478ca8cbf3c51b'

  # Upstream hasn't had activity in years, patch from MacPorts
  def patches; { :p0 => DATA }; end

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--disable-debug",
                          "--disable-dependency-tracking",
                          "--with-logfile=/var/log/apache2/access_log"
    system "make install"
  end
end

__END__
--- src/resolver.h    2005-10-15 18:10:01.000000000 +0200
+++ src/resolver.h        2007-02-17 11:24:37.000000000 
0100
@@ -10,8 +10,8 @@
 class Resolver
 {
 	public:
-	Resolver::Resolver(void);
-	Resolver::~Resolver(void);
+	Resolver(void);
+	~Resolver(void);
 	int add_request(char *request, enum resolver_action act);
 
 
