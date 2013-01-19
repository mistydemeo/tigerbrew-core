require 'formula'

class Ffmpeg < Formula
  homepage 'http://ffmpeg.org/'
  url 'http://ffmpeg.org/releases/ffmpeg-1.1.tar.bz2'
  sha1 'a006d8833dd7a03dd5b7823671995640322177fe'

  head 'git://git.videolan.org/ffmpeg.git'

  option "without-x264", "Disable H264 encoder"
  option "without-faac", "Disable AAC encoder"
  option "without-lame", "Disable MP3 encoder"
  option "without-xvid", "Disable Xvid MPEG-4 video format"

  option "with-freetype", "Enable FreeType"
  option "with-theora", "Enable Theora video format"
  option "with-libvorbis", "Enable Vorbis audio format"
  option "with-libvpx", "Enable VP8 video format"
  option "with-rtmpdump", "Enable RTMP protocol"
  option "with-opencore-amr", "Enable AMR audio format"
  option "with-libvo-aacenc", "Enable VisualOn AAC encoder"
  option "with-libass", "Enable ASS/SSA subtitle format"
  option "with-openjpeg", 'Enable JPEG 2000 image format'
  option 'with-schroedinger', 'Enable Dirac video format'
  option 'with-ffplay', 'Enable FFPlay media player'
  option 'with-tools', 'Enable additional FFmpeg tools'
  option 'with-fdk-aac', 'Enable the Fraunhofer FDK AAC library'
  option 'with-openssl', 'Enable OpenSSL encryption library'
  option 'with-opus', 'Enable the Opus Codec library'

  depends_on 'pkg-config' => :build

  # manpages won't be built without texi2html
  depends_on 'texi2html' => :build if MacOS.version >= :mountain_lion
  depends_on 'yasm' => :build

  depends_on 'x264' unless build.include? 'without-x264'
  depends_on 'faac' unless build.include? 'without-faac'
  depends_on 'lame' unless build.include? 'without-lame'
  depends_on 'xvid' unless build.include? 'without-xvid'

  depends_on :freetype if build.include? 'with-freetype'
  depends_on 'theora' if build.include? 'with-theora'
  depends_on 'libvorbis' if build.include? 'with-libvorbis'
  depends_on 'libvpx' if build.include? 'with-libvpx'
  depends_on 'rtmpdump' if build.include? 'with-rtmpdump'
  depends_on 'opencore-amr' if build.include? 'with-opencore-amr'
  depends_on 'libvo-aacenc' if build.include? 'with-libvo-aacenc'
  depends_on 'libass' if build.include? 'with-libass'
  depends_on 'openjpeg' if build.include? 'with-openjpeg'
  depends_on 'sdl' if build.include? 'with-ffplay'
  depends_on 'speex' if build.include? 'with-speex'
  depends_on 'schroedinger' if build.include? 'with-schroedinger'
  depends_on 'fdk-aac' if build.include? 'with-fdk-aac'
  depends_on 'opus' if build.include? 'with-opus'

  def install
    args = ["--prefix=#{prefix}",
            "--enable-shared",
            "--enable-pthreads",
            "--enable-gpl",
            "--enable-version3",
            "--enable-nonfree",
            "--enable-hardcoded-tables",
            "--enable-avresample",
            "--cc=#{ENV.cc}",
            "--host-cflags=#{ENV.cflags}",
            "--host-ldflags=#{ENV.ldflags}"
           ]

    args << "--enable-libx264" unless build.include? 'without-x264'
    args << "--enable-libfaac" unless build.include? 'without-faac'
    args << "--enable-libmp3lame" unless build.include? 'without-lame'
    args << "--enable-libxvid" unless build.include? 'without-xvid'

    args << "--enable-libfreetype" if build.include? 'with-freetype'
    args << "--enable-libtheora" if build.include? 'with-theora'
    args << "--enable-libvorbis" if build.include? 'with-libvorbis'
    args << "--enable-libvpx" if build.include? 'with-libvpx'
    args << "--enable-librtmp" if build.include? 'with-rtmpdump'
    args << "--enable-libopencore-amrnb" << "--enable-libopencore-amrwb" if build.include? 'with-opencore-amr'
    args << "--enable-libvo-aacenc" if build.include? 'with-libvo-aacenc'
    args << "--enable-libass" if build.include? 'with-libass'
    args << "--enable-ffplay" if build.include? 'with-ffplay'
    args << "--enable-libspeex" if build.include? 'with-speex'
    args << '--enable-libschroedinger' if build.include? 'with-schroedinger'
    args << "--enable-libfdk-aac" if build.include? 'with-fdk-aac'
    args << "--enable-openssl" if build.include? 'with-openssl'
    args << "--enable-libopus" if build.include? 'with-opus'

    if build.include? 'with-openjpeg'
      args << '--enable-libopenjpeg'
      args << '--extra-cflags=' + %x[pkg-config --cflags libopenjpeg].chomp
    end

    # For 32-bit compilation under gcc 4.2, see:
    # http://trac.macports.org/ticket/20938#comment:22
    ENV.append_to_cflags "-mdynamic-no-pic" if MacOS.version == :leopard or Hardware.is_32_bit?

    system "./configure", *args

    if MacOS.prefer_64_bit?
      inreplace 'config.mak' do |s|
        shflags = s.get_make_var 'SHFLAGS'
        if shflags.gsub!(' -Wl,-read_only_relocs,suppress', '')
          s.change_make_var! 'SHFLAGS', shflags
        end
      end
    end

    system "make install"

    if build.include? 'with-tools'
      system "make alltools"
      bin.install Dir['tools/*'].select {|f| File.executable? f}
    end
  end

end
