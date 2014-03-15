require 'formula'

class Iodine < Formula
  homepage 'http://code.kryo.se/iodine/'
  url 'http://code.kryo.se/iodine/iodine-0.6.0-rc1.tar.gz'
  sha1 '4fa9a248b8a84df8a727a5d749e669e58136edca'

  # 10.8 compatibility; see https://github.com/yarrick/iodine/pull/1
  patch do
    url "https://github.com/zschoche/iodine/commit/e1e438497a83dbe6800212a0e5cb632907d1b3d9.patch"
    sha1 "207140143903db61c78ca1dcdc807ac2314b5aff"
  end

  def install
    system "make", "install", "prefix=#{prefix}"
  end
end
