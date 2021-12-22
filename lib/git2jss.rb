# load the dependencies
require 'ruby-jss'

# load the rest of our module
require 'git2jss/prefs'
require 'git2jss/repo'
require 'git2jss/parser'
require 'git2jss/exceptions'
require 'git2jss/version'

###
### Git2JSS, A Ruby program for synchronizing git repositories with a JSS instance.
###
module Git2JSS

  ### Main entry point for Git2JSS executable. Consumes the contents of ARGV,
  ### and publishes any given script objects to the JSS from a Git repository.
  ###
  ### @return [void]

  def self.run(args)
    # parse the args
    options = self.get_args(args)

    # verify that args are reasonable
    if !self.good_args?(options)
      # print usage and exit
      puts(options.help)
      exit(1)
    end # if

    # get to work
    ref = (options.tag || options.branch)
    files = options.all ? Dir.glob("**/*.{sh,pl,py}", base: options.source_dir) :
                          options.files
    name_sym_list = @ignore_names ? nil : options.names.map {|n| n.to_sym};
    push_map = {}
    repo = nil

    # attempt to create our repo object
    begin
      repo = GitRepo.new ref, options.source_dir
    rescue Error
      puts("Unable to build GitRepo object. "\
            "Please ensure that the source directory "\
            "is actually a git repository.")
      exit(1)
    end # begin

    # build up a Hash from name -> path of available files
    (0...files.length).each do |i|
      if repo.has_file?(files[i])
        if @ignore_names
          push_map[File.basename(files[i]).to_sym] = files[i]
        else
          push_map[name_sym_list[i]] = files[i]
        end # if
      else
        puts("WARNING: \"#{files[i]}\" does not exist on ref \"#{ref}\".")
      end # if
    end # each loop

    # create prefs object using the arguments we got from the user
    prefs = KeyringJSSPrefs.new(options.preference_file, options.use_keyring)
    begin
      JSS.api.connect(user: "#{prefs.user}", pw: "#{prefs.pw}", server: "#{prefs.fqdn}")
    rescue JSS::AuthenticationError
      # we failed to log in with the given credentials
      puts("FATAL: Failed to authenticate against the JSS. Check that your password is correct.")
      exit(1)
    end # begin

    script_names_in_jss = JSS::Script.all_names.map(&:downcase)
    push_map.each do |k, v|
      code = File.read(File.join(options.source_dir, v))
      script = nil
      if script_names_in_jss.include?(k.to_s.downcase)
        # script objects exists in JSS already - let's update
        script = JSS::Script.fetch(name: k.to_s)
        t = Time.new
        if !script.notes
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
      begin
        script.code = code
      rescue JSS::InvalidDataError => ide
        # print an error and move to the next script object
        puts("Improper formatting in #{v}. " + ide.message)
        next
      end # begin
      if options.dry
        # print the results, but don't save them to the JSS
        puts("Created/updated script with name: #{script.name}")
        puts("Created/updated script notes field: #{script.notes}")
      else
        script.save
        puts("Saved #{script.name} to #{prefs.fqdn}.")
      end # if
    end # each block
  end # self.run

  private

  ### Extract command-line arguments from ARGV
  ###
  ### @return [void]

  def self.get_args(args)
    parser = Parser.new
    parser.parse!(args)
    parser
  end # self.get_args

  ### Verifies that command-line arguments are good
  ###
  ### @return [Boolean]

  def self.good_args?(options)
    @ignore_names = (options.all && options.names) || options.names.nil?
    if options.all && options.names
      puts("WARNING: --all was specified, ignoring --names.")
    end # if

    if !options.info && (!(options.branch || options.tag))
      puts("FATAL: No ref was given! Please specify either --tag or --branch.")
      return false
    end # if

    if options.tag && options.branch
      puts("FATAL: Please specify either --tag or --branch (but not both).")
      return false
    end # if
    return true
  end # self.good_args?
end # module Git2JSS