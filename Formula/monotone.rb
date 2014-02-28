require 'formula'

class Monotone < Formula
  homepage 'http://monotone.ca/'
  url 'http://www.monotone.ca/downloads/1.0/monotone-1.0.tar.bz2'
  sha1 'aac556bb26d92910b74b65450a0be6c5045e2052'

  depends_on 'pkg-config' => :build
  depends_on 'gettext'
  depends_on 'libidn'
  depends_on 'lua'
  depends_on 'pcre'

  # http://botan.randombit.net/
  resource 'botan' do
    url 'http://files.randombit.net/botan/v1.8/Botan-1.8.13.tbz'
    sha1 '66cda9e05001e4a298cbb0095b9a3f6d11c4ef53'
  end

  fails_with :llvm do
    build 2334
    cause "linker fails"
  end

  def install
    botan18_prefix = libexec+'botan18'
    resource('botan').stage do
      args = ["--prefix=#{botan18_prefix}"]
      args << "--cpu=#{Hardware::CPU.arch_64_bit}" if MacOS.prefer_64_bit?
      system "./configure.py", *args
      system "make", "CXX=#{ENV.cxx}", "install"
    end

    ENV['botan_CFLAGS'] = "-I#{botan18_prefix}/include"
    ENV['botan_LIBS'] = "-L#{botan18_prefix}/lib -lbotan"

    # Monotone only needs headers from Boost, so avoid building the libraries.
    # This is suggested in the Monotone installation instructions.

    boost_prefix = buildpath/'boost'
    boost = Formula['boost149']
    boost.brew do
      boost_prefix.install Dir['*']
      # Add header location to CPPFLAGS
      ENV.append 'CPPFLAGS', "-I#{boost_prefix}"
    end

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end
end
