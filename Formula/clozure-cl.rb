require 'formula'

class ClozureCl < Formula
  homepage 'http://ccl.clozure.com/'
  url 'http://ccl.clozure.com/ftp/pub/release/1.10/ccl-1.10-darwinx86.tar.gz'
  version '1.10'
  sha1 'b624499eff340c1bcfb0bd8fa4638bc4770357fc'

  conflicts_with 'cclive', :because => 'both install a ccl binary'

  def install
    # Get rid of all the .svn directories
    buildpath.find do |path|
      if path.directory? and path.basename.to_s == '.svn'
        rm_rf path
        Find.prune
      end
    end

    libexec.install Dir["*"]
    scripts = Dir["#{libexec}/scripts/ccl{,64}"]

    inreplace scripts do |s|
      s.gsub! /CCL_DEFAULT_DIRECTORY=.+$/, %Q{CCL_DEFAULT_DIRECTORY="#{libexec}"}
    end

    bin.install_symlink scripts
  end

  def test_ccl(bit = 32)
    ccl = bin + "ccl#{'64' if bit == 64}"
    %Q{#{ccl} -e '(progn (format t "Hello world from #{bit}-bit ClozureCL") (ccl::quit))'}
  end

  test do
    system test_ccl
    system test_ccl(64)
  end
end
