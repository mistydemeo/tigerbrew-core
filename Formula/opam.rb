require 'formula'

class Opam < Formula
  homepage 'https://github.com/OCamlPro/opam'
  url 'https://github.com/OCamlPro/opam/archive/0.9.5.tar.gz'
  sha1 '73afb82f16052badd5c7eea0d24a01029ab21c67'

  head 'https://github.com/OCamlPro/opam.git'

  depends_on "objective-caml"

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make install"

    bash_completion.install "shell/opam_completion.sh"
    zsh_completion.install "shell/opam_completion_zsh.sh"
  end

  def test
    system "#{bin}/opam --help"
  end

  def caveats; <<-EOS.undent
    OPAM uses ~/.opam by default for its package database, so you need to
    initialize it first by running (as a normal user):

    $  opam init

    Run the following to initialize your environmnent variables:

    $  eval `opam config env`

    To export the needed variables every time, add them to your dotfiles.
      * On Bash, add them to `~/.bash_profile`.
      * On Zsh, add them to `~/.zprofile` instead.

    Documentation and tutorials are available at http://opam.ocamlpro.com, or
    via 'man opam' and 'opam --help'.
    EOS
  end
end
