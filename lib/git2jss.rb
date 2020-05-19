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
      options = get_args args
      if good_args? options
      
    end

    private

    def get_args(args)
      parser = Git2JSS::Parser.new
      parser.parse
      parser
    end

    def good_args?(options)
      
    end

  end   # class Git2JSS
end   # module Git2JSS

