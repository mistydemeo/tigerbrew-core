class ArgyllCms < Formula
  desc "ICC compatible color management system"
  homepage "http://www.argyllcms.com/"
  url "http://www.argyllcms.com/Argyll_V1.8.2_src.zip"
  version "1.8.2"
  sha256 "59bdfaeace35d2007c90fc53234ba33bf8a64cffc08f7b27a297fc5f85455377"

  bottle do
    cellar :any
    sha256 "5ccd63160f67a179ae087d7ef94bed2ec2a73e3b0c0e211500e0aa6893569aa3" => :yosemite
    sha256 "b08312c51196318c60b75eb2fda84a08afbf0a93533ba6d57fdb5f1c41ed90ca" => :mavericks
    sha256 "807c8c40f2ebd2e67136d45a6609cbaa734e5b88c96f9d79e23be5582caf132d" => :mountain_lion
  end

  depends_on "jam" => :build
  depends_on "jpeg"
  depends_on "libtiff"

  def install
    system "sh", "makeall.sh"
    system "./makeinstall.sh"
    rm "bin/License.txt"
    prefix.install "bin", "ref", "doc"
  end

  test do
    system bin/"targen", "-d", "0", "test.ti1"
    system bin/"printtarg", testpath/"test.ti1"
    %w[test.ti1.ps test.ti1.ti1 test.ti1.ti2].each { |f| File.exist? f }
  end
end
