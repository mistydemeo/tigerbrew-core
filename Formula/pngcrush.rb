require 'formula'

class Pngcrush < Formula
  homepage 'http://pmt.sourceforge.net/pngcrush/'
  # Stay at least one version behind and use the old-versions directory,
  # because tarballs are routinely removed and upstream won't change this
  # practice.
  url 'http://downloads.sourceforge.net/project/pmt/pngcrush/old-versions/1.7/1.7.60/pngcrush-1.7.60.tar.gz'
  sha1 'ada052647368eb542e00df2fa2dd120bee346725'

  def install
    # Required to successfully build the bundled zlib 1.2.6
    ENV.append_to_cflags "-DZ_SOLO"
    # Required to enable "-cc" (color counting) option (disabled by default since 1.5.1)
    ENV.append_to_cflags "-DPNGCRUSH_COUNT_COLORS"

    system "make", "CC=#{ENV.cc}",
                   "LD=#{ENV.cc}",
                   "CFLAGS=#{ENV.cflags}",
                   "LDFLAGS=#{ENV.ldflags}"
    bin.install 'pngcrush'
  end
end
