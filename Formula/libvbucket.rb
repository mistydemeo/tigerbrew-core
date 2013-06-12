require 'formula'

class Libvbucket < Formula
  homepage 'http://couchbase.com/develop/c/current'
  url 'http://packages.couchbase.com/clients/c/libvbucket-1.8.0.4.tar.gz'
  sha1 '4f24a85d251c0fca69e7705681a2170dd794492a'

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--without-docs"
    system "make install"
  end

  test do
    require 'multi_json'
    require 'open3'
    json = MultiJson.encode(
      {
        "hashAlgorithm" => "CRC",
        "numReplicas" => 2,
        "serverList" => ["server1:11211","server2:11210","server3:11211"],
        "vBucketMap" => [[0,1,2],[1,2,0],[2,1,-1],[1,2,0]],
      }
    )

    expected = <<-EOS.undent
      key: hello master: server1:11211 vBucketId: 0 couchApiBase: (null) replicas: server2:11210 server3:11211
      key: world master: server2:11210 vBucketId: 3 couchApiBase: (null) replicas: server3:11211 server1:11211
      EOS

    Open3.popen3("#{bin}/vbuckettool", "-", "hello", "world") do |stdin, stdout, _|
      stdin.write(json)
      stdin.close
      assert_equal expected, stdout.read
    end
  end
end
