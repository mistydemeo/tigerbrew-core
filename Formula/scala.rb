require 'formula'

class Scala < Formula
  homepage 'http://www.scala-lang.org/'
  url 'http://www.scala-lang.org/files/archive/scala-2.10.3.tgz'
  sha1 '04cd6237f164940e1e993a127e7cb21297f3b7ae'

  devel do
    url 'http://www.scala-lang.org/files/archive/scala-2.11.0-M4.tgz'
    sha1 '43e0983cebe75154e41a6b35a5b82bdc5bdbbaa2'
    version '2.11.0-M4'

    resource 'docs' do
      url 'http://www.scala-lang.org/files/archive/scala-docs-2.11.0-M4.zip'
      sha1 '24be02960fda935ab8d5a67b902147af3c95ced4'
      version '2.11.0-M4'
    end
  end

  option 'with-docs', 'Also install library documentation'

  resource 'docs' do
    url 'http://www.scala-lang.org/files/archive/scala-docs-2.10.3.zip'
    sha1 '43bab3ceb8215dad9caefb07eac5c24edc36c605'
  end

  resource 'completion' do
    url 'https://raw.github.com/scala/scala-dist/27bc0c25145a83691e3678c7dda602e765e13413/completion.d/2.9.1/scala'
    sha1 'e2fd99fe31a9fb687a2deaf049265c605692c997'
    version '2.9.1'
  end

  def install
    rm_f Dir["bin/*.bat"]
    doc.install Dir['doc/*']
    man1.install Dir['man/man1/*']
    libexec.install Dir['*']
    bin.install_symlink Dir["#{libexec}/bin/*"]

    bash_completion.install resource('completion')

    if build.with? 'docs'
      branch = build.stable? ? 'scala-2.10' : 'scala-2.11'
      (share/'doc'/branch).install resource('docs')
    end

    # Set up an IntelliJ compatible symlink farm in 'idea'
    idea = prefix/'idea'
    idea.install_symlink libexec/'src', libexec/'lib'
    (idea/'doc/scala-devel-docs').install_symlink doc => 'api'
  end

  def caveats; <<-EOS.undent
    To use with IntelliJ, set the Scala home to:
      #{opt_prefix}/idea
    EOS
  end
end
