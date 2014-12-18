require "formula"

# No head build supported; if you need head builds of Mercurial, do so outside
# of Homebrew.
class Mercurial < Formula
  homepage "http://mercurial.selenic.com/"
  url "http://mercurial.selenic.com/release/mercurial-3.2.2.tar.gz"
  sha1 "a8a51aa412abd5155c7de29fd39c9774decb4d3f"

  bottle do
    cellar :any
    sha1 "e1cb3bd4effe967a82b3067a8d02f6284220d754" => :yosemite
    sha1 "2074f826e0a883fcb811ab2fc6b192fb65c61a1d" => :mavericks
    sha1 "550f916069fdb3c89e96b772c387e12a2dcefa61" => :mountain_lion
  end

  def install
    ENV.minimal_optimization if MacOS.version <= :snow_leopard

    system "make", "PREFIX=#{prefix}", "install-bin"
    # Install man pages, which come pre-built in source releases
    man1.install "doc/hg.1"
    man5.install "doc/hgignore.5", "doc/hgrc.5"

    # install the completion scripts
    bash_completion.install "contrib/bash_completion" => "hg-completion.bash"
    zsh_completion.install "contrib/zsh_completion" => "_hg"

    # install the merge tool default configs
    # http://mercurial.selenic.com/wiki/Packaging#Things_to_note
    (etc/"mercurial"/"hgrc.d").install "contrib/mergetools.hgrc" => "mergetools.rc"
  end

  test do
    system "#{bin}/hg", "init"
  end
end
