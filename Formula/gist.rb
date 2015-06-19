require "formula"

class Gist < Formula
  desc "Command-line utility for uploading Gists"
  homepage "https://github.com/defunkt/gist"
  url "https://github.com/defunkt/gist/archive/v4.3.0.tar.gz"
  sha1 "7eceb93d4d5f43da32201607409ee3aa196dcf7f"
  head "https://github.com/defunkt/gist.git"

  # rake wasn't shipped with Ruby back in 1.8.2
  depends_on :macos => :leopard

  def install
    rake "install", "prefix=#{prefix}"
  end

  test do
    system "#{bin}/gist", "--version"
  end
end
