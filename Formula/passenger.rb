class Passenger < Formula
  desc "Server for Ruby, Python, and Node.js apps via Apache/NGINX"
  homepage "https://www.phusionpassenger.com/"
  url "https://s3.amazonaws.com/phusion-passenger/releases/passenger-5.0.10.tar.gz"
  sha256 'd44e1a65331755b4f063807f959081eb2fed1be3762645db7a103604d19b2366'
  head "https://github.com/phusion/passenger.git"

  bottle do
    sha256 "002cc75503e14694d01fc96e2db6d58ec64c343520560106a9e4448173831d75" => :yosemite
    sha256 "d181f916504b148c28ee62e7fa2ae158ac00e140647248ab66a2ba8d8310557d" => :mavericks
    sha256 "a445adc7e7460ef1a85dd329adb2f4d541f17fe745911e432e88c829904fa663" => :mountain_lion
  end

  depends_on "pcre"
  depends_on "openssl"
  depends_on :macos => :lion

  option "without-apache2-module", "Disable Apache2 module"

  def install
    rake "apache2" if build.with? "apache2-module"
    rake "nginx"
    rake "webhelper"

    (libexec/"download_cache").mkpath

    # Fixes https://github.com/phusion/passenger/issues/1288
    rm_rf "buildout/libev"
    rm_rf "buildout/libeio"
    rm_rf "buildout/cache"

    necessary_files = Dir[".editorconfig", "configure", "Rakefile", "README.md", "CONTRIBUTORS",
      "CONTRIBUTING.md", "LICENSE", "CHANGELOG", "INSTALL.md",
      "passenger.gemspec", "build", "lib", "node_lib", "bin", "doc", "man",
      "dev", "helper-scripts", "ext", "resources", "buildout"]
    libexec.mkpath
    cp_r necessary_files, libexec, :preserve => true

    # Allow Homebrew to create symlinks for the Phusion Passenger commands.
    bin.install_symlink Dir["#{libexec}/bin/*"]

    # Ensure that the Phusion Passenger commands can always find their library
    # files.
    locations_ini = `/usr/bin/ruby ./bin/passenger-config --make-locations-ini --for-native-packaging-method=homebrew`
    locations_ini.gsub!(/=#{Regexp.escape Dir.pwd}/, "=#{libexec}")
    (libexec/"lib/phusion_passenger/locations.ini").write(locations_ini)
    system "/usr/bin/ruby", "./dev/install_scripts_bootstrap_code.rb",
      "--ruby", libexec/"lib", *Dir[libexec/"bin/*"]
    system "/usr/bin/ruby", "./dev/install_scripts_bootstrap_code.rb",
      "--nginx-module-config", libexec/"bin", libexec/"ext/nginx/config"

    mv libexec/"man", share
  end

  def caveats
    s = <<-EOS.undent
      To activate Phusion Passenger for Nginx, run:
        brew install nginx --with-passenger

      EOS

    s += <<-EOS.undent if build.with? "apache2-module"
      To activate Phusion Passenger for Apache, create /etc/apache2/other/passenger.conf:
        LoadModule passenger_module #{opt_libexec}/buildout/apache2/mod_passenger.so
        PassengerRoot #{opt_libexec}/lib/phusion_passenger/locations.ini
        PassengerDefaultRuby /usr/bin/ruby

      EOS
    s
  end

  test do
    ruby_libdir = `#{HOMEBREW_PREFIX}/bin/passenger-config --ruby-libdir`.strip
    assert_equal "#{libexec}/lib", ruby_libdir
  end
end
