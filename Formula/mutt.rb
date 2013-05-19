require 'formula'

class Mutt < Formula
  homepage 'http://www.mutt.org/'
  url 'ftp://ftp.mutt.org/mutt/devel/mutt-1.5.21.tar.gz'
  sha1 'a8475f2618ce5d5d33bff85c0affdf21ab1d76b9'

  option "with-debug", "Build with debug option enabled"
  option "with-sidebar-patch", "Apply sidebar (folder list) patch"
  option "with-trash-patch", "Apply trash folder patch"
  option "with-slang", "Build against slang instead of ncurses"
  option "with-ignore-thread-patch", "Apply ignore-thread patch"
  option "with-pgp-verbose-mime-patch", "Apply PGP verbose mime patch"

  depends_on 'tokyo-cabinet'
  depends_on 'slang' if build.include? 'with-slang'

  def patches
    urls = [
      ['with-sidebar-patch', 'http://lunar-linux.org/~tchan/mutt/patch-1.5.21.sidebar.20130219.txt'],
      ['with-trash-patch', 'http://patch-tracker.debian.org/patch/series/dl/mutt/1.5.21-6.2/features/trash-folder'],
      # original source for this went missing, patch sourced from Arch at
      # https://aur.archlinux.org/packages/mutt-ignore-thread/
      ['with-ignore-thread-patch', 'https://gist.github.com/mistydemeo/5522742/raw/1439cc157ab673dc8061784829eea267cd736624/ignore-thread-1.5.21.patch'],
      ['with-pgp-verbose-mime-patch',
          'http://patch-tracker.debian.org/patch/series/dl/mutt/1.5.21-6.2/features-old/patch-1.5.4.vk.pgp_verbose_mime'],
    ]

    if build.include? "with-ignore-thread-patch" and build.include? "with-sidebar-patch"
      puts "\n"
      onoe "The ignore-thread-patch and sidebar-patch options are mutually exlusive. Please pick one"
      exit 1
    end

    p = []
    urls.each do |u|
      p << u[1] if build.include? u[0]
    end

    return p
  end

  def install
    args = ["--disable-dependency-tracking",
            "--disable-warnings",
            "--prefix=#{prefix}",
            "--with-ssl",
            "--with-sasl",
            "--with-gss",
            "--enable-imap",
            "--enable-smtp",
            "--enable-pop",
            "--enable-hcache",
            "--with-tokyocabinet",
            # This is just a trick to keep 'make install' from trying to chgrp
            # the mutt_dotlock file (which we can't do if we're running as an
            # unpriviledged user)
            "--with-homespool=.mbox"]
    args << "--with-slang" if build.include? 'with-slang'

    if build.include? 'with-debug'
      args << "--enable-debug"
    else
      args << "--disable-debug"
    end

    system "./configure", *args
    system "make install"
  end
end
