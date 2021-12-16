require 'tmpdir'
require 'subprocess'
require 'git'
require 'fileutils'

module Git2JSS

  attr_reader :source_dir

  attr_reader :ref

  attr_reader :remote_name

  attr_reader :remote_uri

  attr_reader :temp_repo_dir

  class GitRepo

    def initialize(ref, source_dir)
      @ref = ref
      @source_dir = File.expand_path(source_dir)
      raise ArgumentError, "Source dir invalid" unless Dir.exist? @source_dir
      @git = Git.open(source_dir)

      # attempt to capture the name of the remote
      begin
        @remote_name = get_remote_name
      rescue Subprocess::NonZeroExit => e
        if e.include? "not a git repository"
          raise NotAGitRepoError, "Not a git repo"
        else
          raise RuntimeError, "Unknown error"
        end
      rescue RuntimeError => e
        # this is extremely bad and I need to check for each error explicitly
        puts e
      end

      @temp_repo_dir = Dir.mktmpdir
      @remote_uri = get_remote_uri

      # attempt to clone the remote
      @temp_repo_dir = clone_to_temp_dir
    end

    # does the file exist at the ref?
    def has_file?(name)
      name = File.join(@temp_repo_dir, name)
      File.exist? name
    end

    # retrieve a File object which corresponds to the specified file
    def get_file(name)
      name = File.join(@temp_repo_dir, name)
      File.new name, "r"
    end

    private

    # clone to temp and return path to repo in temp dir
    def clone_to_temp_dir
      begin
        temp_repo = Git.clone("#{@remote_uri}", "#{@temp_repo_dir}")
      rescue Git::GitExecuteError
        FileUtils.remove_dir("#{@temp_repo_dir}", force: true)
        temp_repo = Git.clone("#{@remote_uri}", "#{@temp_repo_dir}")     
      end
      return temp_repo.dir.to_s
    end

    # retrieves the name of the remote (usually origin)
    def get_remote_name
      remotes = @git.remotes

      if remotes.size > 1
        raise TooManyRemotesError, "Git2JSS only supports one remote."
      elsif remotes.size < 1 or remotes[0] == nil
        raise NoRemoteError, "No Git remote is configured."
      else
        remotes[0].name
      end
    end

    # retrieves the URI of the remote
    def get_remote_uri
      remotes = @git.remotes
      return remotes[0].url
    end
  end
end

