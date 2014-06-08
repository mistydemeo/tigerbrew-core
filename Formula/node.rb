require "formula"

# Note that x.even are stable releases, x.odd are devel releases
class Node < Formula
  homepage "http://nodejs.org/"
  url "http://nodejs.org/dist/v0.10.28/node-v0.10.28.tar.gz"
  sha1 "ef08a75f6359a16e672cae684e0804ca7f4554b7"

  bottle do
    sha1 "22ea2a8408d8dacfa486b1badd42a70506f3aecc" => :mavericks
    sha1 "943f78e9337ecb8158e579b12148db541beedaea" => :mountain_lion
    sha1 "3548317dae53ecf767e530e4c27c9d2373cfb70b" => :lion
  end

  devel do
    url "http://nodejs.org/dist/v0.11.13/node-v0.11.13.tar.gz"
    sha1 "da4a9adb73978710566f643241b2c05fb8a97574"
  end

  head "https://github.com/joyent/node.git"

  option "enable-debug", "Build with debugger hooks"
  option "without-npm", "npm will not be installed"
  option "without-completion", "npm bash completion will not be installed"

  depends_on :python => :build

  fails_with :llvm do
    build 2326
  end

  resource "npm" do
    url "http://registry.npmjs.org/npm/-/npm-1.4.9.tgz"
    sha1 "29094f675dad69fc5ea24960a81c7abbfca5ce01"
  end

  def install
    args = %W{--prefix=#{prefix} --without-npm}
    args << "--debug" if build.include? "enable-debug"

    system "./configure", *args
    system "make", "install"

    resource("npm").stage libexec/"npm" if build.with? "npm"
  end

  def post_install
    return if build.without? "npm"

    node_modules = HOMEBREW_PREFIX/"lib/node_modules"
    node_modules.mkpath
    cp_r libexec/"npm", node_modules

    npm_root = node_modules/"npm"
    npmrc = npm_root/"npmrc"
    npmrc.atomic_write("prefix = #{HOMEBREW_PREFIX}\n")

    npm_root.cd { system "make", "install" }
    system "#{HOMEBREW_PREFIX}/bin/npm", "update", "npm", "-g",
                                         "--prefix", HOMEBREW_PREFIX

    Pathname.glob(npm_root/"man/*") do |man|
      man.children.each do |file|
        ln_sf file, "#{HOMEBREW_PREFIX}/share/man/#{man.basename}"
      end
    end

    if build.with? "completion"
      bash_completion.install_symlink \
        npm_root/"lib/utils/completion.sh" => "npm"
    end
  end

  def caveats
    if build.without? "npm"; <<-end.undent
      Homebrew has NOT installed npm. If you later install it, you should supplement
      your NODE_PATH with the npm module folder:
        #{HOMEBREW_PREFIX}/lib/node_modules
      end
    end
  end

  test do
    path = testpath/"test.js"
    path.write "console.log('hello');"

    output = `#{bin}/node #{path}`.strip
    assert_equal "hello", output
    assert_equal 0, $?.exitstatus

    system "#{HOMEBREW_PREFIX}/bin/npm", "install", "npm" if build.with? "npm"
  end
end
