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
      @ignore_names = false
      options = self.get_args(args)

      # verify that args are reasonable
      if not self.good_args?(options)
        puts(options.help)
        exit(1)
      end # if

      # get to work
      ref = (options.tag or options.branch)
      name_sym_list = options.names.map {|n| n.to_sym}
      push_map = {}
      repo = nil

      begin
        repo = GitRepo.new ref, options.source_dir
      rescue Error
        puts("Unable to build GitRepo object. "\
              "Please ensure that the source directory "\
              "is actually a git repository."
        exit(1)
      end # begin

      # TODO: update name map to use file names as keys if
      # there isn't an object with that name already in the JSS
      # TODO: handle ignore names case, wherein we'll use the file name
      # as the key for all files.
      # TODO: handle all files case (basically the above).
      # build a list of valid files
      (0...options.files.length).each do |i|
        if repo.has_file? options.files[i]
          push_map[name_sym_list[i]] = options.files[i]
        else
          puts("WARNING: \"#{options.files[i]}\" does not exist on ref \"#{ref}\".")
        end # if
      end # each loop

      prefs = KeyringJSSPrefs.new(keyring: options.use_keyring, file: options.file)
      begin
        JSS.api.connect(user: "#{prefs.user}", pw: "#{prefs.pw}", server: "#{prefs.fqdn}")
      rescue JSS::AuthenticationError
        puts("Failed to authenticate against the JSS. Check that your password is correct.")
        exit(1)
      end # begin

      script_names_in_jss = JSS::Script.all_names
      push_map.each do |k, v|
        code = File.read(File.join(options.source_dir, v))
        script = nil
        script_names_in_jss.map(&:downcase)
        if script_names_in_jss.include?(k.to_s.downcase) or 
          # script objects exists in JSS already - let's update
          script = JSS::Script.fetch(name: k.to_s)
          t = Time.new
          if not script.notes
            script.notes = ""
          end # if
          if script.notes[-1] != "\n"
            script.notes += "\n"
          end # if
          script.notes += "Script updated on #{t.inspect} from ref #{ref}\n"
        else
          # script object doesn't exist in JSS already - let's create
          script = JSS::Script.make(name: k.to_s)
          t = Time.new
          script.notes = "Script object created on #{t.inspect} from ref #{ref}\n"
        end # if
        script.code = code
        if options.dry
          # print the results, but don't save them to the JSS
          puts script.name
          puts script.code
          puts script.info
        else
          script.save
        end # if
      end # each block
    end # self.run

    private

    def self.get_args(args)
      parser = Parser.new
      parser.parse!
      parser
    end # self.get_args

    def self.good_args?(options)
      if options.all and options.names
        puts("WARNING: --all was specified, ignoring --names.")
        @ignore_names = true
      end # if

      if not options.names
        puts("WARNING: --names was not specified. Ignoring.")
        @ignore_names = true
      end # if

      if not options.info and (not (options.branch or options.tag))
        puts("WARNING: No ref was given! Please specify either --tag or --branch.")
        return false
      end # if

      if options.tag and options.branch
        puts("Please specify either --tag or --branch (but not both).")
        return false
      end # if
    end # self.good_args?
  end # class Git2JSS
end # module Git2JSS