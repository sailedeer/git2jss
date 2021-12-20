module Git2JSS
  class Error < ::RuntimeError; end
  class ParameterError < Error; end
  class NotAGitRepoError < Error; end
  class NoRemoteError < Error; end
  class TooManyRemotesError < Error; end
end # Git2JSS