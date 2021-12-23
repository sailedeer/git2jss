# load the dependencies
require 'ruby-jss'

# load the rest of our module
require 'git2jss/prefs'
require 'git2jss/repo'
require 'git2jss/parser'
require 'git2jss/exceptions'
require 'git2jss/version'
require 'git2jss/log'

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
    if !self.good_args?(options, args)
      # print usage and exit
      puts(options.help)
      exit(1)
    end # if

    # get to work
    ref = (options.tag || options.branch)
    Git2JSS::LOGGER.verbose_notify((options.tag ? "Using tag " : "Using branch HEAD ") + "#{ref}.")
    files = options.all ? Dir.glob("**/*.{sh,pl,py}", base: options.source_dir) :
                          options.files
    Git2JSS::LOGGER.verbose_notify("Attempting to update #{files.length} files in the JSS.")
    Git2JSS::LOGGER.verbose_notify("\n#{files}")
    name_sym_list = @ignore_names ? nil : options.names.map {|n| n.to_sym};
    push_map = {}
    repo = nil

    # attempt to create our repo object
    begin
      repo = GitRepo.new ref, options.source_dir
      Git2JSS::LOGGER.verbose_notify("Successfully cloned the repository in "\
                            "#{options.source_dir}to a temporary directory.")
    rescue Error
      Git2JSS::LOGGER.fatal("Unable to build GitRepo object. "\
                    "Please ensure that the source directory "\
                    "is actually a git repository.")
      exit(1)
    end # begin

    # build up a Hash from name -> path of available files
    (0...files.length).each do |i|
      if repo.has_file?(files[i])
        Git2JSS::LOGGER.verbose_notify("Found file: #{files[i]} in #{ref}.")
        k = @ignore_names ? File.basename(files[i]).to_sym : name_sym_list[i]
        v = files[i]
        push_map[k] = v
        Git2JSS::LOGGER.verbose_notify("Mapping #{k.to_s} to #{v}.")
      else
        Git2JSS::LOGGER.warn("\"#{files[i]}\" does not exist on ref \"#{ref}\".")
      end # if
    end # each loop

    # create prefs object using the arguments we got from the user
    prefs = KeyringJSSPrefs.new(options.preference_file, options.use_keyring)
    Git2JSS::LOGGER.verbose_notify("Successfully retrieved preferences.")
    begin
      JSS.api.connect(user: "#{prefs.user}", pw: "#{prefs.pw}", server: "#{prefs.fqdn}")
      Git2JSS::LOGGER.verbose_notify("Connected to #{prefs.fqdn} with #{prefs.user}")
    rescue JSS::AuthenticationError
      # we failed to log in with the given credentials
      Git2JSS::LOGGER.fatal("Failed to authenticate against the JSS. Check that your password is correct.")
      exit(1)
    end # begin

    script_names_in_jss = JSS::Script.all_names.map(&:downcase)
    push_map.each do |k, v|
      code = File.read(File.join(options.source_dir, v))
      script = nil
      if script_names_in_jss.include?(k.to_s.downcase)
        # script objects exists in JSS already - let's update
        Git2JSS::LOGGER.verbose_notify("#{k.to_s} already exists in #{prefs.fqdn}. Updating code and notes.")
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
        Git2JSS::LOGGER.verbose_notify("#{k.to_s} doesn't exist in #{prefs.fqdn}. Creating Script object.")
        script = JSS::Script.make(name: k.to_s)
        t = Time.new
        script.notes = "Script object created on #{t.inspect} from ref #{ref}\n"
      end # if
      begin
        script.code = code
      rescue JSS::InvalidDataError => ide
        # print an error and move to the next script object
        Git2JSS::LOGGER.warn("Improper formatting in #{v}. " + ide.message)
        next
      end # begin
      if options.dry
        # print the results, but don't save them to the JSS
        Git2JSS::LOGGER.notify("Created/updated script with name: #{script.name}")
        Git2JSS::LOGGER.notify("Created/updated script notes field: #{script.notes}")
      else
        script.save
        Git2JSS::LOGGER.verbose_notify("Saved #{script.name} to #{prefs.fqdn}.")
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

  def self.good_args?(options, args)
    if args.length < 1
      return false
    end 

    # both quiet and verbose don't make sense
    if options.quiet && options.verbose
      Git2JSS::LOGGER.fatal("Git2JSS can't be both quiet and verbose!")
      return false
    end # if
    Git2JSS::LOGGER.quiet = options.quiet
    Git2JSS::LOGGER.verbose = options.verbose

    if (options.all && options.names) || options.names.nil?
      @ignore_names = true
      if options.all && options.names
        Git2JSS::LOGGER.warn("--all was specified, ignoring --names.")
      else
        Git2JSS::LOGGER.warn("Ignoring --names field because it wasn't specified.")
      end # if
    end

    if !options.info && (!(options.branch || options.tag))
      Git2JSS::LOGGER.fatal("No ref was given! Please specify either --tag or --branch.")
      return false
    end # if

    if options.tag && options.branch
      Git2JSS::LOGGER.fatal("Please specify either --tag or --branch (but not both).")
      return false
    end # if
    return true
  end # self.good_args?
end # module Git2JSS