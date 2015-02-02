class AutoScaling < AmazonWebServicesFormula
  homepage "https://aws.amazon.com/developertools/2535"
  url "https://ec2-downloads.s3.amazonaws.com/AutoScaling-2011-01-01.zip"
  version "1.0.61.6"
  sha1 "2e3aaaa2567f4dcafcedbfc05678270ab02ed341"

  def caveats
    <<-EOS.undent
      Before you can use these tools you must populate a file and export some variables to your $SHELL.

      You must create a credential file containing:

      AWSAccessKeyId=<Your AWS Access ID>
      AWSSecetKey=<Your AWS Secret Key>

      Then to export the needed variables, add them to your dotfiles.
       * On Bash, add them to `~/.bash_profile`.
       * On Zsh, add them to `~/.zprofile` instead.

      export JAVA_HOME="$(/usr/libexec/java_home)"
      export AWS_AUTO_SCALING_HOME="#{libexec}"
      export AWS_CREDENTIAL_FILE="<Path to credential file>"

      See the website for more details:
      https://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/UsingTheCommandLineTools.html
    EOS
  end

  test do
    ENV["JAVA_HOME"] = `/usr/libexec/java_home`.chomp
    ENV["AWS_AUTO_SCALING_HOME"] = libexec
    assert_match version.to_s, shell_output("#{bin}/as-version")
  end
end
