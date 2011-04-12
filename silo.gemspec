require 'bundler'

require File.expand_path(File.dirname(__FILE__) + '/lib/silo/version')

Gem::Specification.new do |s|
  s.name        = "silo"
  s.version     = Silo::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ 'Sebastian Staudt' ]
  s.email       = [ 'koraktor@gmail.com' ]
  s.licenses    = [ 'BSD' ]
  s.homepage    = 'http://koraktor.de/silo'
  s.summary     = 'A command-line utility and API for Git-based backups'
  s.description = %Q{With Silo you can backup arbitrary files into one or more Git repositories and take advantage of Git's compression, speed and other features. No Git knowledge needed.}

  s.add_bundler_dependencies
  s.requirements = [ 'git >= 1.6' ]

  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- test/test_*.rb`.split("\n")
  s.require_paths      = [ 'lib' ]
end
