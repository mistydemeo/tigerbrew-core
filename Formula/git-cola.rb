require 'formula'

class GitCola < Formula
  homepage 'http://git-cola.github.io/'
  url 'https://github.com/git-cola/git-cola/archive/v1.8.3.tar.gz'
  sha1 '22c3376c26d642ec94a0ae2481b08a49cd6b41e0'

  head 'https://github.com/git-cola/git-cola.git'

  option 'with-docs', "Build man pages using asciidoc and xmlto"

  depends_on :python
  depends_on 'pyqt'

  if build.include? 'with-docs'
    # these are needed to build man pages
    depends_on 'asciidoc'
    depends_on 'xmlto'
  end

  def install
    python do
      # The python do block creates the PYTHONPATH and temp. site-packages
      system "make", "prefix=#{prefix}", "install"

      if build.include? 'with-docs'
        system "make", "-C", "share/doc/git-cola",
                       "-f", "Makefile.asciidoc",
                       "prefix=#{prefix}",
                       "install", "install-html"
      end
    end
  end

end
