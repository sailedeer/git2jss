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
        repo = GitRepo.new ref, options.source_dir
      rescue ArgumentError
        puts "Unable to build GitRepo object."\
              "Please ensure that the source directory is actually a git repository."
        exit(1)
      rescue Error => e
        puts "Unable to build GitRepo object."\
        "Please ensure that the source directory is actually a git repository."
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

      prefs = KeyringJSSPrefs.new(keyring: true, file: true)
      # 0. connect to the JSS
      begin
        JSS.api.connect(user: "#{prefs.user}", pw: "#{prefs.pw}", server: "#{prefs.fqdn}")
      rescue JSS::AuthenticationError
        puts "Failed to authenticate against the JSS. Check that your password is correct."
        # TODO: prompt for a password and update the keychain
      end
      script_names_in_jss = JSS::Script.all_names
      push_map.each do |k, v|
        code = File.read(File.join(options.source_dir, v))
        script = nil
        script_names_in_jss.map(&:downcase)
        if script_names_in_jss.include?(k.to_s.downcase) or 
          # script objects exists in JSS already - let's update
          script = JSS::Script.fetch(name: k.to_s)
          t = Time.new
          # TODO: add the commit that corresponds with this file - how to get this?
          if not script.notes
            script.notes = ""
          end
          if script.notes[-1] != "\n"
            script.notes += "\n"
          end
          script.notes += "Script updated on #{t.inspect} from ref #{ref}\n"
        else
          # script object doesn't exist in JSS already - let's create
          script = JSS::Script.make(name: k.to_s)
          t = Time.new
          script.notes = "Script object created on #{t.inspect} from ref #{ref}\n"
        end
        script.code = code
        if options.dry
          # print the results, but don't save them to the JSS
          puts script.name
          puts script.code
          puts script.info
        else
          script.save
        end
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
        return true
      elsif options.branch and not options.tag
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

