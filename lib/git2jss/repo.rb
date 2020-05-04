require 'git2jss/exceptions'

require 'tmpdir'
require 'subprocess'
require 'pathname'

module Git2JSS

  attr_reader :source_dir

  attr_reader :ref

  attr_reader :remote_name

  attr_reader :remote_url

  attr_reader :temp_dir

  class GitRepo

    def initialize(args)
      # raise exception if we don't see the proper number of args?
      # or if args is not a hash, like we expect
      @tag ||= args[:tag]
      @branch ||= args[:branch]
      @source_dir ||= args[:source_dir] or "."
      @ref ||= args[:tag] or args[:branch]

      if tag and branch
        raise Git2JSS::ParameterError, "Specify either tag or branch"
      end

      # attempt to capture the name of the remote
      begin
        @remote_name = get_remote_name
      rescue Subprocess::NonZeroExit => e
        if e.include? "not a git repository"
          raise Git2JSS::NotAGitRepoError, "Not a git repo"
        end
      rescue RuntimeError => e
        # this is extremely bad and I need to check for each error explicitly
        puts e
      end

      @temp_dir = Dir.tempdir
      @remote_url = get_remote_url

      # attempt to clone the remote
      @temp_dir = clone_to_temp_dir
    end

    def file_in_repo?(name=nil)
      unless name not nil raise Git2JSS::ParameterError, "Filename can't be nil"
      name = File.join(@temp_dir, name)
      File.file? name
    end

    private

    # clone to temp and return path to repo in temp dir
    def clone_to_temp_dir
      output = Subprocess.check_output(%W[git clone --branch #{@ref} #{@remote_url}],
        cwd=@temp_dir).chomp.split("\n")
      
      output = output[0].split(' ')[2].chomp("\'")
      File.join(@temp_dir, output)
    end

    def get_remote_name
      # use the subprocess module to spin up a git process in @source_dir
      remotes = Subprocess.check_output(%W[git remote], cwd=@source_dir).
                  chomp.split("\n")

      if remotes.size > 1
        raise Git2JSS::TooManyRemotesError, "Git2JSS only supports one remote."
      elif remotes.size < 1 or remotes[0] is nil
        raise Git2JSS::NoRemoteError, "No Git remote is configured."
      else
        remotes[0]
      end
    end

    def get_remote_url
      # use the subprocess module to spin up a git process in @source_dir
      remote_url = Subprocess.check_output(%W[git remote show #{@remote_name}],
                                          cwd=@source_dir).chomp.split("\n")
      
      # we know the fetch URL is going to be the second line of output
      # and then the URI itself is the 3rd word on the line
      # TODO: Use regex to find the line we want instead
      remote_url = remote_url[1].split(' ')[2]
      end
  end
end
