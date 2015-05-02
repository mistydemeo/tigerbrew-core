require 'formula'

class Serd < Formula
  homepage 'http://drobilla.net/software/serd/'
  url 'http://download.drobilla.net/serd-0.20.0.tar.bz2'
  sha1 '38c0c8600270e38d99bc87b0ceb14b25c4c0cea3'

  bottle do
    cellar :any
    sha256 "fa5c347c7566b07e48821dd8b55c253c2ee681a0fb98ca392652757dece2b9b1" => :yosemite
    sha256 "abc4c507232fa581114ee241f95f5c3aede518b2edcf7d7ff41e33f8c7ad25a7" => :mavericks
    sha256 "ef544a7dab5f355717e72587bb66bc99c2b5c48f05a2e34f2523849c4bad3526" => :mountain_lion
  end

  depends_on 'pkg-config' => :build

  def install
    system "./waf", "configure", "--prefix=#{prefix}"
    system "./waf"
    system "./waf", "install"
  end
end
