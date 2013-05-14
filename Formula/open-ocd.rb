require 'formula'

class OpenOcd < Formula
  homepage 'http://sourceforge.net/projects/openocd/'
  url 'http://downloads.sourceforge.net/project/openocd/openocd/0.7.0/openocd-0.7.0.tar.bz2'
  sha1 '40fa518af4fae273f24478249fc03aa6fcce9176'

  option 'enable-ft2232_libftdi', 'Enable building support for FT2232 based devices with libftdi driver'
  option 'enable-ft2232_ftd2xx',  'Enable building support for FT2232 based devices with FTD2XX driver'

  depends_on 'libusb-compat'
  depends_on 'libftdi' if build.include? 'enable-ft2232_libftdi'

  def install
    # default options that don't imply additional dependencies
    args = %W[
      --enable-ftdi
      --enable-arm-jtag-ew
      --enable-jlink
      --enable-rlink
      --enable-stlink
      --enable-ulink
      --enable-usbprog
      --enable-vsllink
      --enable-ep93xx
      --enable-at91rm9200
      --enable-ecosboard
      --enable-opendous
      --enable-osbdm
      --enable-buspirate
    ]

    if build.include? "enable-ft2232_libftdi"
      args << "--enable-ft2232_libftdi"
      args << "--enable-presto_libftdi"
      args << "--enable-usb_blaster_libftdi"
    end

    if build.include? "enable-ft2232_ftd2xx"
      args << "--enable-ft2232_ftd2xx"
      args << "--enable-presto_ftd2xx"
    end

    ENV['CCACHE'] = 'none'

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          *args
    system "make install"
  end
end
