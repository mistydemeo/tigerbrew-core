require 'formula'

class Multimarkdown < Formula
  homepage 'http://fletcherpenney.net/multimarkdown/'
  head 'https://github.com/fletcher/MultiMarkdown-4.git', :branch => 'master'
  # Use git tag instead of the tarball to get submodules
  url 'https://github.com/fletcher/MultiMarkdown-4.git', :tag => '4.5'

  conflicts_with 'mtools', :because => 'both install `mmd` binaries'

  def install
    ENV.append 'CFLAGS', '-g -O3 -include GLibFacade.h'
    system "make"
    bin.install 'multimarkdown', Dir['scripts/*']
    prefix.install 'Support'
  end

  def caveats; <<-EOS.undent
    Support files have been installed to:
      #{opt_prefix}/Support
    EOS
  end
end
