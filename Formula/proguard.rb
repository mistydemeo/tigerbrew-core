class Proguard < Formula
  homepage "http://proguard.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/proguard/proguard/5.2/proguard5.2.1.tar.gz"
  sha256 "162fb2816212c6a7a195884a01ff826920919e97f57914a5b00bdf7641fc00f6"

  def install
    libexec.install "lib/proguard.jar"
    bin.write_jar_script libexec/"proguard.jar", "proguard"
  end

  test do
    expect = <<-EOS.undent
      ProGuard, version #{version}
      Usage: java proguard.ProGuard [options ...]
    EOS
    assert_equal expect, shell_output("#{bin}/proguard", 1)
  end
end
