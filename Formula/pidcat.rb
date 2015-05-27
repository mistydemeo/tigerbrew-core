require "formula"

class Pidcat < Formula
  homepage "https://github.com/JakeWharton/pidcat"
  head "https://github.com/JakeWharton/pidcat.git"
  url "https://github.com/JakeWharton/pidcat/archive/2.0.0.tar.gz"
  sha256 "4bb3d7bab7e124e355892ee9cf87de1d6f39bea201b03fce6449ca2486470656"

  def install
    bin.install "pidcat.py" => "pidcat"
  end

  test do
    assert_match /^usage: pidcat/, shell_output("#{bin}/pidcat --help").strip
  end
end
