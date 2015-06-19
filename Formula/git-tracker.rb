require 'formula'

class GitTracker < Formula
  desc "Integrate Pivotal Tracker into git use"
  homepage 'https://github.com/stevenharman/git_tracker'
  url 'https://github.com/stevenharman/git_tracker/archive/v1.6.3.tar.gz'
  sha1 'c748e564f176165dba2498637e0b99f27647b88a'

  head 'https://github.com/stevenharman/git_tracker.git'

  # rake wasn't shipped with Ruby back in 1.8.2
  depends_on :macos => :leopard

  def install
    rake 'standalone:install', "prefix=#{prefix}"
  end

  test do
    output = shell_output("#{bin}/git-tracker help")
    assert_match /git-tracker \d+(\.\d+)* is installed\./, output
  end
end
