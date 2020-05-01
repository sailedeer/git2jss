require 'tmpdir'
require 'subprocess'

module Git2JSS

  attr_reader :tag

  attr_reader :branch

  attr_reader :source_dir

  attr_reader :ref

  attr_reader :remote_name

  attr_reader :temp_dir

  class GitRepo

    # empty hash to start
    def initialize(args)
      # raise exception if we don't see the proper number of args
      @tag ||= args[:tag]
      @branch ||= args[:branch]
      @source_dir ||= args[:source_dir]

      # raise exception if both tag and branch specified

      @ref ||= args[:tag] or args[:branch]
      # raise exception if ref is still nil

      # raise an exception if both tag and branch specified

      # attempt to capture the name of the remote
      
      # attempt to clone the remote to a temporary file if ref is on remote
      # otherwise throw an exception
      
    end

    private

    def clone_to_temp_dir
      
    end

    def get_remote_name(source = nil)
      # raise an exception if remote is nil
    end

    def get_remote_url
    end

    
  end
end