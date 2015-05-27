require "language/haskell"

class PandocCiteproc < Formula
  include Language::Haskell::Cabal

  homepage "https://github.com/jgm/pandoc-citeproc"
  url "https://github.com/jgm/pandoc-citeproc/archive/0.7.0.1.tar.gz"
  sha256 "f672af320b808706657dcf578f4beef1b410cab744eab0707213e76687bd7a07"

  revision 1

  bottle do
    sha256 "304c122d67adbcff13fd7fb43852234c9138983d931c45b53bf6ab0160b16a98" => :yosemite
    sha256 "72e0a53626551fd9f889879b86903c8b2775e3f688f57889bb09a1d7f62abdc6" => :mavericks
    sha256 "441ca80c3bf92cc1b6416e796fc64b57eabe122619c96a944dd6029dade3541c" => :mountain_lion
  end

  depends_on "ghc" => :build
  depends_on "cabal-install" => :build
  depends_on "pandoc"

  def install
    cabal_sandbox do
      cabal_install "--only-dependencies"
      cabal_install "--prefix=#{prefix}"
    end
    cabal_clean_lib
  end

  test do
    bib = testpath/"test.bib"
    bib.write <<-EOS.undent
      @Book{item1,
      author="John Doe",
      title="First Book",
      year="2005",
      address="Cambridge",
      publisher="Cambridge University Press"
      }
    EOS
    system "pandoc-citeproc", "--bib2yaml", bib
  end
end
