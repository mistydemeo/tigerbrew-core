require 'formula'

class PkgConfig < Formula
  homepage 'http://pkgconfig.freedesktop.org'
  url 'http://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz'
  mirror 'http://fossies.org/unix/privat/pkg-config-0.28.tar.gz'
  sha256 '6b6eb31c6ec4421174578652c7e141fdaae2dabad1021f420d8713206ac1f845'

  bottle do
    revision 2
    sha1 '809937fdb5faaa3170f0abfc810ff244207d8975' => :mavericks
    sha1 'a0cbbdbe64aa3ffe665f674d68db8fb6fb84f7df' => :mountain_lion
    sha1 '44ec3ac051189dcd1e782cb7175979812f018e97' => :lion
  end

  def install
    paths = %W[
        #{HOMEBREW_PREFIX}/lib/pkgconfig
        #{HOMEBREW_PREFIX}/share/pkgconfig
        /usr/local/lib/pkgconfig
        /usr/lib/pkgconfig
        #{HOMEBREW_LIBRARY}/ENV/pkgconfig/#{MacOS.version}
      ].uniq

    args = %W[
        --disable-debug
        --prefix=#{prefix}
        --disable-host-tool
        --with-internal-glib
        --with-pc-path=#{paths*':'}
      ]
    args << "CC=#{ENV.cc} #{ENV.cflags}" unless MacOS::CLT.installed?

    system "./configure", *args

    system "make"
    system "make check"
    system "make install"
  end
end
