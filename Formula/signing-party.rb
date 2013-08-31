require 'formula'

class GnupgInstalled < Requirement
  fatal true
  default_formula 'gnupg2'
  satisfy { which('gpg') || which('gpg2') }
end

class SigningParty < Formula
  homepage 'http://pgp-tools.alioth.debian.org/'
  url 'http://ftp.debian.org/debian/pool/main/s/signing-party/signing-party_1.1.4.orig.tar.gz'
  sha1 '092b7d644b7a8a8d2e82fd6ddb453ca58020ed31'

  depends_on GnupgInstalled
  depends_on 'dialog'
  depends_on 'qprint'
  depends_on 'MIME::Tools' => :perl
  depends_on 'Text::Template' => :perl
  depends_on 'Text::Iconv' => :perl
  depends_on 'GnuPG::Interface' => :perl

  # gpgparticipants data on OS X behaves differently from linux version
  # https://github.com/mxcl/homebrew/pull/21628
  def patches
    DATA
  end

  def install
    # gpgdir and gpgwrap are not included as they have their own homepages
    # springraph is not included because it depends on the 'GD' perl module
    # which has its own dependency issues

    doc.install 'README'

    cd 'caff' do
      inreplace 'caff', '/usr/share/doc/signing-party', HOMEBREW_PREFIX/'share/doc/signing-party'
      system "make"
      man1.install Dir['*.1']
      bin.install 'caff', 'pgp-clean', 'pgp-fixkey'
      (doc/'caff').install Dir['README*', 'caffrc.sample']
    end

    cd 'gpg-key2ps' do
      system "make"
      man1.install 'gpg-key2ps.1'
      bin.install 'gpg-key2ps'
      (doc/'key2ps').install 'README'
    end

    cd 'gpg-mailkeys' do
      inreplace 'gpg-mailkeys',
        %q[`getent passwd $USER | cut -d: -f5 | cut -d, -f1`],
        %q[`osascript -e "long user name of (system info)" 2>/dev/null`]

      bin.install 'gpg-mailkeys'
      man1.install 'gpg-mailkeys.1'
      (doc/'gpg-mailkeys').install 'README', 'example.gpg-mailkeysrc'
    end

    cd 'gpglist' do
      system "make"
      bin.install 'gpglist'
      man1.install 'gpglist.1'
    end

    cd 'gpgparticipants' do
      bin.install 'gpgparticipants'
      man1.install 'gpgparticipants.1'
    end

    cd 'gpgsigs' do
      system "make"
      man1.install 'gpgsigs.1'
      bin.install 'gpgsigs', 'gpgsigs-eps-helper'
      (doc/'gpgsigs').install Dir['gpgsigs-lt2k5*.txt']
    end

    cd 'keyanalyze' do
      system "make"
      bin.install 'keyanalyze', 'process_keys', 'pgpring/pgpring'
      man1.install 'keyanalyze.1', 'process_keys.1', 'pgpring/pgpring.1'
    end

    cd 'keylookup' do
      bin.install 'keylookup'
      man1.install 'keylookup.1'
    end

    cd 'sig2dot' do
      bin.install 'sig2dot'
      man1.install 'sig2dot.1'
      (doc/'sig2dot').install 'README.sig2dot'
    end
  end
end

__END__
diff --git a/gpgparticipants/gpgparticipants b/gpgparticipants/gpgparticipants
index 4dd06e8..ea76aff 100755
--- a/gpgparticipants/gpgparticipants
+++ b/gpgparticipants/gpgparticipants
@@ -29,7 +29,7 @@ title=$(echo "$5"|tr a-z A-Z|sed 's/\(.\)/\1 /g')
 exec > "$output"
 
 # Date of event
-LANG=C date --date="$date" +"%A, %B %e, %Y;  %H:%M"
+LANG=C date -j -f "%Y%m%d %H%M" "$date" +"%A, %B %e, %Y;  %H:%M"
 # Organiser contact
 printf "%80s\n\n\n" "$org"
 # Title
