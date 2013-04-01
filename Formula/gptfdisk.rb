require 'formula'

class Gptfdisk < Formula
  homepage 'http://www.rodsbooks.com/gdisk/'
  url 'http://sourceforge.net/projects/gptfdisk/files/gptfdisk/0.8.6/gptfdisk-0.8.6.tar.gz'
  sha1 '87dc5704b19173c7536c7fa991912a81e69c5020'

  depends_on 'popt'
  depends_on 'icu4c'

  def install
    system "make -f Makefile.mac"
    sbin.install ['gdisk','cgdisk','sgdisk','fixparts']
    man8.install ['gdisk.8','cgdisk.8','sgdisk.8','fixparts.8']
  end

  test do
    IO.popen("#{sbin}/gdisk", "w+") do |pipe|
      pipe.write("\n")
      /GPT fdisk \(gdisk\) version #{Regexp.escape(version)}/ === pipe.read
    end
  end
end
