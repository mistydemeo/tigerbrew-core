require "formula"

class Nvm < Formula
  homepage "https://github.com/creationix/nvm"
  head "https://github.com/creationix/nvm.git"
  url "https://github.com/creationix/nvm/archive/v0.10.0.tar.gz"
  sha1 "8d456f01e6bbb3bd25cb2124776b0320b6c5f707"

  def install
    prefix.install "nvm.sh"
    bash_completion.install "bash_completion" => "nvm"
  end

  def caveats; <<-EOS.undent
      Add the following to $HOME/.bashrc, $HOME/.zshrc, or your shell's
      equivalent configuration file:

        source $(brew --prefix nvm)/nvm.sh

      Node installs will be lost upon upgrading nvm. Add the following above
      the source line to move install location and prevent this:

        export NVM_DIR=~/.nvm

      Type `nvm help` for further information.
    EOS
  end
end
