require 'formula'

class RakudoStar < Formula
  homepage 'http://rakudo.org/'
  url 'http://rakudo.org/downloads/star/rakudo-star-2013.05.tar.gz'
  sha256 '4eeb7116bf432a8c439fc0db53294364fa723ae32659f31547a62fa7cd2e3384'

  conflicts_with 'parrot'

  depends_on 'gmp' => :optional
  depends_on 'icu4c' => :optional
  depends_on 'pcre' => :optional
  depends_on 'libffi'

  def install
    libffi = Formula.factory("libffi")
    ENV.remove 'CPPFLAGS', "-I#{libffi.include}"
    ENV.prepend 'CPPFLAGS', "-I#{libffi.lib}/libffi-3.0.11/include"

    ENV.j1  # An intermittent race condition causes random build failures.
    system "perl", "Configure.pl", "--prefix=#{prefix}", "--gen-parrot"
    system "make"
    system "make install"
    # move the man pages out of the top level into share.
    mv "#{prefix}/man", share
  end
end
