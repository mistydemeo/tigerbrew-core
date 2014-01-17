require 'formula'

class Passenger < Formula
  homepage 'https://www.phusionpassenger.com/'
  url 'http://s3.amazonaws.com/phusion-passenger/releases/passenger-4.0.33.tar.gz'
  sha1 'b82ef1f51eab692ea0422028ced210c65d192083'
  head 'https://github.com/phusion/passenger.git'

  depends_on :macos => :lion

  def install
    rake "apache2"
    rake "nginx"

    necessary_files = Dir["configure", "Rakefile", "README.md", "CONTRIBUTORS",
      "CONTRIBUTING.md", "LICENSE", "INSTALL.md", "NEWS", "passenger.gemspec",
      "build", "lib", "node_lib", "bin", "doc", "man", "helper-scripts",
      "ext", "resources", "buildout"]
    libexec.mkpath
    cp_r necessary_files, libexec, :preserve => true

    # Allow Homebrew to create symlinks for the Phusion Passenger commands.
    bin.mkpath
    Dir[libexec/"bin/*"].each do |orig_script|
      name = File.basename(orig_script)
      ln_s orig_script, bin/name
    end

    # Ensure that the Phusion Passenger commands can always find their library
    # files.
    locations_ini = `/usr/bin/ruby ./bin/passenger-config --make-locations-ini`
    locations_ini.gsub!(/=#{Regexp.compile Dir.pwd}\//, "=#{libexec}/")
    (libexec/"lib/phusion_passenger/locations.ini").write(locations_ini)
    system "/usr/bin/ruby", "./dev/install_scripts_bootstrap_code.rb",
      "--ruby", libexec/"lib", *Dir[libexec/"bin/*"]
    system "/usr/bin/ruby", "./dev/install_scripts_bootstrap_code.rb",
      "--nginx-module-config", libexec/"bin", libexec/"ext/nginx/config"

    mv libexec/'man', share
  end

  def caveats; <<-EOS.undent
    To activate Phusion Passenger for Apache, create /etc/apache2/other/passenger.conf:
      LoadModule passenger_module #{opt_prefix}/libexec/buildout/apache2/mod_passenger.so
      PassengerRoot #{opt_prefix}/libexec/lib/phusion_passenger/locations.ini
      PassengerDefaultRuby /usr/bin/ruby

    To activate Phusion Passenger for Nginx, run:
      brew install nginx --with-passenger
    EOS
  end

  test do
    ruby_libdir = `#{HOMEBREW_PREFIX}/bin/passenger-config --ruby-libdir`.strip
    if ruby_libdir != (libexec/"lib").to_s
      raise "Invalid installation"
    end
  end
end
