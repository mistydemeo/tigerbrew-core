require "formula"

class Docker < Formula
  homepage "http://docker.io"
  url "https://github.com/dotcloud/docker.git", :tag => "v1.0.0"

  bottle do
    sha1 "ff9ca100ffcbf521cc4abad2a6a6a9569dd5a52b" => :mavericks
    sha1 "ec28d7907015be6898bbfee7c8c85b6ee030c6e1" => :mountain_lion
    sha1 "b9621863233b248d3efe059dcca271ed1769ada6" => :lion
  end

  option "without-completions", "Disable bash/zsh completions"

  depends_on "go" => :build

  def install
    ENV["GIT_DIR"] = cached_download/".git"
    ENV["AUTO_GOPATH"] = "1"
    ENV["DOCKER_CLIENTONLY"] = "1"
    ENV["CGO_ENABLED"] = "0"

    system "hack/make.sh", "dynbinary"
    bin.install "bundles/#{version}/dynbinary/docker-#{version}" => "docker"

    if build.with? "completions"
      bash_completion.install "contrib/completion/bash/docker"
      zsh_completion.install "contrib/completion/zsh/_docker"
    end
  end

  test do
    system "#{bin}/docker", "--version"
  end
end
