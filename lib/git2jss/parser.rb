require 'optparse'
require 'git2jss/version'

module Git2JSS
  class Parser
    attr_reader :files, :all, :names, :source_dir, :branch, :tag,
                :verbose, :dry, :info, :use_keyring
  
    def initialize
      @files = nil
      @all = false
      @names = nil
      @source_dir = "./"
      @branch = nil
      @tag = nil
      @info = false
      @info_flag = false
      @verbose = false
      @dry = false
      @use_keyring = true
      @preference_file = nil
      @options = OptionParser.new do |opts|
        define_options opts
      end # block
    end # initialize

    def parse!
      return @options.parse!
    end # parse!

    def parse
      return @options.parse
    end # parse

    def help
      return @options.help
    end # help
  
    private 

    def define_options(parser)
      parser.banner = "Usage: git2jss [options]"
      parser.separator ""
      parser.separator "Specific options:"
  
      # additional options
      all_option parser
      files_option parser
      names_option parser
      source_dir_option parser
      branch_option parser
      tag_option parser
      info_option parser
      keyring_option parser
      preference_file_option parser
      verbose_option parser
      dry_run_option parser
  
      parser.separator ""
      parser.separator "Common options:"
  
      parser.on_tail "-h", "--help", "Display this help message." do
        puts parser
        exit
      end # do block
  
      parser.on_tail "--version", "Print version information and exit." do
        puts VERSION
        exit(0)
      end # do block
    end # define_options
  
    def all_option(parser)
      parser.on "-a", "--all", "Copies all files present in the source repository "\
                                "to the JSS. This option is incompatible with the "\
                                "--names option, thus the latter will be ignored if "\
                                "--all is specified." do
        @all = true
      end # do block
    end # all_option
  
    def files_option(parser)
      parser.on "-f", "--files f1,f2,f3", Array, "A list of (at least one) file to copy to "\
                                                  "copy to the JSS. If the --names option isn't "\
                                                  "also specified, git2jss will assume that objects "\
                                                  "have the same name as that of the corresponding "\
                                                  "file." do |f|
        @files = f
      end # do block
    end # files_option
  
    def names_option(parser)
      parser.on "-n", "--names n1,n2,n3", Array, "Names of objects in the JSS."\
                                                  "If this option isn't used, it is assumed that"\
                                                  "the object's name in the JSS matches exactly with"\
                                                  "the provided file name." do |n|
        @names = n
      end # do block
    end # names_option
  
    def source_dir_option(parser)
      parser.on "-s", "--source-dir DIRECTORY", String, "Path to the source Git repository on disk. "\
                                                          "This defaults to the current working directory "\
                                                          "if it is not specified." do |s|
        @source_dir = s
      end # do block
    end # source_dir_option
  
    def branch_option(parser)
      parser.on "-b", "--branch BRANCH", "The branch to target in the source repository. "\
                                          "This option is incompatible with --tag." do |b|
        @branch = b
      end # do block
    end # branch_option
  
    def tag_option(parser)
      parser.on "-t", "--tag TAG", "The tag to target in the source repository. "\
                                    "This option is incompatible with --branch." do |t|
        @tag = t
      end # do block
    end # tag_option
  
    def info_option(parser)
      parser.on "-i", "--jss-info", "Print the current JSS configuration, "\
                                      "or enter a new configuration if no "\
                                      "configuration currently exists." do
        @info = true
      end # do block
    end # info_option

    def preference_file_option(parser)
      parser.on "-p", "--pref-file PREFERENCE FILE", "Path to a preference file on disk. "\
                                      "Must conform with ruby-jss's configuration "\
                                      "file format." do |p|
        @preference_file = p
      end # do block
    end # preference_file_option


    def keyring_option(parser)
      parser.on "--no-keyring", "Don't use the System keychain to store the API user password."\
                                  "Avoid storing passwords in plaintext on the system." do
        @use_keyring = false
      end # do block
    end # keyring_option
      
    def verbose_option(parser)
      parser.on "-v", "--verbose", "Print verbose output during execution." do
        @verbose = true
      end # do block
    end # verbose_option

    def dry_run_option(parser)
      parser.on "-d", "--dry-run", "Generate dummy output which describes the operations "\
                                    "requested, but do not make any changes to the JSS." do
        @dry = true
      end # do block
    end # dry_run_option
  end # class Parser
end # module Git2JSS