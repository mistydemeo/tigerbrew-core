require 'formula'

class Elinks < Formula
  homepage 'http://elinks.or.cz/'
  url 'http://elinks.or.cz/download/elinks-0.11.7.tar.bz2'
  sha1 'd13edc1477d0ab32cafe7d3c1f3a23ae1c0a5c54'

  bottle do
    sha1 "39f17a4cf868e624e06f8ce47f721d8f285dfa93" => :mavericks
    sha1 "be7964dc848562b50736eec0f91dc0047fd14bfd" => :mountain_lion
    sha1 "0b32cf3d3836be61385e1598cae07a08bc39f5f4" => :lion
  end

  devel do
    url 'http://elinks.cz/download/elinks-0.12pre6.tar.bz2'
    version '0.12pre6'
    sha1 '3517795e8a390cb36ca249a5be6514b9784520a5'
  end

  head do
    url 'http://elinks.cz/elinks.git'

    depends_on :autoconf
    depends_on :automake
    depends_on :libtool
  end

  def install
    ENV.deparallelize
    ENV.delete('LD')
    system "./autogen.sh" if build.head?
    system "./configure", "--prefix=#{prefix}", "--without-spidermonkey",
                          "--enable-256-colors"
    system "make install"
  end

  test do
    (testpath/"test.html").write <<-EOS.undent
      <!DOCTYPE html>
      <title>elinks test</title>
      Hello world!
      <ol><li>one</li><li>two</li></ol>
    EOS
    assert_match /^\s*Hello world!\n+ *1. one\n *2. two\s*$/, `elinks test.html`
  end
end
