require 'formula'

class Go < Formula
  homepage 'http://golang.org'
  url 'https://go.googlecode.com/files/go1.1.1.src.tar.gz';
  version '1.1.1'
  sha1 'f365aed8183e487a48a66ace7bf36e5974dffbb3'
  head 'https://go.googlecode.com/hg/'

  skip_clean 'bin'

  option 'cross-compile-all', "Build the cross-compilers and runtime support for all supported platforms"
  option 'cross-compile-common', "Build the cross-compilers and runtime support for darwin, linux and windows"

  fails_with :clang do
    cause "clang: error: no such file or directory: 'libgcc.a'"
  end

  def install
    # install the completion scripts
    bash_completion.install 'misc/bash/go' => 'go-completion.bash'
    zsh_completion.install 'misc/zsh/go' => 'go'

    if build.include? 'cross-compile-all'
      targets = [
        ['linux',   ['386', 'amd64', 'arm'], { :cgo => false }],
        ['freebsd', ['386', 'amd64'],        { :cgo => false }],

        ['openbsd', ['386', 'amd64'],        { :cgo => false }],

        ['windows', ['386', 'amd64'],        { :cgo => false }],

        # Host platform (darwin/amd64) must always come last
        ['darwin',  ['386', 'amd64'],        { :cgo => true  }],
      ]
    elsif build.include? 'cross-compile-common'
      targets = [
        ['linux',   ['386', 'amd64', 'arm'], { :cgo => false }],
        ['windows', ['386', 'amd64'],        { :cgo => false }],

        # Host platform (darwin/amd64) must always come last
        ['darwin',  ['386', 'amd64'],        { :cgo => true  }],
      ]
    else
      targets = [
        ['darwin', [''], { :cgo => true }]
      ]
    end

    # The version check is due to:
    # http://codereview.appspot.com/5654068
    Pathname.new('VERSION').write 'default' if build.head?

    cd 'src' do
      # Build only. Run `brew test go` to run distrib's tests.
      targets.each do |(os, archs, opts)|
      archs.each do |arch|
        ENV['GOROOT_FINAL'] = prefix
        ENV['GOOS']         = os
        ENV['GOARCH']       = arch
        ENV['CGO_ENABLED']  = opts[:cgo] ? "1" : "0"
        allow_fail = opts[:allow_fail] ? "|| true" : ""
        system "./make.bash --no-clean #{allow_fail}"
      end
      end
    end

    # cleanup ENV
    ENV.delete('GOROOT_FINAL')
    ENV.delete('GOOS')
    ENV.delete('GOARCH')
    ENV.delete('CGO_ENABLED')

    Pathname.new('pkg/obj').rmtree

    # Don't install header files; they aren't necessary and can
    # cause problems with other builds.
    # See:
    # http://trac.macports.org/ticket/30203
    # http://code.google.com/p/go/issues/detail?id=2407
    prefix.install(Dir['*'] - ['include'])
  end

  def caveats; <<-EOS.undent
    The go get command no longer allows $GOROOT as
    the default destination in Go 1.1 when downloading package source.
    To use the go get command, a valid $GOPATH is now required.

    As a result of the previous change, the go get command will also fail
    when $GOPATH and $GOROOT are set to the same value.

    More information here: http://golang.org/doc/code.html#GOPATH
    EOS
  end

  test do
    (testpath/'hello.go').write <<-EOS.undent
    package main

    import "fmt"

    func main() {
        fmt.Println("Hello World")
    }
    EOS
    # Run go vet check for no errors then run the program.
    # This is a a bare minimum of go working as it uses vet, build, and run.
    assert_empty `#{bin}/go vet hello.go`
    assert_equal "Hello World\n", `#{bin}/go run hello.go`
  end
end
