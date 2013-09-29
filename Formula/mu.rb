require 'formula'

class Emacs23Installed < Requirement
  fatal true
  env :userpaths
  default_formula 'emacs'

  satisfy do
    `emacs --version 2>/dev/null` =~ /^GNU Emacs (\d{2})/
    $1.to_i >= 23
  end
end

class Mu < Formula
  homepage 'http://www.djcbsoftware.nl/code/mu/'
  url 'http://mu0.googlecode.com/files/mu-0.9.9.5.tar.gz'
  sha1 '825e3096e0763a12b8fdf77bd41625ee15ed09eb'

  head do
    url 'https://github.com/djcb/mu.git'

    depends_on 'automake' => :build
    depends_on 'libtool' => :build
  end

  option 'with-emacs', 'Build with emacs support'

  depends_on 'pkg-config' => :build
  depends_on 'gettext'
  depends_on 'glib'
  depends_on 'gmime'
  depends_on 'xapian'
  depends_on Emacs23Installed if build.with? 'emacs'

  env :std if build.with? 'emacs'

  def install
    # Explicitly tell the build not to include emacs support as the version
    # shipped by default with Mac OS X is too old.
    ENV['EMACS'] = 'no' unless build.with? 'emacs'

    system 'autoreconf', '-ivf' if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-gui=none"
    system "make"
    system "make install"
  end

  def caveats; <<-EOS.undent
    Existing mu users are recommended to run the following after upgrading:

      mu index --rebuild
    EOS
  end
end
