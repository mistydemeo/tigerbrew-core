require 'formula'

class Web100clt < Formula
  homepage 'http://www.internet2.edu/performance/ndt/'
  url 'http://software.internet2.edu/sources/ndt/ndt-3.6.5.2.tar.gz'
  sha1 '533a7dbb1b660a0148a0e295b481f63ab9ecb8f7'

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"

    # we only want to build the web100clt client so we need
    # to change to the src directory before installing.
    cd 'src' do
      system "make install"
    end

    cd 'doc' do
      man1.install 'web100clt.man' => 'web100clt.1'
    end
  end

  def test
    system "#{bin}/web100clt", "-v"
  end
end
