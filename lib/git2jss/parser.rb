require 'optparse'
require 'git2jss/version'

module Git2JSS
  class Parser
    attr_reader :files, :all, :names, :source_dir, :branch, :tag, :prefs,
                :verbose
  
    def initialize
      self.files = []
      self.all = false
      self.names = []
      self.source_dir = "."
      self.branch = nil
      self.tag = nil
      self.prefs = nil
      self.verbose = false
    end

    def parse
      options = OptionParser.new do |p|
        define_options p 
      end
      options.parse!
    end
  
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
      verbose_option parser
  
      parser.separator ""
      parser.separator "Common options:"
  
      parser.on_tail "-h", "--help", "Show this help message"  do
        puts parser
        exit
      end
  
      parser.on_tail "--version", "Show version"  do
        puts Git2JSS::VERSION
        exit
      end
    end
  
    def all_option(parser)
      parser.on "-a", "--all", "Copy all files to JSS"  do
        self.all = true
      end
    end   
  
    def files_option(parser)
      parser.on "-f", "--files f1,f2,f3", Array, "List of files"  do |f|
        self.files = f
      end
    end
  
    def names_option(parser)
      parser.on "-n", "--names n1,n2,n3", Array, "List of file names"  do |n|
        self.names = n
      end
    end
  
    def source_dir_option(parser)
      parser.on "-s", "--source-dir [DIRECTORY]", "Location of repo"  do |s|
        self.source_dir = s
      end
    end
  
    def branch_option(parser)
      parser.on "-b", "--branch BRANCH", "Target branch"  do |b|
        self.branch = b
      end
    end
  
    def tag_option(parser)
      parser.on "-t", "--tag TAG", "Target tag"  do |t|
        self.tag = t
      end
    end
  
    def info_option(parser)
      parser.on "-i", "--info [PREF FILE]", "Print JSS configuration"  do
        # check if file exists/build the object?
      end
    end
  
    def verbose_option(parser)
      parser.on "-v", "--version", "Run verbosely"  do
        self.verbose = true
      end
    end
  end   # class CLIParser
end   # module Git2JSS