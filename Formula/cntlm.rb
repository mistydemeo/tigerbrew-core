require 'formula'

class Cntlm < Formula
  homepage 'http://cntlm.sourceforge.net/'
  url 'http://downloads.sourceforge.net/project/cntlm/cntlm/cntlm%200.92.3/cntlm-0.92.3.tar.bz2'
  sha1 '9b68a687218dd202c04b678ba8c559edba6f6f7b'

  def install
    system "./configure"
    system "make", "CC=#{ENV.cc}", "SYSCONFDIR=#{etc}"
    # install target fails - @adamv
    bin.install "cntlm"
    man1.install "doc/cntlm.1"
    etc.install "doc/cntlm.conf"
  end

  def caveats
    "Edit #{etc}/cntlm.conf to configure Cntlm"
  end
end
