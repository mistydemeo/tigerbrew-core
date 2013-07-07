require 'formula'

class ScalaDocs < Formula
  homepage 'http://www.scala-lang.org/'
  url 'http://www.scala-lang.org/downloads/distrib/files/scala-docs-2.10.2.zip'
  sha1 '96107dafb44af30d24c07fc29feddbf470377cdd'

  devel do
    url 'http://www.scala-lang.org/downloads/distrib/files/scala-docs-2.11.0-M3.zip'
    sha1 '5c81f366ae6d1b471ef4e3ead3ad602d535a5ac1'
  end
end

class ScalaCompletion < Formula
  homepage 'http://www.scala-lang.org/'
  url 'https://raw.github.com/scala/scala-dist/27bc0c25145a83691e3678c7dda602e765e13413/completion.d/2.9.1/scala'
  version '2.9.1'
  sha1 'e2fd99fe31a9fb687a2deaf049265c605692c997'
end

class Scala < Formula
  homepage 'http://www.scala-lang.org/'
  url 'http://www.scala-lang.org/downloads/distrib/files/scala-2.10.2.tgz'
  sha1 '86b4e38703d511ccf045e261a0e04f6e59e3c926'

  devel do
    url 'http://www.scala-lang.org/downloads/distrib/files/scala-2.11.0-M3.tgz'
    sha1 '928a5c52f36b2189a8619580f2b9ac157749a968'
  end

  option 'with-docs', 'Also install library documentation'

  def install
    rm_f Dir["bin/*.bat"]
    doc.install Dir['doc/*']
    man1.install Dir['man/man1/*']
    libexec.install Dir['*']
    bin.install_symlink Dir["#{libexec}/bin/*"]
    ScalaCompletion.new.brew { bash_completion.install 'scala' }
    ScalaDocs.new.brew do
      branch = build.stable? ? 'scala-2.10' : 'scala-2.11'
      (share/'doc'/branch).install Dir['*']
    end if build.include? 'with-docs'
  end
end
