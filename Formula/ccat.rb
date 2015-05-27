class Ccat < Formula
  homepage "https://github.com/jingweno/ccat"
  url "https://github.com/jingweno/ccat/archive/v0.1.0.tar.gz"
  sha256 "437c7582ab39c8a1fb5e97ae9569e0096c98209a2ebb11ca67a7f9246b129c7c"

  bottle do
    cellar :any
    sha256 "de19c851b70ac557dc9c3f2a9adfabd9ed3188a6f11a5d9b2f713d9622370dda" => :yosemite
    sha256 "ea0549911b2fefd072b42d04e437063c653be7a7d26b57b125fc3807055127bc" => :mavericks
    sha256 "737d28a8532177a0a9e3819a28689000826dc4ba854388d90770baaba5c080b5" => :mountain_lion
  end

  depends_on "go" => :build

  def install
    system "./script/build"
    bin.install "ccat"
  end

  test do
    (testpath/"test.txt").write <<-EOS.undent
      I am a colourful cat
    EOS

    assert_match(/I am a colourful cat/, shell_output("#{bin}/ccat test.txt"))
  end
end
