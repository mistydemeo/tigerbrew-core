require 'formula'

class X264 < Formula
  homepage 'http://www.videolan.org/developers/x264.html'
  url 'http://download.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-20120812-2245-stable.tar.bz2'
  sha1 '4be913fb12cd5b3628edc68dedb4b6e664eeda0a'
  version 'r2197.4' # brew install -v --HEAD x264 will display the version.
  head 'http://git.videolan.org/git/x264.git', :branch => 'stable'

  bottle do
    cellar :any
    sha1 "ce6311ee8bb0ce64edd888bd9494b51ba4a91b46" => :mavericks
    sha1 "15f59b5c6965efd112cc7f6ecc4fcf76d0f1740a" => :mountain_lion
    sha1 "2667e3a601042682d9a1d4b7a9b69809b47c82e5" => :lion
  end

  # reports that ASM causes a crash on G3; works on G4
  depends_on 'yasm' => :build unless Hardware::CPU.family == :g3

  option '10-bit', 'Build a 10-bit x264 (default: 8-bit)'

  def install
    # https://github.com/Homebrew/homebrew/pull/19594
    ENV.deparallelize
    if build.head?
      ENV['GIT_DIR'] = cached_download/'.git'
      system './version.sh'
    end
    args = ["--prefix=#{prefix}", "--enable-shared"]
    args << "--bit-depth=10" if build.include? '10-bit'
    args << "--disable-asm" if Hardware::CPU.family == :g3

    system "./configure", *args

    if MacOS.prefer_64_bit?
      inreplace 'config.mak' do |s|
        soflags = s.get_make_var 'SOFLAGS'
        s.change_make_var! 'SOFLAGS', soflags.gsub(' -Wl,-read_only_relocs,suppress', '')
      end
    end

    system "make install"
  end

  def caveats; <<-EOS.undent
    Because libx264 has a rapidly-changing API, formulae that link against
    it should be reinstalled each time you upgrade x264. Examples include:
       avidemux, ffmbc, ffmpeg, gst-plugins-ugly
    EOS
  end
end
