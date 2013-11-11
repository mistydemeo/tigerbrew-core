require 'formula'

class Jsawk < Formula
  homepage 'https://github.com/micha/jsawk'
  url 'https://github.com/micha/jsawk/archive/1.4.tar.gz'
  sha1 '4f2c962c8a5209764116457682985854400cbf24'

  head 'https://github.com/micha/jsawk.git'

  depends_on 'spidermonkey'

  def install
    mv "README.markdown", "README"
    bin.install "jsawk"
  end
end
