class Galen < Formula
  homepage "http://galenframework.com/"
  url "https://github.com/galenframework/galen/releases/download/galen-1.6.3/galen-bin-1.6.3.zip"
  sha256 "efd7cac3c6aed1f8630dbfa2ee51069c1d7551df457036c600d93fbc3f9c6ebf"

  bottle do
    cellar :any
    sha256 "e7bb986e7077068b4864fc0136087793f6d3daa49821dc1a059946183d777463" => :yosemite
    sha256 "60137c10b0433fbc729d2590fa2da15f1ddd3ee7cca6ee8ca4d216aa9e40a6a8" => :mavericks
    sha256 "2c7d23e72734ca6387ee784539bc3458ad224b1cce4fa7f9d9539bf80981449f" => :mountain_lion
  end

  depends_on :java => "1.6+"

  def install
    libexec.install "galen.jar"
    (bin/"galen").write <<-EOS.undent
      #!/bin/sh
      set -e
      java -cp "#{libexec}/galen.jar:lib/*:libs/*" net.mindengine.galen.GalenMain "$@"
    EOS
  end

  test do
    assert_match "Version: #{version}", shell_output("#{bin}/galen -v")
  end
end
