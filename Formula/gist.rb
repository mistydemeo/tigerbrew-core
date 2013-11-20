require 'formula'

class Gist < Formula
  homepage 'https://github.com/defunkt/gist'
  url 'https://github.com/defunkt/gist/archive/v4.1.3.tar.gz'
  sha1 '592afe5f45f476f2d9129bcd250892c884c3664d'
  head 'https://github.com/defunkt/gist.git'

  # rake wasn't shipped with Ruby back in 1.8.2
  depends_on :macos => :leopard

  def install
    rake "install", "prefix=#{prefix}"
  end

  test do
    system "#{bin}/gist", '--version'
  end
end
