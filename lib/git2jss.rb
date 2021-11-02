# load the dependencies
require 'ruby-jss'

# load the rest of the module
require 'git2jss/prefs'
require 'git2jss/repo'
require 'git2jss/parser'
require 'git2jss/exceptions'
require 'git2jss/version'

module Git2JSS
  class Git2JSS
    # acts as main method for executable
    def self.run(args)
      # parse the args
      options = self.get_args args

      # verify that args are reasonable
      if not self.good_args? options
        exit(1)
      end

      # get to work
      ref = (options.tag or options.branch)
      name_sym_list = options.names.map {|n| n.to_sym}
      push_map = {}
      repo = nil

      # this raises a few errors, will need to check for each one
      begin
        repo = Git2JSS::GitRepo.new ref, options.source_dir
      rescue ArgumentError => ae
        puts ae.message
        puts ae.backtrace.inspect
      rescue Git2JSS::Error => e
        puts e.message
        puts e.backtrace.inspect
      ensure
        puts "Unable to build GitRepo object"
        exit(1)
      end

      # build a list of valid files
      (0...options.files.length).each do |i|
        if repo.has_file? options.files[i]
          push_map[name_sym_list[i]] = options.files[i]
        else
          puts "#{options.files[i]} not found at given ref"
        end
      end

      # connect to the JSS
      if options.info_flag
        

      if options.dry
        # don't make any changes to the JSS, but do everything else and
        # dump it out to stdout
        push_map.each do |k, v|
          puts "Fake push of #{v} with name #{k.to_s} to JSS"
        end
      else
        # do the actual thing
        # steps:
        #   1.  iterate over push_map, extracting name and file in repo
        #   2.  check to see if a Script object with that name exists on the JSS
        #   2.1 if it does, let's pull it down and update it
        #   2.2 if not, make a new one
        #   3.  send Script object to JSS
        puts "Real push"
      end
    end

    private

    def self.get_args(args)
      parser = Parser.new
      parser.parse!
      parser
    end

    def self.good_args?(options)
      if options.tag and not options.branch
        puts "tag specified"
        return true
      elsif options.branch and not options.tag
        puts "branch specified"
        return true
      elsif not options.branch and not options.tag and options.info_flag
        # attempt to initialize a prefs object with the info
        begin
          args = {:file => options.info}
          prefs = KeyringJSSPrefs.new args
          puts "FQDN: #{prefs.fqdn}"
          puts "USER: #{prefs.user}"
        rescue ParameterError => pe
          puts pe.message
        ensure
          return false
        end
      else
        puts options.help
        return false
      end
    end
  end   # class Git2JSS
end   # module Git2JSS

