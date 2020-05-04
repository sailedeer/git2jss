module Git2JSS
  class ParameterError < RuntimeError; end
  class NotAGitRepoError < RuntimeError; end
  class NoRemoteError < RuntimeError; end
  class TooManyRemotesError < RuntimeError; end
end