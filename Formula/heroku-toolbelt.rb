require 'formula'

class Ruby19 < Requirement
  fatal true
  default_formula 'ruby'

  satisfy :build_env => false do
    next unless which 'ruby'
    version = /\d\.\d/.match `ruby --version 2>&1`

    next unless version
    Version.new(version.to_s) >= Version.new("1.9")
  end

  def modify_build_environment
    ruby = which "ruby"
    return unless ruby

    ENV.prepend_path "PATH", ruby.dirname
  end

  def message; <<-EOS.undent
    The Heroku Toolbelt requires Ruby >= 1.9
    EOS
  end
end

class HerokuToolbelt < Formula
  homepage 'https://toolbelt.heroku.com/other'
  url 'http://assets.heroku.com.s3.amazonaws.com/heroku-client/heroku-client-3.9.6.tgz'
  sha1 'c198322c1cc25bc6b97a0fcef9897e5137c1aa6c'

  depends_on Ruby19

  def install
    inreplace 'bin/heroku', '/usr/bin/env ruby', Formula['ruby'].opt_bin/'ruby'
    libexec.install Dir["*"]
    bin.write_exec_script libexec/"bin/heroku"
  end

  test do
    system "#{bin}/heroku", "version"
  end

  def caveats; <<-EOS.undent
    heroku-toolbelt requires an installation of Ruby 1.9 or greater.
    EOS
  end
end
