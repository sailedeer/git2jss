# load the dependencies
require 'ruby-jss'

# load the rest of the module
require 'git2jss/prefs'
require 'git2jss/repo'
require 'git2jss/parser'

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
        repo = Git2JSS::GitRepo ref, options.source_dir
      rescue ArgumentError => ae
        puts ae.message
        puts ae.backtrace.inspect
      rescue Git2JSS::Error => e
        puts re.message
        puts re.backtrace.inspect
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

      if options.dry
        # don't make any changes to the JSS, but do everything else and
        # dump it out to stdout
        push_map.each do |k, v|
          puts "Fake push of #{v} with name #{k.to_s} to JSS"
        end
      else
        # do the actual thing
      end
    end

    private

    def self.get_args(args)
      parser = Git2JSS::Parser.new
      parser.parse!
      parser
    end

    def self.good_args?(options)
      if options.tag and options.branch
        puts "Specify either --tag or --branch, but not both."
        return false
      end
      if options.files.length != options.names.length
        puts "The number of files does not equal the number of names."
        return false
      end
      if options.all and options.files 
        puts "Specify either --all or --files, but not both."
        return false
      end
      true
    end
  end   # class Git2JSS
end   # module Git2JSS

