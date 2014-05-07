require 'formula'

class Bigloo < Formula
  homepage 'http://www-sop.inria.fr/indes/fp/Bigloo/'
  url 'ftp://ftp-sop.inria.fr/indes/fp/Bigloo/bigloo4.0b.tar.gz'
  version '4.0b'
  sha1 '2c70863de59d1d92b63aee3f1ee2f39c6672e732'

  depends_on 'gmp' => :recommended

  option 'with-jvm', 'Enable JVM support'

  fails_with :clang do
    cause <<-EOS.undent
      objs/obj_u/Ieee/dtoa.c:262:79504: fatal error: parser
      recursion limit reached, program too complex
    EOS
  end

  def install
    args = ["--disable-debug",
            "--disable-dependency-tracking",
            "--prefix=#{prefix}",
            "--mandir=#{man1}",
            "--infodir=#{info}",
            "--customgc=yes",
            "--os-macosx",
            "--native=yes",
            "--disable-alsa",
            "--disable-mpg123",
            "--disable-flac"]

    args << "--jvm=yes" if build.with? 'jvm'
    args << "--no-gmp" if build.without? "gmp"

    # SRFI 27 is 32-bit only
    args << "--disable-srfi27" if MacOS.prefer_64_bit?

    system "./configure", *args

    system "make"
    system "make install"

    # Install the other manpages too
    manpages = %w( bgldepend bglmake bglpp bgltags bglafile bgljfile bglmco bglprof )
    manpages.each {|m| man1.install "manuals/#{m}.man" => "#{m}.1"}
  end
end
