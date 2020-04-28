proj_name = 'git2jss'
lib_dir   = 'git2jss'

require "./lib/#{lib_dir}/version"

Gem::Specification.new do |s|
  # General
  s.name        = proj_name
  s.version     = Git2JSS::VERSION
  s.date        = Time.now.utc.strftime('%Y-%m-%d')
  s.summary     = "Git to JSS"
  s.description = <<-EOD
                  The git2jss gem provides a utility by which scripts in a git
                  repository can be published to a Jamf Software Server (JSS).
                  It leverages the ruby-jss gem provided by Pixar Animation
                  Studios at https://github.com/PixarAnimationStudios/ruby-jss.
                  For more details on usage, see the README file. 
                  EOD
  s.authors     = ["Eli Reed"]
  s.email       = ["erobreed@uw.edu"]
  # s.homepage    = 'https://rubygems.org/gems/git2jss' or https://github.com/UW-LT/git2jss
  # s.license     = what license should we use?

  s.files       = Dir['lib/**/*.rb']
  s.files       << '.yardopts'
  s.files       += Dir['test/**/*']

  s.executables << 'git2jss'

  # Dependencies
  s.required_ruby_version   = '>= 2.0.0'

  s.add_runtime_dependency  = 'ruby-jss'

  # Rdoc
  s.extra_rdoc_files  = ['README.md', 'LICENSE.txt', 'CHANGES.md']
  s.rdoc_options      << '--title' << 'Git2JSS' << '--line-numbers' << '--main' << 'README.md'
end