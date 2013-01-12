require 'formula'

class RbenvGemset < Formula
  url 'https://github.com/jamis/rbenv-gemset/tarball/v0.3.0'
  homepage 'https://github.com/jamis/rbenv-gemset'
  sha1 '52e058e43a4a1395c3fe923365cee53d0977c41a'

  head 'https://github.com/jamis/rbenv-gemset.git'

  depends_on 'rbenv'

  def install
    prefix.install Dir['*']

    ln_sf opt_prefix, "#{HOMEBREW_PREFIX}/var/lib/rbenv/plugins/#{name}"
  end
end
