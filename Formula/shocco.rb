require 'formula'

# Include a private copy of this Python app
# so we don't have to worry about clashing dependencies.
class Pygments < Formula
  homepage 'http://pygments.org/'
  url 'http://pypi.python.org/packages/source/P/Pygments/Pygments-1.5.tar.gz'
  sha1 '4fbd937fd5cebc79fa4b26d4cce0868c4eec5ec5'
end

class MarkdownProvider < Requirement
  def message; <<-EOS.undent
    shocco requires a `markdown` command.

    You can satisfy this requirement with either of two formulae:
      brew install markdown
      brew install discount

    Please install one and try again.
    EOS
  end

  def satisfied?
    which 'markdown'
  end

  def fatal?
    true
  end
end

class Shocco < Formula
  homepage 'http://rtomayko.github.com/shocco/'
  url 'https://github.com/rtomayko/shocco/tarball/a1ee000613946335f54a8f236ee9fe6f7f22bcb8'
  sha1 '8feb66dad3c957fabdfa368e710dfb2a078a732f'

  depends_on MarkdownProvider.new

  def install
    Pygments.new.brew { libexec.install 'pygmentize','pygments' }

    # Brew along with Pygments
    system "./configure", "PYGMENTIZE=#{libexec}/pygmentize", "--prefix=#{prefix}"

    # Shocco's Makefile does not combine the make and make install steps.
    system "make"
    system "make install"
  end

  def caveats
    <<-EOS.undent
      You may also want to install browser:
        brew install browser
        shocco `which shocco` | browser
    EOS
  end
end
