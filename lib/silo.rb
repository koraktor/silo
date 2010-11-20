# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2010, Sebastian Staudt

libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'silo/errors'
require 'silo/repository'
require 'silo/remote/git'
require 'silo/version'

# A command-line utility and API for Git-based backups
#
# With Silo you can backup arbitrary files into one or more Git repositories
# and take advantage of Git's compression, speed and other features. No Git
# knowledge needed.
module Silo
end
