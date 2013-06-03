require 'formula'

class Diffuse < Formula
  homepage 'http://diffuse.sourceforge.net/'
  url 'http://downloads.sourceforge.net/project/diffuse/diffuse/0.4.7/diffuse-0.4.7.tar.bz2'
  sha1 '9e3b906b579495027b76dc723b5df28e400d3f26'

  depends_on :python
  depends_on 'pygtk'

  def install
    python do
      system python, "./install.py",
                     "--sysconfdir=#{etc}",
                     "--examplesdir=#{share}",
                     "--prefix=#{prefix}"
    end
  end

  def test
    system "#{bin}/diffuse", "--help"
  end
end
