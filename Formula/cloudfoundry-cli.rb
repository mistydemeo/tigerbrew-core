require 'formula'

class CloudfoundryCli < Formula
  homepage 'https://github.com/cloudfoundry/cli'
  head 'https://github.com/cloudfoundry/cli.git', :branch => 'master'
  url 'https://github.com/cloudfoundry/cli.git', :tag => 'v6.0.0'

  depends_on 'go' => :build

  def install
    inreplace 'src/cf/app_constants.go', 'SHA', 'homebrew'
    system 'bin/build'
    bin.install 'out/cf'
    doc.install 'LICENSE'
  end

  test do
    system "#{bin}/cf"
  end
end
