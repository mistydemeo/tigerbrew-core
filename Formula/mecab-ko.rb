class MecabKo < Formula
  desc "See mecab"
  homepage "https://bitbucket.org/eunjeon/mecab-ko"
  url "https://bitbucket.org/eunjeon/mecab-ko/downloads/mecab-0.996-ko-0.9.2.tar.gz"
  version "0.996-ko-0.9.2"
  sha256 "d0e0f696fc33c2183307d4eb87ec3b17845f90b81bf843bd0981e574ee3c38cb"

  def install
    # https://bitbucket.org/eunjeon/mecab-ko/pull-request/1/mecab-ko-ipadic-ipadic/diff
    # Upstream decided not to comment out the dicdir path but replaced 'ipadic'
    # with 'mecab-ko-dic' instead in mecabrc file. Though the change resolves
    # the error of mecab-ko-dic path by source installation, it still doesn't
    # fit with Homebrew as it's expected installed under /usr/local/ with
    # mecab-ko-dic regardless of version.
    inreplace "mecabrc.in",
      "@prefix@/lib/mecab/dic/mecab-ko-dic",
      Formula["mecab-ko-dic"].opt_prefix

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
