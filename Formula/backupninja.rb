require 'formula'

class Backupninja < Formula
  homepage 'https://labs.riseup.net/code/projects/backupninja'
  url 'https://labs.riseup.net/code/attachments/download/275/backupninja-1.0.1.tar.gz'
  sha1 'c9b2cef3c289b2b71cc8fd33f8e089a70a11affb'

  head 'git://labs.riseup.net/backupninja.git'

  depends_on "dialog"
  depends_on "gawk"

  skip_clean 'etc/backup.d'
  skip_clean 'var/log'

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make install"
  end
end
