module Git2JSS
  ### General Runtime Error for Git2JSS
  class Error < ::RuntimeError; end

  ### Function Parameter Error
  class ParameterError < Error; end

  ### Not a Git Repository Error
  class NotAGitRepoError < Error; end

  ### No Remote Found Error
  class NoRemoteError < Error; end

  ### Too Many Remotes Error
  class TooManyRemotesError < Error; end
end # Git2JSS