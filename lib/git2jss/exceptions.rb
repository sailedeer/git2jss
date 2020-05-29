module Git2JSS
  class Error < ::RuntimeError; end
  class ParameterError < Git2JSSError; end
  class NotAGitRepoError < Git2JSSError; end
  class NoRemoteError < Git2JSSError; end
  class TooManyRemotesError < Git2JSSError; end
end