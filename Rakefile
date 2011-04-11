# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010-2011, Sebastian Staudt

require 'rake/gempackagetask'
require 'rake/testtask'

task :default => :test

# Rake tasks for building the gem
spec = Gem::Specification.load('silo.gemspec')
Rake::GemPackageTask.new(spec) do |pkg|
end

# Test task
Rake::TestTask.new do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
end

begin
  require 'yard'

  # Create a rake task +:doc+ to build the documentation using YARD
  YARD::Rake::YardocTask.new do |yardoc|
    yardoc.name    = 'doc'
    yardoc.files   = ['lib/**/*.rb', 'LICENSE', 'README.md']
    yardoc.options = ['--private', '--title', 'Silo &mdash; API Documentation']
  end
rescue LoadError
  desc 'Generate YARD Documentation (not available)'
  task :doc do
    $stderr.puts 'You need YARD to build the documentation. Install it using `gem install yard`.'
  end
end

# Task for cleaning documentation and package directories
desc 'Clean documentation and package directories'
task :clean do
  FileUtils.rm_rf 'doc'
  FileUtils.rm_rf 'pkg'
end
